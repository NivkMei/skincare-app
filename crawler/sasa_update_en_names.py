"""
sasa_update_en_names.py
Backfills English product names for all Sasa products already in the DB.

Strategy:
  1. Fetch the full Sasa product list in zh-HK  → {salePageId: zh_title}
  2. Fetch the full Sasa product list in en      → {salePageId: en_title}
  3. Match by salePageId to pair them.
  4. For each pair, find the DB row by (lower(name)=lower(zh_title)) and UPDATE:
       name    = en_title
       name_zh = zh_title      (promote Chinese to name_zh)

Run:
    cd crawler && python3 sasa_update_en_names.py [--dry-run]
"""
from __future__ import annotations
import os
import sys
import time
import random
import argparse
import json
import requests
from dotenv import load_dotenv

load_dotenv()
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from db.connection import get_conn  # noqa: E402

GRAPHQL_URL = "https://apigw.91app.hk/pythia-cdn/graphql"
SHOP_ID = 17
CATEGORY_ID = 5886
FETCH_COUNT = 100

GRAPHQL_QUERY = """
query cms_shopCategory($shopId: Int!, $categoryId: Int!, $startIndex: Int!, $fetchCount: Int!, $orderBy: String, $isShowCurator: Boolean, $locationId: Int, $tagFilters: [ItemTagFilter], $tagShowMore: Boolean, $serviceType: String, $minPrice: Float, $maxPrice: Float, $payType: [String], $shippingType: [String], $includeSalePageGroup: Boolean) {
  shopCategory(shopId: $shopId, categoryId: $categoryId) {
    salePageList(startIndex: $startIndex, maxCount: $fetchCount, orderBy: $orderBy, isCuratorable: $isShowCurator, locationId: $locationId, tagFilters: $tagFilters, tagShowMore: $tagShowMore, minPrice: $minPrice, maxPrice: $maxPrice, payType: $payType, shippingType: $shippingType, serviceType: $serviceType, includeSalePageGroup: $includeSalePageGroup) {
      salePageList {
        salePageId
        title
        salePageCode
        price
        picUrl
        __typename
      }
      totalSize
      __typename
    }
    __typename
  }
}
"""

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
    "Accept": "application/json",
    "Accept-Language": "zh-HK,en;q=0.8",
    "Referer": "https://www.sasa.com.hk/v2/official/SalePageCategory/5886",
    "Origin": "https://www.sasa.com.hk",
}


def fetch_page(start_index: int, lang: str = "zh-HK") -> dict:
    variables = {
        "shopId": SHOP_ID,
        "categoryId": CATEGORY_ID,
        "startIndex": start_index,
        "fetchCount": FETCH_COUNT,
        "orderBy": "PageView",
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


def fetch_all(lang: str) -> dict[int, dict]:
    """Fetch all products for the given lang. Returns {salePageId: row}."""
    print(f"  Fetching lang={lang} page 0…")
    data = fetch_page(0, lang)
    total = data["data"]["shopCategory"]["salePageList"]["totalSize"]
    rows = data["data"]["shopCategory"]["salePageList"]["salePageList"]
    print(f"    Total: {total}, got {len(rows)} from page 0")

    start = FETCH_COUNT
    while start < total:
        time.sleep(random.uniform(1.2, 2.5))
        print(f"  Fetching lang={lang} startIndex={start}/{total}…")
        try:
            data = fetch_page(start, lang)
            page = data["data"]["shopCategory"]["salePageList"]["salePageList"]
            rows.extend(page)
            print(f"    +{len(page)} → {len(rows)} total")
        except Exception as e:
            print(f"  Warning at {start}: {e}. Skipping.")
        start += FETCH_COUNT

    return {r["salePageId"]: r for r in rows}


def update_db(pairs: list[tuple[str, str]], dry_run: bool) -> None:
    """
    pairs = list of (zh_title, en_title)
    Finds DB rows by lower(name)=lower(zh_title) and updates name/name_zh.
    Skips pairs where the en_title already exists (avoids unique constraint
    violations from duplicate products inserted in a prior run).
    """
    import psycopg2

    conn = get_conn()
    updated = 0
    not_found = 0
    skipped_dup = 0
    deleted_dup = 0

    for zh_title, en_title in pairs:
        if dry_run:
            with conn.cursor() as cur:
                cur.execute(
                    "SELECT id FROM products WHERE lower(name) = lower(%s)",
                    (zh_title,),
                )
                row = cur.fetchone()
                if row:
                    print(f"  [DRY] {row['id']}: '{en_title[:55]}'")
                    updated += 1
                else:
                    not_found += 1
            continue

        # Each update in its own savepoint so one failure doesn't roll back all
        with conn.cursor() as cur:
            cur.execute("SAVEPOINT sp_update")
            try:
                cur.execute(
                    """
                    UPDATE products
                    SET name    = %s,
                        name_zh = CASE WHEN name_zh = '' THEN %s ELSE name_zh END
                    WHERE lower(name) = lower(%s)
                    RETURNING id
                    """,
                    (en_title, zh_title, zh_title),
                )
                row = cur.fetchone()
                cur.execute("RELEASE SAVEPOINT sp_update")
                if row:
                    updated += 1
                else:
                    not_found += 1
            except psycopg2.errors.UniqueViolation:
                # English name already exists → the Chinese-name row is a
                # duplicate. Roll back savepoint, delete the zh duplicate.
                cur.execute("ROLLBACK TO SAVEPOINT sp_update")
                cur.execute("RELEASE SAVEPOINT sp_update")
                try:
                    cur.execute(
                        "DELETE FROM products WHERE lower(name) = lower(%s) RETURNING id",
                        (zh_title,),
                    )
                    gone = cur.fetchone()
                    if gone:
                        deleted_dup += 1
                    else:
                        skipped_dup += 1
                except Exception:
                    skipped_dup += 1

    conn.commit()
    print(f"\nUpdated: {updated} | Not found: {not_found} | "
          f"Duplicates deleted: {deleted_dup} | Skipped: {skipped_dup}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true",
                        help="Show what would happen without writing to DB")
    args = parser.parse_args()

    print("=== Step 1: Fetch Chinese (zh-HK) product list ===")
    zh_map = fetch_all("zh-HK")
    print(f"  zh-HK: {len(zh_map)} products\n")

    print("=== Step 2: Fetch English (en) product list ===")
    en_map = fetch_all("en")
    print(f"  en: {len(en_map)} products\n")

    # Match by salePageId
    pairs: list[tuple[str, str]] = []
    unmatched = 0
    for spid, zh_row in zh_map.items():
        en_row = en_map.get(spid)
        if not en_row:
            unmatched += 1
            continue
        zh_title = zh_row["title"].strip()
        en_title = en_row["title"].strip()
        if zh_title and en_title and zh_title != en_title:
            pairs.append((zh_title, en_title))

    print(f"=== Step 3: Matched {len(pairs)} bilingual pairs ({unmatched} unmatched) ===")
    if pairs:
        print("  Sample pairs:")
        for zh, en in pairs[:5]:
            print(f"    ZH: {zh[:60]}")
            print(f"    EN: {en[:60]}")
            print()

    print(f"=== Step 4: {'DRY RUN — ' if args.dry_run else ''}Updating DB ===")
    update_db(pairs, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
