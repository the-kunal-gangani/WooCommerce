
import jwt

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.db.session import get_db
from app.models.user import User

bearer_scheme = HTTPBearer(auto_error=False)


def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    db: Session = Depends(get_db),
) -> User:
    unauthorized = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid or expired access token.",
        headers={"WWW-Authenticate": "Bearer"},
    )

    if credentials is None:
        raise unauthorized

    settings = get_settings()
    secret = settings.jwt_secret_key.get_secret_value()

    if not secret:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Authentication is not configured.",
        )

    try:
        payload = jwt.decode(
            credentials.credentials,
            secret,
            algorithms=["HS256"],
        )

        if payload.get("type") != "access":
            raise unauthorized

        subject = payload.get("sub")
        if not isinstance(subject, str) or not subject.isdigit():
            raise unauthorized

        user_id = int(subject)

    except (jwt.InvalidTokenError, ValueError):
        raise unauthorized from None

    user = db.scalar(select(User).where(User.id == user_id))

    if user is None or not user.is_active:
        raise unauthorized

    return user
