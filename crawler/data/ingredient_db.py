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


# ── Traditional Chinese ingredient name lookup (繁體中文) ──────────────────
# Maps Traditional Chinese names → same IngredientInfo values.
# Enables search and display in Chinese for HK/TW markets.
INGREDIENT_DB_ZH: dict = {
    # Water / Solvents
    "水": IngredientInfo(0, 0),
    "純水": IngredientInfo(0, 0),
    # Humectants
    "甘油": IngredientInfo(0, 0),
    "丙三醇": IngredientInfo(0, 0),
    "透明質酸鈉": IngredientInfo(0, 0),
    "玻尿酸": IngredientInfo(0, 0),
    "泛醇": IngredientInfo(0, 0),
    "尿囊素": IngredientInfo(0, 0),
    "蘆薈": IngredientInfo(0, 0),
    "蘆薈葉汁": IngredientInfo(0, 0),
    "丙二醇": IngredientInfo(0, 1),
    "丁二醇": IngredientInfo(0, 0),
    "戊二醇": IngredientInfo(0, 0),
    "山梨醇": IngredientInfo(0, 0),
    "尿素": IngredientInfo(0, 1),
    "乳酸": IngredientInfo(0, 2),
    "乙醇酸": IngredientInfo(0, 3),
    # Emollients
    "二甲矽油": IngredientInfo(1, 0),
    "環戊矽氧烷": IngredientInfo(0, 0),
    "角鯊烷": IngredientInfo(0, 0),
    "角鯊烯": IngredientInfo(2, 0),
    "荷荷巴籽油": IngredientInfo(0, 0),
    "椰子油": IngredientInfo(4, 0),
    "乳木果油": IngredientInfo(0, 0),
    "凡士林": IngredientInfo(0, 0),
    "礦物油": IngredientInfo(0, 0),
    "菸鹼醯胺": IngredientInfo(0, 0),
    "辛甘醇": IngredientInfo(0, 0),
    # Ceramides
    "神經醯胺NP": IngredientInfo(0, 0),
    "神經醯胺AP": IngredientInfo(0, 0),
    "神經醯胺EOP": IngredientInfo(0, 0),
    "神經醯胺NG": IngredientInfo(0, 0),
    "膽固醇": IngredientInfo(0, 0),
    "植物鞘氨醇": IngredientInfo(0, 0),
    # Emulsifiers / Surfactants
    "鯨蠟硬脂醇": IngredientInfo(2, 0),
    "鯨蠟醇": IngredientInfo(2, 0),
    "硬脂酸": IngredientInfo(3, 0),
    "聚山梨醇酯20": IngredientInfo(0, 0),
    "聚山梨醇酯80": IngredientInfo(0, 1),
    "十二烷基硫酸鈉": IngredientInfo(0, 5),
    "月桂醇聚醚硫酸酯鈉": IngredientInfo(0, 3),
    "椰油醯胺丙基甜菜鹼": IngredientInfo(0, 1),
    # pH adjusters / chelating
    "氫氧化鈉": IngredientInfo(0, 1),
    "檸檬酸": IngredientInfo(0, 1),
    "乙二胺四乙酸二鈉": IngredientInfo(0, 0),
    "乙二胺四乙酸四鈉": IngredientInfo(0, 0),
    # Preservatives
    "苯氧乙醇": IngredientInfo(0, 1),
    "乙基己基甘油": IngredientInfo(0, 0),
    "苯甲醇": IngredientInfo(0, 2),
    "甲基羥基苯甲酸酯": IngredientInfo(0, 0),
    "丙基羥基苯甲酸酯": IngredientInfo(0, 0),
    "氯苯甘醚": IngredientInfo(0, 1),
    # Antioxidants / actives
    "生育酚": IngredientInfo(2, 0),
    "維生素E": IngredientInfo(2, 0),
    "抗壞血酸": IngredientInfo(0, 2),
    "維生素C": IngredientInfo(0, 2),
    "視黃醇": IngredientInfo(0, 3),
    "A醇": IngredientInfo(0, 3),
    "水楊酸": IngredientInfo(0, 2),
    "過氧化苯甲酰": IngredientInfo(0, 4),
    "菸鹼醯胺（維生素B3）": IngredientInfo(0, 0),
    "壬二酸": IngredientInfo(0, 1),
    "曲酸": IngredientInfo(0, 1),
    "氧化鋅": IngredientInfo(0, 0),
    "二氧化鈦": IngredientInfo(0, 0),
    "積雪草苷": IngredientInfo(0, 0),
    "積雪草提取物": IngredientInfo(0, 0),
    "咖啡因": IngredientInfo(0, 0),
    "茶樹油": IngredientInfo(0, 3),
    # Misc
    "香料": IngredientInfo(0, 4),
    "香精": IngredientInfo(0, 4),
    "變性酒精": IngredientInfo(0, 3),
    "酒精": IngredientInfo(0, 3),
    "肉豆蔻酸異丙酯": IngredientInfo(5, 1),
    "棕櫚酸異丙酯": IngredientInfo(4, 0),
    "麥芽糊精": IngredientInfo(0, 0),
    "矽石": IngredientInfo(0, 0),
    "羊毛脂": IngredientInfo(1, 1),
    "卡波姆": IngredientInfo(0, 1),
    "黃原膠": IngredientInfo(0, 0),
    "麥冬根提取物": IngredientInfo(0, 0),
    "月桂醯乳酸鈉": IngredientInfo(0, 0),
}

