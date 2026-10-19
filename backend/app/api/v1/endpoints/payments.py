import asyncio
import hashlib
import hmac
import json
import logging
from decimal import Decimal, InvalidOperation
from typing import Any, Literal

import razorpay
from fastapi import APIRouter, Depends, Header, HTTPException, Request, status
from pydantic import AliasChoices, BaseModel, Field
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.core.config import get_settings
from app.db.session import get_db
from app.integrations.woocommerce.client import (
    WooCommerceClient,
    WooCommerceError,
)
from app.models.payment import Payment
from app.models.user import User

router = APIRouter(prefix="/payments", tags=["Payments"])
logger = logging.getLogger(__name__)

# Initial shipping policy matching the current Flutter checkout UI.
# Keep these prices server-side. Adjust them if your store's policy changes.
SHIPPING_OPTIONS = {
    "standard": {
        "method_id": "flat_rate",
        "method_title": "Standard shipping",
        "total": "0.00",
    },
    "express": {
        "method_id": "flat_rate",
        "method_title": "Express shipping",
        "total": "15.00",
    },
}


# ---------- Request models ----------


class AddressPayload(BaseModel):
    first_name: str = Field(min_length=1, max_length=100)
    last_name: str = Field(default="", max_length=100)
    phone: str = Field(min_length=7, max_length=30)
    address_1: str = Field(min_length=1, max_length=255)
    address_2: str | None = Field(default=None, max_length=255)
    city: str = Field(min_length=1, max_length=100)
    state: str = Field(min_length=1, max_length=100)
    postcode: str = Field(min_length=1, max_length=20)
    country: str = Field(default="IN", min_length=2, max_length=2)
    company: str | None = Field(default=None, max_length=150)


class CartLinePayload(BaseModel):
    product_id: int = Field(
        gt=0,
        validation_alias=AliasChoices("product_id", "productId"),
    )
    quantity: int = Field(ge=1, le=99)
    variation_id: int | None = Field(
        default=None,
        gt=0,
        validation_alias=AliasChoices("variation_id", "variationId"),
    )


class CreateOrderPayload(BaseModel):
    billing: AddressPayload
    shipping: AddressPayload
    items: list[CartLinePayload] = Field(min_length=1, max_length=100)
    shipping_method: Literal["standard", "express"]
    coupon_code: str | None = Field(default=None, max_length=100)
    customer_note: str | None = Field(default=None, max_length=500)


class VerifyPaymentPayload(BaseModel):
    razorpay_order_id: str = Field(min_length=1, max_length=100)
    razorpay_payment_id: str = Field(min_length=1, max_length=100)
    razorpay_signature: str = Field(min_length=1, max_length=256)


# ---------- Helpers ----------


def _get_razorpay_client() -> Any:
    settings = get_settings()
    key_id = settings.razorpay_key_id.strip()
    key_secret = settings.razorpay_key_secret.get_secret_value().strip()

    if not key_id or not key_secret:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Razorpay is not configured.",
        )

    return razorpay.Client(auth=(key_id, key_secret))


def _amount_to_minor_units(total: Any) -> int:
    """Convert a WooCommerce INR total into paise without float arithmetic."""
    try:
        amount = Decimal(str(total))
    except (InvalidOperation, ValueError, TypeError):
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="WooCommerce returned an invalid order total.",
        ) from None

    if not amount.is_finite() or amount <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="The order total must be greater than zero.",
        )

    paise = amount * 100

    if paise != paise.to_integral_value():
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="The order total has invalid INR precision.",
        )

    return int(paise)


def _verify_checkout_signature(
    *,
    order_id: str,
    payment_id: str,
    signature: str,
) -> bool:
    secret = get_settings().razorpay_key_secret.get_secret_value().strip()
    message = f"{order_id}|{payment_id}".encode("utf-8")
    expected = hmac.new(
        secret.encode("utf-8"),
        message,
        hashlib.sha256,
    ).hexdigest()

    return hmac.compare_digest(expected, signature)


async def _close_woocommerce(client: WooCommerceClient) -> None:
    await client.close()


