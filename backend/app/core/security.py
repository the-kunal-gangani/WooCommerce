
from datetime import datetime, timedelta, timezone

import jwt
from pwdlib import PasswordHash

from app.core.config import get_settings

password_hash = PasswordHash.recommended()


def hash_password(password: str) -> str:
    """Hash a password using the recommended Argon2 configuration."""
    return password_hash.hash(password)


def verify_password(password: str, hashed_password: str) -> bool:
    """Verify a password against its stored hash."""
    return password_hash.verify(password, hashed_password)


def create_access_token(user_id: int) -> tuple[str, int]:
    """Create a signed JWT access token and return its lifetime in seconds."""
    settings = get_settings()
    secret = settings.jwt_secret_key.get_secret_value()

    if not secret:
        raise RuntimeError("JWT_SECRET_KEY is not configured.")

    expires_in = settings.access_token_expire_minutes * 60
    now = datetime.now(timezone.utc)

    payload = {
        "sub": str(user_id),
        "type": "access",
        "iat": now,
        "exp": now + timedelta(seconds=expires_in),
    }

    token = jwt.encode(payload, secret, algorithm="HS256")
    return token, expires_in
