
from contextlib import asynccontextmanager
from typing import AsyncIterator
from app.api.v1.endpoints.categories import router as categories_router
from app.api.v1.endpoints.auth import router as auth_router

from fastapi import FastAPI

from app.api.v1.endpoints.products import router as products_router
from app.core.config import get_settings
from app.integrations.woocommerce.client import WooCommerceClient

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    app.state.woocommerce_client = WooCommerceClient()

    try:
        yield
    finally:
        await app.state.woocommerce_client.close()


app = FastAPI(
    title=settings.app_name,
    version="0.1.0",
    description="Trusted backend for Magna Data AI Ecommerce.",
    lifespan=lifespan,
)


@app.get("/health", tags=["Health"])
def health_check() -> dict[str, str]:
    return {
        "status": "ok",
        "service": "magna-data-backend",
    }


@app.get("/", tags=["Root"])
def root() -> dict[str, str]:
    return {
        "message": "Magna Data AI Ecommerce API",
        "docs": "/docs",
    }

app.include_router(
    products_router,
    prefix=settings.api_v1_prefix,
)

app.include_router(
    categories_router,
    prefix=settings.api_v1_prefix,
)

app.include_router(
    auth_router,
    prefix=settings.api_v1_prefix,
)