async def _update_woocommerce_order(
    order_id: int,
    payload: dict[str, Any],
) -> dict[str, Any]:
    client = WooCommerceClient()
    try:
        return await client.update_order(order_id, payload)
    finally:
        await _close_woocommerce(client)


def _address_for_woocommerce(
    address: AddressPayload,
    *,
    email: str | None = None,
) -> dict[str, Any]:
    result = address.model_dump(exclude_none=True)
    if email:
        result["email"] = email
    return result


# ---------- Create order ----------


@router.post("/create-order", status_code=status.HTTP_201_CREATED)
async def create_payment_order(
    payload: CreateOrderPayload,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict[str, Any]:
    """Create a pending WooCommerce order and its Razorpay order."""

    client = WooCommerceClient()
    woo_order: dict[str, Any] | None = None

    try:
        # Build line items exclusively from product IDs and quantities.
        # Names, prices, SKUs and totals submitted by Flutter are ignored.
        line_items: list[dict[str, Any]] = []

        for item in payload.items:
            product = await client.get_product(item.product_id)

            if product.get("status") != "publish":
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Product {item.product_id} is not available.",
                )

            if not product.get("purchasable", True):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Product {item.product_id} cannot be purchased.",
                )

            product_type = product.get("type")

            if product_type == "variable" and item.variation_id is None:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=(
                        f"Select a variation for product {item.product_id}."
                    ),
                )

            if item.variation_id is not None:
                variation = await client.get_variation(
                    item.product_id,
                    item.variation_id,
                )

                if variation.get("status") != "publish":
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail="The selected variation is unavailable.",
                    )

                if not variation.get("purchasable", True):
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail="The selected variation cannot be purchased.",
                    )

                if variation.get("stock_status") == "outofstock":
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail="The selected variation is out of stock.",
                    )

                line_items.append({
                    "product_id": item.product_id,
                    "variation_id": item.variation_id,
                    "quantity": item.quantity,
                })
            else:
                if product.get("stock_status") == "outofstock":
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"Product {item.product_id} is out of stock.",
                    )

                line_items.append({
                    "product_id": item.product_id,
                    "quantity": item.quantity,
                })

        shipping_option = SHIPPING_OPTIONS[payload.shipping_method]

        order_payload: dict[str, Any] = {
            "status": "pending",
            "payment_method": "razorpay",
            "payment_method_title": "Razorpay",
            "set_paid": False,
            "billing": _address_for_woocommerce(
                payload.billing,
                email=current_user.email,
            ),
            "shipping": _address_for_woocommerce(payload.shipping),
            "line_items": line_items,
            "shipping_lines": [{
                "method_id": shipping_option["method_id"],
                "method_title": shipping_option["method_title"],
                "total": shipping_option["total"],
            }],
        }

        if current_user.woocommerce_customer_id is not None:
            order_payload["customer_id"] = (
                current_user.woocommerce_customer_id
            )

        if payload.coupon_code:
            coupon = payload.coupon_code.strip()
            if not coupon:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Coupon code cannot be blank.",
                )

            # WooCommerce is responsible for validating and calculating
            # the coupon discount.
            order_payload["coupon_lines"] = [{"code": coupon}]

        if payload.customer_note:
            order_payload["customer_note"] = payload.customer_note.strip()

        woo_order = await client.create_order(order_payload)

        woo_order_id = int(woo_order["id"])

        # Do not continue if WooCommerce did not apply the requested coupon.
        if payload.coupon_code:
            requested_coupon = payload.coupon_code.strip().casefold()
            applied_coupons = {
                str(coupon.get("code", "")).casefold()
                for coupon in woo_order.get("coupon_lines", [])
                if isinstance(coupon, dict)
            }

            if requested_coupon not in applied_coupons:
                try:
                    await client.update_order(
                        woo_order_id,
                        {"status": "cancelled"},
                    )
                except WooCommerceError:
                    logger.exception(
                        "Could not cancel order after coupon validation failed."
                    )

                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="WooCommerce did not apply the requested coupon.",
                )

        currency = str(woo_order.get("currency", "")).upper()
        if currency != "INR":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Only INR payments are currently supported.",
            )

        amount_minor = _amount_to_minor_units(woo_order.get("total"))

        # Razorpay's Python SDK uses synchronous HTTP requests. Run those
        # calls in a worker thread so they don't block FastAPI's event loop.
        razorpay_client = _get_razorpay_client()
        razorpay_order = await asyncio.to_thread(
            razorpay_client.order.create,
            data={
                "amount": amount_minor,
                "currency": "INR",
                "receipt": f"wc-{woo_order_id}",
                "notes": {
                    "woocommerce_order_id": str(woo_order_id),
                    "user_id": str(current_user.id),
                },
            },
        )

        razorpay_order_id = str(razorpay_order.get("id", ""))
        if not razorpay_order_id:
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail="Razorpay did not return a valid order ID.",
            )

        payment = Payment(
            user_id=current_user.id,
            woocommerce_order_id=woo_order_id,
            razorpay_order_id=razorpay_order_id,
            amount_minor=amount_minor,
            currency="INR",
            status="created",
        )
        db.add(payment)

        try:
            db.commit()
        except IntegrityError:
            db.rollback()
            logger.exception("Could not persist the payment record.")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Could not save the payment order.",
            ) from None

        line_items = woo_order.get("line_items", [])

        subtotal = sum(
            (
                Decimal(str(item.get("subtotal", "0") or "0"))
                for item in line_items
                ),
            Decimal("0.00"),
        )
        settings = get_settings()
        return {
            "woocommerce_order_id": woo_order_id,
            "order_number": str(woo_order.get("number") or woo_order_id),
            "razorpay_order_id": razorpay_order_id,
            "subtotal": str(subtotal),
            "shipping_total": str(woo_order.get("shipping_total", "0")),
            "discount_total": str(woo_order.get("discount_total", "0")),
            "total_tax": str(woo_order.get("total_tax", "0")),
            "total": str(woo_order.get("total", "0")),
            "amount": amount_minor,
            "currency": "INR",
            "key_id": settings.razorpay_key_id,
        }

    except HTTPException:
        raise

    except WooCommerceError:
        logger.exception("WooCommerce order creation failed.")
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Could not create the store order.",
        ) from None

    except Exception:
        logger.exception("Payment order creation failed.")

        if woo_order and woo_order.get("id"):
            try:
                await client.update_order(
                    int(woo_order["id"]),
                    {"status": "failed"},
                )
            except Exception:
                logger.exception(
                    "Could not mark the WooCommerce order as failed."
                )

        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Could not initialize the payment. Please try again.",
        ) from None

    finally:
        await client.close()


