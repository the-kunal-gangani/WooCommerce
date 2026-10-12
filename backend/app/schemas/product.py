
from pydantic import BaseModel, ConfigDict, Field


class ProductImage(BaseModel):
    model_config = ConfigDict(extra="ignore")

    id: int | None = None
    src: str | None = None
    alt: str | None = None
    name: str | None = None


class ProductCategoryRef(BaseModel):
    model_config = ConfigDict(extra="ignore")

    id: int
    name: str
    slug: str | None = None


class ProductResponse(BaseModel):
    model_config = ConfigDict(extra="ignore")

    id: int
    name: str
    slug: str | None = None
    type: str | None = None
    status: str | None = None

    permalink: str | None = None
    description: str | None = None
    short_description: str | None = None

    price: str | None = None
    regular_price: str | None = None
    sale_price: str | None = None
    on_sale: bool = False
    purchasable: bool = False

    stock_status: str | None = None

    images: list[ProductImage] = Field(default_factory=list)
    categories: list[ProductCategoryRef] = Field(default_factory=list)


class ProductListResponse(BaseModel):
    items: list[ProductResponse]
    total: int
    total_pages: int
    page: int
    per_page: int
