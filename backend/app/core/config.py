
from functools import lru_cache

from pydantic import Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "Magna Data AI Ecommerce API"
    app_env: str = "development"
    api_v1_prefix: str = "/api/v1"
    
    # Invoice email configuration
    smtp_host: str = ""
    smtp_port: int = Field(default=587, gt=0, le=65535)
    smtp_username: str = ""
    smtp_password: SecretStr = SecretStr("")
    smtp_from_email: str = ""
    smtp_starttls: bool = True


    # WooCommerce credentials must remain on the backend.
    woocommerce_base_url: str = "https://serverboat.com"
    woocommerce_consumer_key: SecretStr = SecretStr("")
    woocommerce_consumer_secret: SecretStr = SecretStr("")

    # Configure these before implementing authentication.
    jwt_secret_key: SecretStr = SecretStr("")
    database_url: SecretStr = SecretStr("")

    request_timeout_seconds: float = Field(default=20.0, gt=0, le=120)

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )
    access_token_expire_minutes: int = Field(
        default=15,
        gt=0,
        le=1440,
    )
    
    # Razorpay payment gateway
    razorpay_key_id: str = ""
    razorpay_key_secret: SecretStr = SecretStr("")
    razorpay_webhook_secret: SecretStr = SecretStr("")


@lru_cache
def get_settings() -> Settings:
    return Settings()