# Mapping from Traditional Chinese name → canonical English name
# Used by scrapers to normalise zh ingredient names.
ZH_TO_EN: dict[str, str] = {
    "水": "water",
    "純水": "aqua",
    "甘油": "glycerin",
    "丙三醇": "glycerol",
    "透明質酸鈉": "sodium hyaluronate",
    "玻尿酸": "hyaluronic acid",
    "泛醇": "panthenol",
    "尿囊素": "allantoin",
    "蘆薈": "aloe vera",
    "蘆薈葉汁": "aloe barbadensis leaf juice",
    "丙二醇": "propylene glycol",
    "丁二醇": "butylene glycol",
    "戊二醇": "pentylene glycol",
    "山梨醇": "sorbitol",
    "尿素": "urea",
    "乳酸": "lactic acid",
    "乙醇酸": "glycolic acid",
    "二甲矽油": "dimethicone",
    "環戊矽氧烷": "cyclopentasiloxane",
    "角鯊烷": "squalane",
    "角鯊烯": "squalene",
    "荷荷巴籽油": "jojoba seed oil",
    "椰子油": "coconut oil",
    "乳木果油": "shea butter",
    "凡士林": "petrolatum",
    "礦物油": "mineral oil",
    "菸鹼醯胺": "niacinamide",
    "辛甘醇": "caprylyl glycol",
    "神經醯胺NP": "ceramide np",
    "神經醯胺AP": "ceramide ap",
    "神經醯胺EOP": "ceramide eop",
    "神經醯胺NG": "ceramide ng",
    "膽固醇": "cholesterol",
    "植物鞘氨醇": "phytosphingosine",
    "鯨蠟硬脂醇": "cetearyl alcohol",
    "鯨蠟醇": "cetyl alcohol",
    "硬脂酸": "stearic acid",
    "聚山梨醇酯20": "polysorbate 20",
    "聚山梨醇酯80": "polysorbate 80",
    "十二烷基硫酸鈉": "sodium lauryl sulfate",
    "月桂醇聚醚硫酸酯鈉": "sodium laureth sulfate",
    "椰油醯胺丙基甜菜鹼": "cocamidopropyl betaine",
    "氫氧化鈉": "sodium hydroxide",
    "檸檬酸": "citric acid",
    "乙二胺四乙酸二鈉": "disodium edta",
    "乙二胺四乙酸四鈉": "tetrasodium edta",
    "苯氧乙醇": "phenoxyethanol",
    "乙基己基甘油": "ethylhexylglycerin",
    "苯甲醇": "benzyl alcohol",
    "甲基羥基苯甲酸酯": "methylparaben",
    "丙基羥基苯甲酸酯": "propylparaben",
    "氯苯甘醚": "chlorphenesin",
    "生育酚": "tocopherol",
    "維生素E": "tocopherol",
    "抗壞血酸": "ascorbic acid",
    "維生素C": "ascorbic acid",
    "視黃醇": "retinol",
    "A醇": "retinol",
    "水楊酸": "salicylic acid",
    "過氧化苯甲酰": "benzoyl peroxide",
    "壬二酸": "azelaic acid",
    "曲酸": "kojic acid",
    "氧化鋅": "zinc oxide",
    "二氧化鈦": "titanium dioxide",
    "積雪草苷": "madecassoside",
    "積雪草提取物": "centella asiatica extract",
    "咖啡因": "caffeine",
    "茶樹油": "tea tree oil",
    "香料": "fragrance",
    "香精": "parfum",
    "變性酒精": "alcohol denat.",
    "酒精": "alcohol",
    "肉豆蔻酸異丙酯": "isopropyl myristate",
    "棕櫚酸異丙酯": "isopropyl palmitate",
    "麥芽糊精": "maltodextrin",
    "矽石": "silica",
    "羊毛脂": "lanolin",
    "卡波姆": "carbomer",
    "黃原膠": "xanthan gum",
    "麥冬根提取物": "ophiopogon japonicus root extract",
    "月桂醯乳酸鈉": "sodium lauroyl lactylate",
}


def lookup_zh(name: str) -> Optional[IngredientInfo]:
    """Look up an ingredient by Traditional Chinese name."""
    key = name.strip()
    result = INGREDIENT_DB_ZH.get(key)
    if result is None:
        # Fall back to English lookup via ZH_TO_EN mapping
        en_name = ZH_TO_EN.get(key)
        if en_name:
            result = INGREDIENT_DB.get(en_name)
    return result


def zh_to_en_name(zh_name: str) -> Optional[str]:
    """Translate a Traditional Chinese ingredient name to its English INCI name."""
    return ZH_TO_EN.get(zh_name.strip())
