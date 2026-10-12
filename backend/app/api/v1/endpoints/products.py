
from fastapi import APIRouter, HTTPException, Query, Request, status

from app.integrations.woocommerce.client import (
    WooCommerceClient,
    WooCommerceConfigurationError,
    WooCommerceError,
)
from app.schemas.product import ProductListResponse

router = APIRouter(prefix="/products", tags=["Products"])


@router.get("", response_model=ProductListResponse)
async def list_products(
    request: Request,
    page: int = Query(default=1, ge=1),
    per_page: int = Query(default=20, ge=1, le=100),
    search: str | None = Query(
        default=None,
        min_length=1,
        max_length=100,
    ),
) -> ProductListResponse:
    client: WooCommerceClient = request.app.state.woocommerce_client

    try:
        result = await client.get_products(
            page=page,
            per_page=per_page,
            search=search,
        )

        return ProductListResponse(
            **result,
            page=page,
            per_page=per_page,
        )

    except WooCommerceConfigurationError as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="WooCommerce integration is not configured.",
        ) from exc

    except WooCommerceError as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Unable to retrieve products from WooCommerce.",
        ) from exc
