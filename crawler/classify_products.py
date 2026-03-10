"""
classify_products.py
Classifies all products in the DB into proper categories and functionalities
based on keyword matching in Chinese and English product names.
Run: python3 crawler/classify_products.py
"""
import re
import psycopg2
from dotenv import load_dotenv
import os

load_dotenv('crawler/.env')

# ─── Category rules (ordered, first match wins) ────────────────────────────────
# Each rule = (list_of_substrings_in_name, category_label)
# Matching is case-insensitive on the full product name.

CATEGORY_RULES = [
    # ── Makeup removal ────────────────────────────────────────────────────────
    (['卸妝', '卸粧', 'makeup remover', 'cleansing oil', 'cleansing balm',
      'cleansing milk'],                                          'Makeup Remover'),
    # ── Sunscreen ─────────────────────────────────────────────────────────────
    (['防曬', 'spf', 'pa+', 'sunscreen', 'sunblock', 'uv'],     'Sunscreen'),
    # ── Eye masks (before general masks) ──────────────────────────────────────
    (['眼膜'],                                                    'Eye Mask'),
    # ── Lip products ──────────────────────────────────────────────────────────
    (['護唇', '唇膏', '唇膜', 'lip balm', 'lip mask'],           'Lip Care'),
    # ── Face masks (sheet + wash-off + sleeping) ──────────────────────────────
    (['面膜', '睡眠面膜'],                                        'Face Mask'),
    # ── Eye care (before general serums/creams) ───────────────────────────────
    (['眼霜', '眼部精華', '眼精華', '眼部乳霜', 'eye cream', 'eye serum',
      'eye gel', 'eye solution', '眼部配方'],                    'Eye Care'),
    # ── Toner pads / cotton ───────────────────────────────────────────────────
    (['棉片', '棉墊', 'toner pad', 'cotton pad'],                'Toner Pads'),
    # ── Cleansers ─────────────────────────────────────────────────────────────
    (['潔面', '洗面', '洗顏', '潔膚水', '潔膚露', '潔膚乳', '洗面奶',
      'cleanser', 'face wash', 'cleansing foam', 'cleansing gel',
      '潔面巾', '潔面泡沫', '清潔泡沫'],                         'Cleanser'),
    # ── Face / body oils ──────────────────────────────────────────────────────
    (['精油', '清油', '美肌清油', 'face oil', '護膚油'],         'Face Oil'),
    # ── Exfoliators (standalone) ──────────────────────────────────────────────
    (['去角質', '磨砂膏', 'exfoliant', 'peel'],                  'Exfoliator'),
    # ── Toners / essences-lotion (water-like, before serum) ───────────────────
    (['爽膚水', '化妝水', '精華水', '精華化妝水', '精素水',
      '活泉水', '礦泉水', '昇華露', 'softener', 'skin softener',
      'lotion toner', 'preparation lotion'],                     'Toner'),
    # ── Serums / ampoules / essences (concentrate) ────────────────────────────
    (['精華液', '精華露', '安瓶精華', '安瓶', '原液', '原生液',
      '精華', 'serum', 'ampoule', 'essence'],                    'Serum'),
    # ── Emulsions / light lotions ─────────────────────────────────────────────
    (['乳液', 'emulsion', 'lotion'],                              'Lotion'),
    # ── Moisturisers / creams ─────────────────────────────────────────────────
    (['面霜', '乳霜', '凝霜', '日霜', '晚霜', '修護霜', '天才霜',
      '美肌霜', '保濕霜', '乳膏', 'cream', 'moisturizer', 'moisturiser'],
                                                                  'Moisturizer'),
    # ── Scalp care ────────────────────────────────────────────────────────────
    (['頭皮', '育髮', '防脫', 'scalp'],                          'Scalp Care'),
    # ── Body / hand care ──────────────────────────────────────────────────────
    (['身體乳', '護手', '手霜', 'body lotion', 'hand cream',
      'body cream'],                                              'Body Care'),
    # ── Supplements / ingestibles ─────────────────────────────────────────────
    (['益生菌', '口服', '粒裝', 'supplement', 'capsule', 'probiotic'],
                                                                  'Supplement'),
    # ── Mists / sprays ────────────────────────────────────────────────────────
    (['噴霧', '水噴霧', 'mist', 'spray', 'facial spray'],        'Mist'),
    # ── Fallback ──────────────────────────────────────────────────────────────
]

