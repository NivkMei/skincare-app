from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional, List


@dataclass
class IngredientDetail:
    name: str
    function: Optional[str] = None
    acne_risk: Optional[int] = None   # 0 (none) – 5 (high)
    irritant: Optional[int] = None    # 0 (none) – 5 (high)
    safety: Optional[int] = None      # 1 (low concern) – 5 (high concern)


@dataclass
class ProductData:
    name: str
    brand: str
    category: str                        # Cleanser / Serum / Moisturizer …
    functionalities: List[str] = field(default_factory=list)
    description: str = ""
    ingredients: List[str] = field(default_factory=list)
    ingredient_details: List[IngredientDetail] = field(default_factory=list)
    image_url: str = ""

    # availability (per-run)
    country_code: str = ""
    store_name: str = ""
    store_type: str = "online"          # 'online' | 'local'
    price: float = 0.0
    currency: str = ""
    source_url: str = ""
