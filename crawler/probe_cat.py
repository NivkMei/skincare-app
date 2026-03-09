import requests, json

s = requests.Session()
base_headers = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "Accept": "application/json, text/plain, */*",
    "Accept-Language": "zh-HK,zh;q=0.9,en-US;q=0.8",
    "Referer": "https://www.sasa.com.hk/v2/official/SalePageCategory/5886?sortMode=PageView",
    "Origin": "https://www.sasa.com.hk",
}

SHOP_ID = 17
CAT_ID = 5886

# From JS analysis:
# e9(path, stream, isCDN) builds URLs:
# - CDN: https://webapi.91app.hk/{path}
# - non-CDN (client): /{path} → proxied via www.sasa.com.hk
# ftsHostTemp: https://fts-api.91app.hk
# ftsHost: https://apigw.91app.hk/cms/v1

endpoints = [
    # Via Sasa domain proxy (clientApiHost="/")
    f"https://www.sasa.com.hk/SalePageV2/GetSalePageListByShopCategoryId/{SHOP_ID}/{CAT_ID}?page=1&pageSize=20&orderBy=PageView",
    f"https://www.sasa.com.hk/Catalog/GetSalePageListByShopCategoryId/{SHOP_ID}/{CAT_ID}?page=1&pageSize=20",
    f"https://www.sasa.com.hk/ShopCategory/GetSalePageList/{SHOP_ID}/{CAT_ID}?page=1&pageSize=20",
    # Via webapi.91app.hk CDN (cdnApiHost)
    f"https://webapi.91app.hk/SalePageV2/GetSalePageListByShopCategoryId/{SHOP_ID}/{CAT_ID}?page=1&pageSize=20&orderBy=PageView",
    f"https://webapi.91app.hk/Catalog/GetSalePageListByShopCategoryId/{SHOP_ID}/{CAT_ID}?page=1&pageSize=20",
    # Via fts-api.91app.hk
    f"https://fts-api.91app.hk/salepage-listing/api/mweb/category/{SHOP_ID}?categoryId={CAT_ID}&lang=zh-HK&page=1&pageSize=20",
    f"https://fts-api.91app.hk/salepage-listing/api/category-listing/{SHOP_ID}?categoryId={CAT_ID}&lang=zh-HK&page=1&pageSize=20",
    f"https://fts-api.91app.hk/salepage-listing/api/salepage-list/{SHOP_ID}?categoryId={CAT_ID}&lang=zh-HK&page=1&pageSize=20",
    f"https://fts-api.91app.hk/bff/salepage-listing/{SHOP_ID}/category/{CAT_ID}?lang=zh-HK&page=1&pageSize=20",
]

for url in endpoints:
    try:
        r = s.get(url, headers=base_headers, timeout=10)
        ct = r.headers.get("content-type", "")
        print(f"\n{url}")
        print(f"  Status: {r.status_code}, CT: {ct[:50]}")
        if r.status_code < 400:
            body = r.text[:400]
            print(f"  Body: {body}")
    except Exception as e:
        print(f"\n{url}\n  Error: {e}")