# ─── Functionality rules (multiple per product) ────────────────────────────────
FUNCTIONALITY_RULES = [
    (['保濕', '補濕', '水潤', '水嫩', '水感', '透明質酸', '玻尿酸',
      'hyaluronic', 'hydrating', 'moisturizing', '保水'],        'Hydrating'),
    (['美白', '提亮', '淡斑', '亮白', '煥亮', '嫩白', '美肌', '淡化',
      'brightening', 'whitening', 'radiance', '均勻膚色'],       'Brightening'),
    (['抗老', '抗衰', '抗皺', '逆齡', '再生', '修護', '時空修護',
      'anti-aging', 'anti-ageing', 'anti aging', 'retinol', '視黃醇',
      '維A醇', '膠原', 'collagen', '胜肽', 'peptide'],           'Anti-aging'),
    (['緊緻', '拉提', '塑顏', '提升', '彈力', 'firming', 'lifting',
      'tightening'],                                              'Firming'),
    (['舒緩', '鎮靜', '抗敏', 'soothing', 'calming', 'calming',
      'cica', '積雪草', 'centella', '洋甘菊'],                   'Soothing'),
    (['去角質', '水楊酸', '果酸', '甘醇酸', '乳酸', 'aha', 'bha',
      'salicylic', 'glycolic', 'exfoliat'],                      'Exfoliating'),
    (['防曬', 'spf', 'pa+', 'sun protection', 'uv'],             'SPF Protection'),
    (['毛孔', '去黑頭', '粉刺', 'pore', 'blackhead', 'sebum'],   'Pore Cleansing'),
    (['控油', '抗痘', '去痘', 'oil control', 'oil-free',
      '調脂'],                                                    'Oil Control'),
    (['修護', '修復', '修皮', '肌底修護', 'repairing', 'recovery',
      'barrier', '屏障', '神經醯胺', 'ceramide', 'pdrn'],        'Repairing'),
]


def match_any(name_lower: str, keywords: list[str]) -> bool:
    return any(k.lower() in name_lower for k in keywords)


def classify(name: str) -> tuple[str, list[str]]:
    n = name.lower()

    # Determine category
    category = 'Skincare'
    for keywords, cat in CATEGORY_RULES:
        if match_any(n, keywords):
            category = cat
            break

    # Determine functionalities (can be multiple)
    functionalities = []
    for keywords, func in FUNCTIONALITY_RULES:
        if match_any(n, keywords):
            functionalities.append(func)

    return category, functionalities


def main():
    import sys
    apply = '--apply' in sys.argv

    conn = psycopg2.connect(os.environ['DATABASE_URL'])
    cur = conn.cursor()

    cur.execute('SELECT id, name FROM products ORDER BY id')
    rows = cur.fetchall()
    print(f"Classifying {len(rows)} products...")

    # Preview stats
    cat_counts: dict[str, int] = {}
    updates = []
    for pid, name in rows:
        cat, funcs = classify(name)
        cat_counts[cat] = cat_counts.get(cat, 0) + 1
        updates.append((cat, funcs, pid))

    print("\nCategory distribution:")
    for cat, cnt in sorted(cat_counts.items(), key=lambda x: -x[1]):
        print(f"  {cat}: {cnt}")

    if not apply:
        print("\nDry run — pass --apply to write to database.")
        conn.close()
        return

    cur.executemany(
        "UPDATE products SET category = %s, functionalities = %s WHERE id = %s",
        updates
    )
    conn.commit()
    print(f"\n✅ Updated {len(updates)} products.")
    conn.close()


if __name__ == '__main__':
    main()
