import requests, json

headers = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "Accept": "application/json",
    "Referer": "https://www.sasa.com.hk/",
}

# Try 91app's known product listing API pattern
urls = [
    "https://apigw.91app.hk/cms/v1/shops/17/sale-page-categories/5886/products?page=1&pageSize=20&sortMode=PageView",
    "https://webapi.91app.hk/shops/17/products?categoryId=5886&page=1&pageSize=20",
    "https://apigw.91app.hk/cms/v1/shops/17/products?salepage-category-id=5886&page=1&pageSize=20",
    "https://apigw.91app.hk/cms/v1/shops/17/sale-pages?categoryId=5886&page=1&pageSize=20",
    "https://apigw.91app.hk/bff/v1/shops/17/categories/5886/sale-pages?page=1&pageSize=20",
    "https://apigw.91app.hk/bff/v2/shops/17/sale-page-categories/5886/sale-pages?page=1&pageSize=20",
    "https://www.sasa.com.hk/api/products?categoryId=5886&page=1&pageSize=20",
]

for url in urls:
    try:
        r = requests.get(url, headers=headers, timeout=10)
        print(f"\n{url}")
        print(f"  Status: {r.status_code}")
        if r.status_code == 200 and 'json' in r.headers.get('content-type',''):
            print(f"  Body: {r.text[:500]}")
        elif r.status_code == 200:
            print(f"  Content-Type: {r.headers.get('content-type')}")
            print(f"  Body start: {r.text[:200]}")
    except Exception as e:
        print(f"  Error: {e}")
