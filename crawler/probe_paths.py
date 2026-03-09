import requests, re, json

s = requests.Session()
headers = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "Accept": "application/json, text/plain, */*",
    "Accept-Language": "zh-TW,zh;q=0.9,en-US;q=0.8",
    "Referer": "https://www.sasa.com.hk/v2/official/SalePageCategory/5886?sortMode=PageView",
    "Origin": "https://www.sasa.com.hk",
    "X-Requested-With": "XMLHttpRequest",
}

# clientApiHost is "/" meaning all calls go through www.sasa.com.hk as a proxy
# Try common 91app category product listing paths via Sasa domain
base = "https://www.sasa.com.hk"
paths = [
    # Common webapi paths
    "/webapi/shops/17/sale-page-categories/5886/sale-pages?page=1&pageSize=20&sortMode=PageView",
    "/api/shops/17/sale-page-categories/5886/sale-pages?page=1&pageSize=20",
    "/webapi/shops/17/categories/5886/products?page=1&pageSize=20",
    # 91app CDN API format  
    "/api/v1/shops/17/sale-page-categories/5886/sale-pages?page=1&pageSize=20",
    "/api/v2/shops/17/sale-page-categories/5886/sale-pages?page=1&pageSize=20",
]

for path in paths:
    url = base + path
    r = s.get(url, headers=headers, timeout=10)
    ct = r.headers.get("content-type", "")
    print(f"\n{path}")
    print(f"  Status: {r.status_code}, CT: {ct[:60]}")
    if r.status_code == 200:
        print(f"  Body: {r.text[:300]}")

# Also try webapi.91app.hk directly with Sasa referer
print("\n\n--- webapi.91app.hk direct ---")
wapi_headers = {**headers, "Referer": "https://www.sasa.com.hk/"}
wapi_urls = [
    "https://webapi.91app.hk/shops/17/sale-page-categories/5886/sale-pages?page=1&pageSize=20&sortMode=PageView",
    "https://webapi.91app.hk/v2/shops/17/sale-page-categories/5886/sale-pages?page=1&pageSize=20",
    "https://webapi.91app.hk/Catalog/v1/shops/17/categories/5886/products?page=1&pageSize=20",
]
for url in wapi_urls:
    r = s.get(url, headers=wapi_headers, timeout=10)
    print(f"\n{url}")
    print(f"  Status: {r.status_code}, Body: {r.text[:200]}")
