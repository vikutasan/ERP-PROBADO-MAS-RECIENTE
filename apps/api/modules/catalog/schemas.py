from pydantic import BaseModel, ConfigDict
from typing import Optional, List

# --- Categoria ---
class CategoryBase(BaseModel):
    name: str
    icon: Optional[str] = None
    vision_enabled: bool = False

class CategoryCreate(CategoryBase):
    pass

class CategoryResponse(CategoryBase):
    id: int
    model_config = ConfigDict(from_attributes=True)

# --- Producto ---
class ProductBase(BaseModel):
    sku: str
    barcode: Optional[str] = None
    name: str
    price: float
    category_id: Optional[int] = None
    active: bool = True

class ProductCreate(ProductBase):
    pass

class ProductResponse(ProductBase):
    id: int
    category: Optional[CategoryResponse] = None
    model_config = ConfigDict(from_attributes=True)
