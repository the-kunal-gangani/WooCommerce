
from pydantic import BaseModel, ConfigDict


class CategoryImage(BaseModel):
    model_config = ConfigDict(extra="ignore")

    id: int | None = None
    src: str | None = None
    alt: str | None = None
    name: str | None = None


class CategoryResponse(BaseModel):
    model_config = ConfigDict(extra="ignore")

    id: int
    name: str
    slug: str
    description: str | None = None
    parent: int = 0
    count: int = 0
    image: CategoryImage | None = None


class CategoryListResponse(BaseModel):
    items: list[CategoryResponse]
    total: int
    total_pages: int
    page: int
    per_page: int
