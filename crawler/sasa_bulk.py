"""
Sasa HK Bulk Scraper - Uses 91app GraphQL API
Discovered endpoint: https://apigw.91app.hk/pythia-cdn/graphql
No auth required (CDN-cached public endpoint)
"""
from __future__ import annotations
import os
import sys
import time
import random
import requests
import json
from urllib.parse import urlencode
from dotenv import load_dotenv

load_dotenv()

GRAPHQL_URL = "https://apigw.91app.hk/pythia-cdn/graphql"
SHOP_ID = 17
CATEGORY_ID = 5886
FETCH_COUNT = 100  # products per page

GRAPHQL_QUERY = """
query cms_shopCategory($shopId: Int!, $categoryId: Int!, $startIndex: Int!, $fetchCount: Int!, $orderBy: String, $isShowCurator: Boolean, $locationId: Int, $tagFilters: [ItemTagFilter], $tagShowMore: Boolean, $serviceType: String, $minPrice: Float, $maxPrice: Float, $payType: [String], $shippingType: [String], $includeSalePageGroup: Boolean) {
  shopCategory(shopId: $shopId, categoryId: $categoryId) {
    salePageList(startIndex: $startIndex, maxCount: $fetchCount, orderBy: $orderBy, isCuratorable: $isShowCurator, locationId: $locationId, tagFilters: $tagFilters, tagShowMore: $tagShowMore, minPrice: $minPrice, maxPrice: $maxPrice, payType: $payType, shippingType: $shippingType, serviceType: $serviceType, includeSalePageGroup: $includeSalePageGroup) {
      salePageList {
        salePageId
        title
        picUrl
        salePageCode
        price
        suggestPrice
        isSoldOut
        isComingSoon
        __typename
      }
      totalSize
      shopCategoryId
      shopCategoryName
      __typename
    }
    __typename
  }
}
"""

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "Accept": "application/json",
    "Accept-Language": "zh-HK,zh;q=0.9,en-US;q=0.8",
    "Referer": "https://www.sasa.com.hk/v2/official/SalePageCategory/5886?sortMode=PageView",
    "Origin": "https://www.sasa.com.hk",
}


def fetch_page(start_index: int, order_by: str = "PageView", lang: str = "en") -> dict:
    variables = {
        "shopId": SHOP_ID,
        "categoryId": CATEGORY_ID,
        "startIndex": start_index,
        "fetchCount": FETCH_COUNT,
        "orderBy": order_by,
        "isShowCurator": False,
        "tagFilters": [],
        "tagShowMore": False,
        "minPrice": None,
        "maxPrice": None,
        "payType": [],
        "shippingType": [],
        "includeSalePageGroup": False,
        "locationId": None,
    }
    params = {
        "shopId": SHOP_ID,
        "lang": lang,
        "query": GRAPHQL_QUERY,
        "operationName": "cms_shopCategory",
        "variables": json.dumps(variables, separators=(",", ":")),
    }
    r = requests.get(GRAPHQL_URL, params=params, headers=HEADERS, timeout=20)
    r.raise_for_status()
    return r.json()


def parse_products(data: dict) -> list[dict]:
    try:
        sale_page_list = data["data"]["shopCategory"]["salePageList"]["salePageList"]
        return sale_page_list
    except (KeyError, TypeError) as e:
        print(f"  Warning: Could not parse products: {e}")
        return []


def get_total_size(data: dict) -> int:
    try:
        return data["data"]["shopCategory"]["salePageList"]["totalSize"]
    except (KeyError, TypeError):
        return 0


def scrape_all_products(order_by: str = "PageView", dry_run: bool = False, lang: str = "en") -> list[dict]:
    print(f"Fetching first page (startIndex=0, lang={lang})...")
    data = fetch_page(0, order_by, lang=lang)
    total = get_total_size(data)
    products = parse_products(data)
    print(f"  Total products in category: {total}")
    print(f"  Got {len(products)} products from first page")

    if dry_run:
        print("\n[DRY RUN] First 5 products:")
        for p in products[:5]:
            print(f"  - [{p['salePageId']}] {p['title'][:60]} | HKD {p['price']} | Code: {p['salePageCode']}")
        return products

    all_products = list(products)
    start = FETCH_COUNT
    while start < total:
        print(f"  Fetching startIndex={start}/{total}...")
        delay = random.uniform(1.5, 3.0)
        time.sleep(delay)
        try:
            data = fetch_page(start, order_by, lang=lang)
            page_products = parse_products(data)
            all_products.extend(page_products)
            print(f"    Got {len(page_products)} → total so far: {len(all_products)}")
            start += FETCH_COUNT
        except Exception as e:
            print(f"  Error at startIndex={start}: {e}")
            print("  Retrying in 5s...")
            time.sleep(5)
            try:
                data = fetch_page(start, order_by, lang=lang)
                page_products = parse_products(data)
                all_products.extend(page_products)
                start += FETCH_COUNT
            except Exception as e2:
                print(f"  Retry failed: {e2}. Skipping page.")
                start += FETCH_COUNT

    print(f"\nTotal products scraped: {len(all_products)}")
    return all_products


