from pydantic import BaseModel, Field


class DeviceRegistrationRequest(BaseModel):
    token: str = Field(min_length=1, max_length=4096)
    platform: str = Field(default="unknown", max_length=30)
    enabled: bool = True