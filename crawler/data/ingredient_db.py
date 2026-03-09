"""
Compact Python mirror of app/lib/data/ingredient_data.dart.
Used by the CosDNA scraper to fill in Acne Risk and Irritant
when the website doesn't expose them in static HTML.
"""
from typing import Optional, NamedTuple


class IngredientInfo(NamedTuple):
    acne_risk: Optional[int]   # 0 (none) – 5 (high)
    irritant: Optional[int]    # 0 (none) – 5 (high)


# Keys are lowercase, trimmed ingredient names.
INGREDIENT_DB: dict = {
    # Water / Solvents
    "water": IngredientInfo(0, 0),
    "aqua": IngredientInfo(0, 0),
    # Humectants
    "glycerin": IngredientInfo(0, 0),
    "glycerol": IngredientInfo(0, 0),
    "sodium hyaluronate": IngredientInfo(0, 0),
    "hyaluronic acid": IngredientInfo(0, 0),
    "panthenol": IngredientInfo(0, 0),
    "allantoin": IngredientInfo(0, 0),
    "aloe vera": IngredientInfo(0, 0),
    "aloe barbadensis leaf juice": IngredientInfo(0, 0),
    "propylene glycol": IngredientInfo(0, 1),
    "butylene glycol": IngredientInfo(0, 0),
    "pentylene glycol": IngredientInfo(0, 0),
    "sorbitol": IngredientInfo(0, 0),
    "urea": IngredientInfo(0, 1),
    "lactic acid": IngredientInfo(0, 2),
    "glycolic acid": IngredientInfo(0, 3),
    # Emollients
    "dimethicone": IngredientInfo(1, 0),
    "cyclopentasiloxane": IngredientInfo(0, 0),
    "squalane": IngredientInfo(0, 0),
    "squalene": IngredientInfo(2, 0),
    "jojoba seed oil": IngredientInfo(0, 0),
    "coconut oil": IngredientInfo(4, 0),
    "shea butter": IngredientInfo(0, 0),
    "petrolatum": IngredientInfo(0, 0),
    "mineral oil": IngredientInfo(0, 0),
    "niacinamide": IngredientInfo(0, 0),
    "caprylyl glycol": IngredientInfo(0, 0),
    # Ceramides
    "ceramide np": IngredientInfo(0, 0),
    "ceramide ap": IngredientInfo(0, 0),
    "ceramide eop": IngredientInfo(0, 0),
    "ceramide ng": IngredientInfo(0, 0),
    "cholesterol": IngredientInfo(0, 0),
    "phytosphingosine": IngredientInfo(0, 0),
    # Emulsifiers / Surfactants
    "cetearyl alcohol": IngredientInfo(2, 0),
    "cetyl alcohol": IngredientInfo(2, 0),
    "stearic acid": IngredientInfo(3, 0),
    "polysorbate 20": IngredientInfo(0, 0),
    "polysorbate 80": IngredientInfo(0, 1),
    "sodium lauryl sulfate": IngredientInfo(0, 5),
    "sodium laureth sulfate": IngredientInfo(0, 3),
    "cocamidopropyl betaine": IngredientInfo(0, 1),
    # pH adjusters / chelating
    "sodium hydroxide": IngredientInfo(0, 1),
    "citric acid": IngredientInfo(0, 1),
    "disodium edta": IngredientInfo(0, 0),
    "tetrasodium edta": IngredientInfo(0, 0),
    # Preservatives
    "phenoxyethanol": IngredientInfo(0, 1),
    "ethylhexylglycerin": IngredientInfo(0, 0),
    "benzyl alcohol": IngredientInfo(0, 2),
    "methylparaben": IngredientInfo(0, 0),
    "propylparaben": IngredientInfo(0, 0),
    "chlorphenesin": IngredientInfo(0, 1),
    # Antioxidants / actives
    "tocopherol": IngredientInfo(2, 0),
    "ascorbic acid": IngredientInfo(0, 2),
    "retinol": IngredientInfo(0, 3),
    "salicylic acid": IngredientInfo(0, 2),
    "benzoyl peroxide": IngredientInfo(0, 4),
    "niacinamide (vitamin b3)": IngredientInfo(0, 0),
    "azelaic acid": IngredientInfo(0, 1),
    "kojic acid": IngredientInfo(0, 1),
    "zinc oxide": IngredientInfo(0, 0),
    "titanium dioxide": IngredientInfo(0, 0),
    "madecassoside": IngredientInfo(0, 0),
    "centella asiatica extract": IngredientInfo(0, 0),
    "caffeine": IngredientInfo(0, 0),
    "tea tree oil": IngredientInfo(0, 3),
    # Misc
    "fragrance": IngredientInfo(0, 4),
    "parfum": IngredientInfo(0, 4),
    "alcohol denat.": IngredientInfo(0, 3),
    "alcohol": IngredientInfo(0, 3),
    "isopropyl myristate": IngredientInfo(5, 1),
    "isopropyl palmitate": IngredientInfo(4, 0),
    "maltodextrin": IngredientInfo(0, 0),
    "silica": IngredientInfo(0, 0),
    "lanolin": IngredientInfo(1, 1),
    "carbomer": IngredientInfo(0, 1),
    "xanthan gum": IngredientInfo(0, 0),
    "ophiopogon japonicus root extract": IngredientInfo(0, 0),
    "sodium lauroyl lactylate": IngredientInfo(0, 0),
}


def lookup(name: str) -> Optional[IngredientInfo]:
    return INGREDIENT_DB.get(name.lower().strip())