# ---------- Verify checkout ----------


@router.post("/verify")
async def verify_payment(
    payload: VerifyPaymentPayload,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict[str, Any]:
    """Verify the checkout signature and reconcile the payment."""

    payment = db.scalar(
        select(Payment).where(
            Payment.razorpay_order_id == payload.razorpay_order_id,
            Payment.user_id == current_user.id,
        )
    )

    if payment is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Payment order was not found.",
        )

    if payment.status == "paid":
        if payment.razorpay_payment_id == payload.razorpay_payment_id:
            return {
                "status": "paid",
                "woocommerce_order_id": payment.woocommerce_order_id,
            }

        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="This order has already been paid.",
        )

    if not _verify_checkout_signature(
        order_id=payload.razorpay_order_id,
        payment_id=payload.razorpay_payment_id,
        signature=payload.razorpay_signature,
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid payment signature.",
        )

    razorpay_client = _get_razorpay_client()

    try:
        payment_info = await asyncio.to_thread(
            razorpay_client.payment.fetch,
            payload.razorpay_payment_id,
        )
    except Exception:
        logger.exception("Could not fetch payment details from Razorpay.")
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Could not verify the payment status. Please retry.",
        ) from None

    if str(payment_info.get("order_id", "")) != payment.razorpay_order_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="The payment does not match this order.",
        )

    try:
        fetched_amount = int(payment_info.get("amount"))
    except (ValueError, TypeError):
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Razorpay returned an invalid payment amount.",
        ) from None

    if (
        fetched_amount != payment.amount_minor
        or str(payment_info.get("currency", "")).upper() != payment.currency
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="The payment amount or currency does not match the order.",
        )

    gateway_status = str(payment_info.get("status", "")).lower()

    if gateway_status not in {"captured", "authorized", "failed"}:
        return {
            "status": gateway_status or "pending",
            "woocommerce_order_id": payment.woocommerce_order_id,
            "message": "Payment is not yet confirmed. Please wait.",
        }

    # Never downgrade a payment that has already been marked paid.
    if payment.status == "paid":
        return {
            "status": "paid",
            "woocommerce_order_id": payment.woocommerce_order_id,
        }

    if gateway_status == "captured":
        await _update_woocommerce_order(
            payment.woocommerce_order_id,
            {
                "status": "processing",
                "transaction_id": payload.razorpay_payment_id,
                "payment_method": "razorpay",
                "payment_method_title": "Razorpay",
            },
        )
        payment.status = "paid"

    elif gateway_status == "authorized":
        payment.status = "authorized"

    else:
        await _update_woocommerce_order(
            payment.woocommerce_order_id,
            {"status": "failed"},
        )
        payment.status = "failed"

    payment.razorpay_payment_id = payload.razorpay_payment_id
    db.commit()

    return {
        "status": payment.status,
        "woocommerce_order_id": payment.woocommerce_order_id,
    }


