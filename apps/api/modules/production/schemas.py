from pydantic import BaseModel, Field
from typing import Optional, List

# Dough Procedure Steps
class DoughProcedureStepBase(BaseModel):
    step_number: int
    task: str
    description: Optional[str] = None
    equipment: Optional[str] = None
    speed: Optional[str] = None
    time_minutes: int = 0

class DoughProcedureStepCreate(DoughProcedureStepBase):
    pass

class DoughProcedureStepResponse(DoughProcedureStepBase):
    id: int
    class Config:
        from_attributes = True

# Dough Ingredients
class DoughIngredientBase(BaseModel):
    name: str
    qty_per_baston: float
    unit: str = "g"
    mep_type: Optional[str] = None # POLVOS, LIQUIDOS, PRE-FERMENTO
    preferment_id: Optional[int] = None

class DoughIngredientCreate(DoughIngredientBase):
    pass

class DoughIngredientResponse(DoughIngredientBase):
    id: int
    class Config:
        from_attributes = True

# Dough Product Relations
class DoughProductRelationBase(BaseModel):
    product_id: int
    grams_per_piece: float
    pieces_per_baston: Optional[int] = None

class DoughProductRelationCreate(DoughProductRelationBase):
    pass

class DoughProductRelationResponse(DoughProductRelationBase):
    id: int
    class Config:
        from_attributes = True

# Dough Relations (Prefermentos)
class DoughRelationBase(BaseModel):
    related_dough_id: int
    qty_per_baston: float

class DoughRelationCreate(DoughRelationBase):
    pass

class DoughRelationResponse(DoughRelationBase):
    id: int
    class Config:
        from_attributes = True

# Batches (Tandas)
class DoughBatchConfigBase(BaseModel):
    name: str
    baston_qty: float
    unit: str = "BST"

class DoughBatchConfigCreate(DoughBatchConfigBase):
    pass

class DoughBatchConfigResponse(DoughBatchConfigBase):
    id: int
    class Config:
        from_attributes = True

from typing import Dict, Any

class TechnicalSheetBase(BaseModel):
    primary_mass_id: Optional[int] = None
    primary_mass_grams: Optional[float] = None
    
    secondary_mass_id: Optional[int] = None
    secondary_mass_grams: Optional[float] = None
    
    tertiary_mass_id: Optional[int] = None
    tertiary_mass_grams: Optional[float] = None
    
    weight_per_piece: Optional[float] = None
    
    baking_temp_top: Optional[float] = None
    baking_temp_bottom: Optional[float] = None
    baking_time_min: Optional[int] = None
    steam_seconds: Optional[int] = None
    scoring_type: Optional[str] = None
    
    forming_procedure: Optional[str] = None
    bom_extra: Optional[List[Dict[str, Any]]] = None

    preparation_time_min: Optional[int] = None
    order_lead_time_hours: Optional[int] = None  # Tiempo para Pedidos (horas)
    recipe_procedure: Optional[str] = None
    modifiers: Optional[List[Dict[str, Any]]] = None

    provider: Optional[str] = None
    original_barcode: Optional[str] = None
    unit_measure: Optional[str] = None
    min_stock: Optional[int] = None
    max_stock: Optional[int] = None

class TechnicalSheetCreate(TechnicalSheetBase):
    product_id: int

class TechnicalSheetResponse(TechnicalSheetBase):
    id: int
    product_id: int
    class Config:
        from_attributes = True

class DoughReorderRequest(BaseModel):
    order: List[int] # List of Dough IDs in desired order

# Main Dough
class DoughBase(BaseModel):
    code: str
    name: str
    description: Optional[str] = None
    dough_type: str
    requires_rest: bool = False
    rest_container: Optional[str] = None
    rest_warehouse: Optional[str] = None
    rest_time_min: Optional[int] = None
    theoretical_yield: Optional[float] = None
    expected_waste: float = 0.0
    recipe_matrix: Optional[Dict[str, Any]] = None
    production_process: Optional[List[Dict[str, Any]]] = None
    position: int = 0
    theme_id: Optional[str] = None

class DoughCreate(DoughBase):
    ingredients: List[DoughIngredientCreate] = []
    procedure_steps: List[DoughProcedureStepCreate] = []
    product_relations: List[DoughProductRelationCreate] = []
    dough_relations: List[DoughRelationCreate] = []
    batches: List[DoughBatchConfigCreate] = []

class DoughResponse(DoughBase):
    id: int
    ingredients: List[DoughIngredientResponse] = []
    procedure_steps: List[DoughProcedureStepResponse] = []
    product_relations: List[DoughProductRelationResponse] = []
    dough_relations: List[DoughRelationResponse] = []
    batches: List[DoughBatchConfigResponse] = []
    
    class Config:
        from_attributes = True

# Production Equipment
class ProductionEquipmentBase(BaseModel):
    name: str
    model_ref: Optional[str] = None
    serial_number: Optional[str] = None
    description: Optional[str] = None
    nature: str
    image_url: Optional[str] = None
    dynamic_specs: Optional[Dict[str, Any]] = None

class ProductionEquipmentCreate(ProductionEquipmentBase):
    pass

class ProductionEquipmentUpdate(BaseModel):
    name: Optional[str] = None
    model_ref: Optional[str] = None
    serial_number: Optional[str] = None
    description: Optional[str] = None
    nature: Optional[str] = None
    image_url: Optional[str] = None
    dynamic_specs: Optional[Dict[str, Any]] = None

class ProductionEquipmentResponse(ProductionEquipmentBase):
    id: int
    class Config:
        from_attributes = True
