from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.fcm_device import FCMDevice
from app.models.user import User
from app.schemas.notification import DeviceRegistrationRequest

router = APIRouter(
    prefix="/notifications",
    tags=["Notifications"],
)


@router.post("/devices/register")
def register_device(
    payload: DeviceRegistrationRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    device = db.scalar(
        select(FCMDevice).where(
            FCMDevice.token == payload.token
        )
    )

    if device is None:
        device = FCMDevice(
            user_id=current_user.id,
            token=payload.token,
            platform=payload.platform,
            enabled=payload.enabled,
        )
        db.add(device)
    else:
        # Update an existing token instead of creating duplicates.
        device.user_id = current_user.id
        device.platform = payload.platform
        device.enabled = payload.enabled

    db.commit()
    db.refresh(device)

    return {
        "message": "Device registration updated successfully.",
        "enabled": device.enabled,
        "platform": device.platform,
    }