def scrape_bilingual(order_by: str = "PageView") -> list[dict]:
    """Fetch both English and Chinese product lists and merge by salePageId.
    Returns list of dicts with extra 'title_zh' key alongside English 'title'.
    """
    print("=== Fetching English product list ===")
    en_products = scrape_all_products(order_by=order_by, lang="en")
    print()
    print("=== Fetching Chinese product list ===")
    zh_products = scrape_all_products(order_by=order_by, lang="zh-HK")

    zh_by_id = {p["salePageId"]: p["title"] for p in zh_products}

    merged = []
    for p in en_products:
        p["title_zh"] = zh_by_id.get(p["salePageId"], "")
        merged.append(p)
    print(f"\nMerged {len(merged)} bilingual products.")
    return merged


def extract_brand(title: str) -> str:
    """Try to extract brand from product title (first word/phrase before space)."""
    # Known brands where the brand name is multi-word
    KNOWN_BRANDS = [
        "Estee Lauder", "SK-II", "The Ordinary", "La Roche-Posay",
        "Drunk Elephant", "Paula's Choice", "Dr. Dennis Gross",
        "Tatcha", "Sunday Riley", "First Aid Beauty", "Peter Thomas Roth",
        "Kate Somerville", "Kiehl's", "Biotherm", "La Mer",
        "Shiseido", "Sulwhasoo", "Laneige", "Innisfree", "Cosrx",
        "Some By Mi", "Dr. Jart+", "TONYMOLY", "Etude House",
        "Neogen", "Klairs", "Mediheal", "SNP", "Missha",
        "CeraVe", "Neutrogena", "Olay", "L'Oreal", "Garnier",
        "Bioderma", "Avene", "Caudalie", "Clarins", "Clinique",
        "Origins", "DKNY", "Elemis", "Murad", "Dermalogica",
        "NARS", "Urban Decay", "Charlotte Tilbury", "Bobbi Brown",
        "MAC", "Lancome", "Givenchy", "YSL", "Dior", "Chanel",
        "Neogence", "Hada Labo", "Kose", "Rohto", "Mentholatum",
        "NMF", "EVE LOM", "REN", "PIXI", "COSRX",
    ]
    title_lower = title.lower()
    for brand in KNOWN_BRANDS:
        if title_lower.startswith(brand.lower()):
            return brand
    # Fall back to first word
    parts = title.split()
    return parts[0] if parts else "Unknown"


def save_to_db(products: list[dict], verbose: bool = False) -> None:
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    from db.upsert import upsert_product
    from models.product import ProductData

    saved = 0
    skipped = 0
    errors = 0
    for p in products:
        sale_page_id = p.get("salePageId")
        title = p.get("title", "Unknown")
        price = p.get("price")
        sale_page_code = p.get("salePageCode")
        pic_url = p.get("picUrl", "")
        if pic_url.startswith("//"):
            pic_url = "https:" + pic_url
        is_sold_out = p.get("isSoldOut", False)

        if not title or price is None:
            skipped += 1
            continue

        product_url = f"https://www.sasa.com.hk/SalePage/Index/{sale_page_code or sale_page_id}"
        brand = extract_brand(title)

        title_zh = p.get("title_zh", "")

        product_data = ProductData(
            name=title,        # English name
            name_zh=title_zh,  # Chinese name
            brand=brand,
            category="skincare",
            image_url=pic_url,
            source_url=product_url,
            country_code="HK",
            store_name="Sasa",
            store_type="online",
            price=float(price),
            currency="HKD",
        )
        try:
            result = upsert_product(product_data, verbose=verbose)
            if result:
                saved += 1
                if saved % 100 == 0:
                    print(f"  Saved {saved} products so far...")
        except Exception as e:
            if verbose:
                print(f"  DB error for '{title[:40]}': {e}")
            errors += 1
            if errors > 20:
                print("  Too many errors, stopping.")
                break

    print(f"\nDB Results: saved={saved}, skipped={skipped}, errors={errors}")


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Sasa HK Bulk Scraper")
    parser.add_argument("--dry-run", action="store_true", help="Fetch first page only, no DB save")
    parser.add_argument("--order-by", default="PageView", help="Sort order (PageView, Price, etc.)")
    parser.add_argument("--no-db", action="store_true", help="Scrape all but don't save to DB")
    args = parser.parse_args()

    if args.dry_run:
        scrape_all_products(order_by=args.order_by, dry_run=True)
    elif args.no_db:
        products = scrape_bilingual(order_by=args.order_by)
        print(f"\nScraped {len(products)} products (no DB save). Sample:")
        for p in products[:10]:
            print(f"  [{p['salePageId']}] {p['title'][:60]} | HKD {p['price']}")
    else:
        products = scrape_bilingual(order_by=args.order_by)
        print("\nSaving to Railway DB...")
        save_to_db(products)
