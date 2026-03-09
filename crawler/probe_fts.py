import requests, json

s = requests.Session()
headers = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "Accept": "application/json, text/plain, */*",
    "Accept-Language": "zh-HK,zh;q=0.9,en-US;q=0.8",
    "Referer": "https://www.sasa.com.hk/v2/official/SalePageCategory/5886?sortMode=PageView",
    "Origin": "https://www.sasa.com.hk",
}

SHOP_ID = 17
CAT_ID = 5886

print("=== Checking 500 endpoint ===")
r = s.get(
    f"https://fts-api.91app.hk/bff/salepage-listing/{SHOP_ID}/category/{CAT_ID}?lang=zh-HK&page=1&pageSize=20",
    headers=headers, timeout=10
)
print(f"Status: {r.status_code}")
print(f"Body: {r.text[:500]}")

print("\n=== Trying variations ===")
variants = [
    f"https://fts-api.91app.hk/salepage-listing/api/category/{SHOP_ID}/{CAT_ID}?lang=zh-HK&page=1&pageSize=20&sortMode=PageView",
    f"https://fts-api.91app.hk/salepage-listing/{SHOP_ID}/category/{CAT_ID}?lang=zh-HK&page=1&pageSize=20",
    f"https://fts-api.91app.hk/salepage-listing/api/web/salepage-list/{SHOP_ID}?categoryId={CAT_ID}&lang=zh-HK&page=1&pageSize=20",
    f"https://fts-api.91app.hk/salepage-listing/api/web/category-list/{SHOP_ID}?categoryId={CAT_ID}&lang=zh-HK&page=1&pageSize=20",
    f"https://fts-api.91app.hk/salepage-listing/api/category-salepage/{SHOP_ID}?categoryId={CAT_ID}&lang=zh-HK&page=1&pageSize=20",
    f"https://fts-api.91app.hk/salepage-listing/api/salepage/{SHOP_ID}/category/{CAT_ID}?lang=zh-HK&page=1&pageSize=20",
    # The 500 with /bff/ - try variants
    f"https://fts-api.91app.hk/bff/salepage-listing/{SHOP_ID}/salepage-list?categoryId={CAT_ID}&lang=zh-HK&page=1&pageSize=20",
    f"https://fts-api.91app.hk/bff/category/{SHOP_ID}/salepage-list?categoryId={CAT_ID}&lang=zh-HK&page=1&pageSize=20",
    f"https://fts-api.91app.hk/bff/salepage-listing/{SHOP_ID}/category/{CAT_ID}/products?lang=zh-HK&page=1&pageSize=20",
    f"https://fts-api.91app.hk/bff/salepage-listing/{SHOP_ID}/category/{CAT_ID}?lang=zh-HK&page=1&pageSize=20&sortMode=PageView",
]

for url in variants:
    try:
        r = s.get(url, headers=headers, timeout=10)
        print(f"\n{url}\n  Status: {r.status_code}")
        if r.status_code < 500:
            print(f"  Body: {r.text[:300]}")
        else:
            print(f"  Body: {r.text[:200]}")
    except Exception as e:
        print(f"\n{url}\n  Error: {e}")
