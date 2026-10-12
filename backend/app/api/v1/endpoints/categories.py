
from fastapi import APIRouter, HTTPException, Query, Request, status

from app.integrations.woocommerce.client import (
    WooCommerceClient,
    WooCommerceConfigurationError,
    WooCommerceError,
)
from app.schemas.category import CategoryListResponse

router = APIRouter(prefix="/categories", tags=["Categories"])


@router.get("", response_model=CategoryListResponse)
async def list_categories(
    request: Request,
    page: int = Query(default=1, ge=1),
    per_page: int = Query(default=20, ge=1, le=100),
    search: str | None = Query(
        default=None,
        min_length=1,
        max_length=100,
    ),
    hide_empty: bool = False,
    parent: int | None = Query(default=None, ge=0),
) -> CategoryListResponse:
    client: WooCommerceClient = request.app.state.woocommerce_client

    try:
        result = await client.get_categories(
            page=page,
            per_page=per_page,
            search=search,
            hide_empty=hide_empty,
            parent=parent,
        )

        return CategoryListResponse(
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
            detail="Unable to retrieve categories from WooCommerce.",
        ) from exc
