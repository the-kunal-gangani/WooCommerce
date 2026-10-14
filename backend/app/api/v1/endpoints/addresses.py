
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.address import Address
from app.models.user import User
from app.schemas.address import (
    AddressCreate,
    AddressListResponse,
    AddressResponse,
    AddressUpdate,
)

router = APIRouter(prefix="/addresses", tags=["Addresses"])


def _get_owned_address(
    db: Session,
    address_id: int,
    user_id: int,
) -> Address:
    address = db.scalar(
        select(Address).where(
            Address.id == address_id,
            Address.user_id == user_id,
        )
    )

    if address is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Address not found.",
        )

    return address


def _set_default(
    db: Session,
    user_id: int,
    address_type: str,
    selected_id: int,
) -> None:
    addresses = db.scalars(
        select(Address).where(
            Address.user_id == user_id,
            Address.address_type == address_type,
        )
    ).all()

    for address in addresses:
        address.is_default = address.id == selected_id


@router.get("", response_model=AddressListResponse)
def list_addresses(
    address_type: str | None = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> AddressListResponse:
    query = select(Address).where(Address.user_id == current_user.id)

    if address_type is not None:
        if address_type not in ("shipping", "billing"):
            raise HTTPException(
                status_code=422,
                detail="address_type must be shipping or billing.",
            )
        query = query.where(Address.address_type == address_type)

    addresses = db.scalars(
        query.order_by(Address.is_default.desc(), Address.updated_at.desc())
    ).all()

    return AddressListResponse(items=addresses, total=len(addresses))


@router.post(
    "",
    response_model=AddressResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_address(
    payload: AddressCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Address:
    address = Address(
        user_id=current_user.id,
        **payload.model_dump(),
    )

    db.add(address)
    db.flush()

    existing_count = db.scalar(
        select(Address.id)
        .where(
            Address.user_id == current_user.id,
            Address.address_type == address.address_type,
            Address.id != address.id,
        )
        .limit(1)
    )

    if payload.is_default or existing_count is None:
        _set_default(
            db,
            current_user.id,
            address.address_type,
            address.id,
        )

    db.commit()
    db.refresh(address)
    return address


@router.get("/{address_id}", response_model=AddressResponse)
def get_address(
    address_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Address:
    return _get_owned_address(db, address_id, current_user.id)


@router.patch("/{address_id}", response_model=AddressResponse)
def update_address(
    address_id: int,
    payload: AddressUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Address:
    address = _get_owned_address(db, address_id, current_user.id)
    changes = payload.model_dump(exclude_unset=True)

    new_type = changes.get("address_type", address.address_type)
    wants_default = changes.pop("is_default", None)

    for field, value in changes.items():
        setattr(address, field, value)

    if new_type != address.address_type or wants_default is True:
        db.flush()
        _set_default(db, current_user.id, new_type, address.id)

    elif wants_default is False and address.is_default:
        # A user may unset a default; if other addresses exist,
        # select one of them to preserve the default invariant.
        address.is_default = False
        replacement = db.scalar(
            select(Address)
            .where(
                Address.user_id == current_user.id,
                Address.address_type == address.address_type,
                Address.id != address.id,
            )
            .order_by(Address.created_at.asc())
            .limit(1)
        )
        if replacement is not None:
            replacement.is_default = True

    db.commit()
    db.refresh(address)
    return address


@router.delete("/{address_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_address(
    address_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> None:
    address = _get_owned_address(db, address_id, current_user.id)
    was_default = address.is_default
    address_type = address.address_type

    db.delete(address)
    db.flush()

    if was_default:
        replacement = db.scalar(
            select(Address)
            .where(
                Address.user_id == current_user.id,
                Address.address_type == address_type,
            )
            .order_by(Address.created_at.asc())
            .limit(1)
        )
        if replacement is not None:
            replacement.is_default = True

    db.commit()


@router.put("/{address_id}/default", response_model=AddressResponse)
def set_default_address(
    address_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Address:
    address = _get_owned_address(db, address_id, current_user.id)

    _set_default(
        db,
        current_user.id,
        address.address_type,
        address.id,
    )

    db.commit()
    db.refresh(address)
    return address
