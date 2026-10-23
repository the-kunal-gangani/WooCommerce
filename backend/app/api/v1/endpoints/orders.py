from decimal import Decimal, InvalidOperation
from typing import Any

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status

from app.api.deps import get_current_user
from app.integrations.woocommerce.client import (
    WooCommerceClient,
    WooCommerceConfigurationError,
    WooCommerceError,
)
from app.models.user import User

router = APIRouter(prefix="/orders", tags=["Orders"])

_ALLOWED_STATUSES = {
    "pending",
    "processing",
    "on-hold",
    "completed",
    "cancelled",
    "refunded",
    "failed",
}


def _minor(value: Any) -> int:
    try:
        amount = Decimal(str(value or "0"))
        return int((amount * 100).to_integral_value())
    except (InvalidOperation, TypeError, ValueError):
        return 0


def _format_order(order: dict[str, Any], *, detail: bool) -> dict[str, Any]:
    currency = str(order.get("currency") or "INR")
    items = []
    for item in order.get("line_items", []):
        if not isinstance(item, dict):
            continue
        items.append({
            "id": item.get("id", 0),
            "product_id": item.get("product_id", 0),
            "variation_id": item.get("variation_id", 0),
            "name": item.get("name", ""),
            "quantity": item.get("quantity", 0),
            "subtotal": _minor(item.get("subtotal")),
            "total": _minor(item.get("total")),
            "sku": item.get("sku", ""),
            "image": "",
        })

    result: dict[str, Any] = {
        "id": order.get("id", 0),
        "number": str(order.get("number") or order.get("id") or ""),
        "status": order.get("status", ""),
        "status_label": str(order.get("status") or "").replace("-", " ").title(),
        "date_created": order.get("date_created", ""),
        "currency": {
            "currency_code": currency,
            "currency_symbol": "₹" if currency == "INR" else currency,
            "currency_minor_unit": 2,
            "currency_decimal_separator": ".",
            "currency_thousand_separator": ",",
            "currency_prefix": "₹" if currency == "INR" else "",
            "currency_suffix": "",
        },
        "total": _minor(order.get("total")),
        "item_count": sum(int(item.get("quantity", 0)) for item in items),
        "items": items,
        "tracking": [],
    }

    if detail:
        result.update({
            "subtotal": _minor(order.get("subtotal")),
            "discount_total": _minor(order.get("discount_total")),
            "shipping_total": _minor(order.get("shipping_total")),
            "tax_total": _minor(order.get("total_tax")),
            "payment_method_title": order.get("payment_method_title", ""),
            "shipping_method": ", ".join(
                str(line.get("method_title", ""))
                for line in order.get("shipping_lines", [])
                if isinstance(line, dict)
            ),
            "customer_note": order.get("customer_note", ""),
            "billing": order.get("billing", {}),
            "shipping": order.get("shipping", {}),
            "notes": [],
        })
    return result


def _client(request: Request) -> WooCommerceClient:
    return request.app.state.woocommerce_client


@router.get("")
async def list_orders(
    request: Request,
    current_user: User = Depends(get_current_user),
    page: int = Query(default=1, ge=1),
    per_page: int = Query(default=10, ge=1, le=50),
    order_status: str | None = Query(default=None, alias="status"),
) -> dict[str, Any]:
    if current_user.woocommerce_customer_id is None:
        return {"items": [], "total": 0, "total_pages": 0}
    if order_status is not None and order_status not in _ALLOWED_STATUSES:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Unsupported order status.",
        )

    try:
        result = await _client(request).get_orders(
            customer_id=current_user.woocommerce_customer_id,
            page=page,
            per_page=per_page,
            status=order_status,
        )
        return {
            "items": [
                _format_order(order, detail=False)
                for order in result["items"]
            ],
            "total": result["total"],
            "total_pages": result["total_pages"],
        }
    except WooCommerceConfigurationError as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="WooCommerce integration is not configured.",
        ) from exc
    except WooCommerceError as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Unable to retrieve orders from WooCommerce.",
        ) from exc


@router.get("/{order_id}")
async def get_order(
    order_id: int,
    request: Request,
    current_user: User = Depends(get_current_user),
) -> dict[str, Any]:
    if current_user.woocommerce_customer_id is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found.",
        )

    try:
        order = await _client(request).get_order(order_id)
    except WooCommerceError as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Unable to retrieve the order from WooCommerce.",
        ) from exc

    if order.get("customer_id") != current_user.woocommerce_customer_id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found.",
        )

    return _format_order(order, detail=True)
