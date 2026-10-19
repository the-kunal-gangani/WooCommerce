
from typing import Any

import httpx

from app.core.config import get_settings


class WooCommerceError(Exception):
    """Raised when WooCommerce cannot fulfill a backend request."""


class WooCommerceConfigurationError(WooCommerceError):
    """Raised when the WooCommerce integration is not configured."""


class WooCommerceClient:
    """Server-side client for the WooCommerce REST API v3."""

    def __init__(self) -> None:
        settings = get_settings()

        self._base_url = settings.woocommerce_base_url.rstrip("/")
        self._consumer_key = (
            settings.woocommerce_consumer_key.get_secret_value()
        )
        self._consumer_secret = (
            settings.woocommerce_consumer_secret.get_secret_value()
        )
        self._timeout = settings.request_timeout_seconds

        if not self._base_url.startswith("https://"):
            raise WooCommerceConfigurationError(
                "WooCommerce must be configured with an HTTPS URL."
            )

        self._configured = bool(
            self._consumer_key and self._consumer_secret
        )

        # Basic authentication is sent only from the backend to WooCommerce.
        auth = (
            (self._consumer_key, self._consumer_secret)
            if self._configured
            else None
        )

        self._client = httpx.AsyncClient(
            base_url=f"{self._base_url}/wp-json/wc/v3/",
            auth=auth,
            timeout=httpx.Timeout(self._timeout),
            headers={"Accept": "application/json"},
            follow_redirects=False,
        )

    async def close(self) -> None:
        await self._client.aclose()
        
        
    async def get_categories(
        self,
        *,
        page: int = 1,
        per_page: int = 20,
        search: str | None = None,
        hide_empty: bool = False,
        parent: int | None = None,
    ) -> dict[str, Any]:
        """Retrieve paginated product categories from WooCommerce."""

        if not self._configured:
            raise WooCommerceConfigurationError(
                "WooCommerce credentials are not configured."
            )

        params: dict[str, Any] = {
            "page": page,
            "per_page": per_page,
            "hide_empty": hide_empty,
        }

        if search:
            params["search"] = search

        if parent is not None:
            params["parent"] = parent

        try:
            response = await self._client.get(
                "products/categories",
                params=params,
            )
            response.raise_for_status()

        except httpx.TimeoutException as exc:
            raise WooCommerceError(
                "WooCommerce request timed out."
            ) from exc

        except httpx.HTTPStatusError as exc:
            raise WooCommerceError(
                "WooCommerce returned an unsuccessful response."
            ) from exc

        except httpx.RequestError as exc:
            raise WooCommerceError(
                "Unable to connect to WooCommerce."
            ) from exc

        try:
            categories = response.json()
        except ValueError as exc:
            raise WooCommerceError(
                "WooCommerce returned an invalid response."
            ) from exc

        if not isinstance(categories, list):
            raise WooCommerceError(
                "WooCommerce returned an unexpected response format."
            )

        try:
            total = int(response.headers.get("X-WC-Total", "0"))
            total_pages = int(
                response.headers.get("X-WC-TotalPages", "0")
            )
        except ValueError as exc:
            raise WooCommerceError(
                "WooCommerce returned invalid pagination metadata."
            ) from exc

        return {
            "items": categories,
            "total": total,
            "total_pages": total_pages,
        }


    async def get_products(
        self,
        *,
        page: int = 1,
        per_page: int = 20,
        search: str | None = None,
    ) -> dict[str, Any]:
        """Retrieve a paginated product list from WooCommerce."""

        if not self._configured:
            raise WooCommerceConfigurationError(
                "WooCommerce credentials are not configured on the backend."
            )

        params: dict[str, Any] = {
            "page": page,
            "per_page": per_page,
        }

        if search:
            params["search"] = search

        try:
            response = await self._client.get(
                "products",
                params=params,
            )
            response.raise_for_status()

        except httpx.TimeoutException as exc:
            raise WooCommerceError(
                "WooCommerce request timed out."
            ) from exc

        except httpx.HTTPStatusError as exc:
            # Never return upstream response details or credentials to Flutter.
            raise WooCommerceError(
                "WooCommerce returned an unsuccessful response."
            ) from exc

        except httpx.RequestError as exc:
            raise WooCommerceError(
                "Unable to connect to WooCommerce."
            ) from exc

        try:
            products = response.json()
        except ValueError as exc:
            raise WooCommerceError(
                "WooCommerce returned an invalid response."
            ) from exc

        if not isinstance(products, list):
            raise WooCommerceError(
                "WooCommerce returned an unexpected response format."
            )

        try:
            total = int(response.headers.get("X-WC-Total", "0"))
            total_pages = int(
                response.headers.get("X-WC-TotalPages", "0")
            )
        except ValueError as exc:
            raise WooCommerceError(
                "WooCommerce returned invalid pagination metadata."
            ) from exc

        return {
            "items": products,
            "total": total,
            "total_pages": total_pages,
        }
    
    async def _request_json(
        self,
        method: str,
        endpoint: str,
        *,
        payload: dict[str, Any] | None = None,
    ) -> Any:
        """Make a safe, authenticated WooCommerce REST API request."""

        if not self._configured:
            raise WooCommerceConfigurationError(
                "WooCommerce credentials are not configured."
            )

        try:
            response = await self._client.request(
                method,
                endpoint,
                json=payload,
            )
            response.raise_for_status()

        except httpx.TimeoutException as exc:
            raise WooCommerceError(
                "WooCommerce request timed out."
            ) from exc

        except httpx.HTTPStatusError as exc:
            raise WooCommerceError(
                "WooCommerce returned an unsuccessful response."
            ) from exc

        except httpx.RequestError as exc:
            raise WooCommerceError(
                "Unable to connect to WooCommerce."
            ) from exc

        try:
            return response.json()
        except ValueError as exc:
            raise WooCommerceError(
                "WooCommerce returned an invalid response."
            ) from exc

    async def get_product(self, product_id: int) -> dict[str, Any]:
        """Fetch the authoritative product details."""

        result = await self._request_json(
            "GET",
            f"products/{product_id}",
        )

        if not isinstance(result, dict):
            raise WooCommerceError(
                "WooCommerce returned an unexpected product response."
            )

        return result

    async def get_variation(
        self,
        product_id: int,
        variation_id: int,
    ) -> dict[str, Any]:
        """Fetch a variation belonging to a specific product."""

        result = await self._request_json(
            "GET",
            f"products/{product_id}/variations/{variation_id}",
        )

        if not isinstance(result, dict):
            raise WooCommerceError(
                "WooCommerce returned an unexpected variation response."
            )

        return result

    async def create_order(
        self,
        payload: dict[str, Any],
    ) -> dict[str, Any]:
        """Create a WooCommerce order."""

        result = await self._request_json(
            "POST",
            "orders",
            payload=payload,
        )

        if not isinstance(result, dict) or not result.get("id"):
            raise WooCommerceError(
                "WooCommerce did not return a valid order."
            )

        return result

    async def update_order(
        self,
        order_id: int,
        payload: dict[str, Any],
    ) -> dict[str, Any]:
        """Update an existing WooCommerce order."""

        result = await self._request_json(
            "PUT",
            f"orders/{order_id}",
            payload=payload,
        )

        if not isinstance(result, dict) or not result.get("id"):
            raise WooCommerceError(
                "WooCommerce did not return a valid updated order."
            )

        return result
    
    async def get_order(self, order_id: int) -> dict[str, Any]:
        """Fetch an existing WooCommerce order."""
        result = await self._request_json(
            "GET",
            f"orders/{order_id}",
        )
        if not isinstance(result, dict) or not result.get("id"):
            raise WooCommerceError(
                "WooCommerce did not return a valid order."
            )
        return result
