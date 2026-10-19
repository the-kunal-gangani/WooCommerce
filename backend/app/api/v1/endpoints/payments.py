
import hashlib
import hmac
import json
import logging

from fastapi import APIRouter, Header, HTTPException, Request, status

from app.core.config import get_settings

router = APIRouter(prefix="/payments", tags=["Payments"])
logger = logging.getLogger(__name__)


@router.post("/webhook", status_code=status.HTTP_200_OK)
async def razorpay_webhook(
    request: Request,
    x_razorpay_signature: str | None = Header(default=None),
) -> dict[str, str]:
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

    # Verify the signature against the exact raw request body.
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
        payload = json.loads(raw_body)
    except (json.JSONDecodeError, UnicodeDecodeError):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid JSON payload.",
        )

    event_type = payload.get("event")

    if not isinstance(event_type, str):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Missing event type.",
        )

    if event_type in {"payment.captured", "payment.failed"}:
        # Signature is valid, but order matching and persistence
        # must be implemented before changing any order status.
        logger.info("Verified Razorpay webhook received: %s", event_type)
    else:
        logger.info("Verified Razorpay webhook received an event: %s", event_type)

    return {"status": "received", "event": event_type}