# ---------- Razorpay webhook ----------


@router.post("/webhook", status_code=status.HTTP_200_OK)
async def razorpay_webhook(
    request: Request,
    x_razorpay_signature: str | None = Header(default=None),
    db: Session = Depends(get_db),
) -> dict[str, str]:
    """Verify Razorpay's raw-body signature and reconcile known payments."""

    settings = get_settings()
    webhook_secret = (
        settings.razorpay_webhook_secret.get_secret_value().strip()
    )

    if not webhook_secret:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Webhook is not configured.",
        )

    if not x_razorpay_signature:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Missing webhook signature.",
        )

    raw_body = await request.body()
    expected_signature = hmac.new(
        webhook_secret.encode("utf-8"),
        raw_body,
        hashlib.sha256,
    ).hexdigest()

    if not hmac.compare_digest(
        expected_signature,
        x_razorpay_signature.strip(),
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid webhook signature.",
        )

    try:
        event_payload = json.loads(raw_body)
    except (json.JSONDecodeError, UnicodeDecodeError):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid JSON payload.",
        ) from None

    event_type = event_payload.get("event")
    if not isinstance(event_type, str):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Missing event type.",
        )

    if event_type not in {"payment.captured", "payment.failed"}:
        return {"status": "received", "event": event_type}

    try:
        entity = event_payload["payload"]["payment"]["entity"]
        razorpay_order_id = str(entity["order_id"])
        razorpay_payment_id = str(entity["id"])
        amount_minor = int(entity["amount"])
        currency = str(entity["currency"]).upper()
    except (KeyError, TypeError, ValueError):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid payment event payload.",
        ) from None

    payment = db.scalar(
        select(Payment).where(
            Payment.razorpay_order_id == razorpay_order_id
        )
    )

    if payment is None:
        # A retry can succeed after the create-order request has persisted.
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Payment order is not registered yet.",
        )

    if (
        amount_minor != payment.amount_minor
        or currency != payment.currency
    ):
        logger.error(
            "Razorpay webhook amount/currency mismatch for payment record %s",
            payment.id,
        )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Payment amount or currency mismatch.",
        )

    # Idempotency: repeated captured events must not downgrade or duplicate
    # an already-paid order.
    if payment.status == "paid":
        return {"status": "received", "event": event_type}

    if event_type == "payment.captured":
        await _update_woocommerce_order(
            payment.woocommerce_order_id,
            {
                "status": "processing",
                "transaction_id": razorpay_payment_id,
                "payment_method": "razorpay",
                "payment_method_title": "Razorpay",
            },
        )
        payment.status = "paid"

    else:
        # A late failure event must not overwrite an already-captured payment.
        if payment.status != "paid":
            await _update_woocommerce_order(
                payment.woocommerce_order_id,
                {"status": "failed"},
            )
            payment.status = "failed"

    payment.razorpay_payment_id = razorpay_payment_id
    db.commit()

    return {"status": "received", "event": event_type}
