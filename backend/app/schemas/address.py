
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator


AddressType = Literal["shipping", "billing"]


class AddressBase(BaseModel):
    label: str = Field(default="Home", min_length=1, max_length=50)
    address_type: AddressType

    first_name: str = Field(min_length=1, max_length=100)
    last_name: str = Field(default="", max_length=100)
    company: str | None = Field(default=None, max_length=150)
    phone: str = Field(min_length=1, max_length=30)

    address1: str = Field(min_length=1, max_length=255)
    address2: str | None = Field(default=None, max_length=255)
    city: str = Field(min_length=1, max_length=100)
    state: str = Field(min_length=1, max_length=100)
    postcode: str = Field(min_length=1, max_length=20)
    country: str = Field(default="IN", min_length=2, max_length=2)

    @field_validator(
        "label",
        "first_name",
        "last_name",
        "phone",
        "address1",
        "city",
        "state",
        "postcode",
        mode="before",
    )
    @classmethod
    def strip_required_strings(cls, value):
        if isinstance(value, str):
            return value.strip()
        return value

    @field_validator("company", "address2", mode="before")
    @classmethod
    def normalize_optional_strings(cls, value):
        if isinstance(value, str):
            value = value.strip()
            return value or None
        return value

    @field_validator("country")
    @classmethod
    def normalize_country(cls, value: str) -> str:
        return value.strip().upper()


class AddressCreate(AddressBase):
    is_default: bool = False


class AddressUpdate(BaseModel):
    label: str | None = Field(default=None, min_length=1, max_length=50)
    address_type: AddressType | None = None

    first_name: str | None = Field(default=None, min_length=1, max_length=100)
    last_name: str | None = Field(default=None, max_length=100)
    company: str | None = Field(default=None, max_length=150)
    phone: str | None = Field(default=None, min_length=1, max_length=30)

    address1: str | None = Field(default=None, min_length=1, max_length=255)
    address2: str | None = Field(default=None, max_length=255)
    city: str | None = Field(default=None, min_length=1, max_length=100)
    state: str | None = Field(default=None, min_length=1, max_length=100)
    postcode: str | None = Field(default=None, min_length=1, max_length=20)
    country: str | None = Field(default=None, min_length=2, max_length=2)
    is_default: bool | None = None

    @field_validator(
        "label",
        "first_name",
        "last_name",
        "phone",
        "address1",
        "city",
        "state",
        "postcode",
        mode="before",
    )
    @classmethod
    def strip_updated_strings(cls, value):
        if isinstance(value, str):
            return value.strip()
        return value

    @field_validator("company", "address2", mode="before")
    @classmethod
    def normalize_updated_optional_strings(cls, value):
        if isinstance(value, str):
            value = value.strip()
            return value or None
        return value

    @field_validator("country")
    @classmethod
    def normalize_updated_country(cls, value):
        if value is not None:
            return value.strip().upper()
        return value


class AddressResponse(AddressBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    is_default: bool
    created_at: datetime
    updated_at: datetime


class AddressListResponse(BaseModel):
    items: list[AddressResponse]
    total: int
