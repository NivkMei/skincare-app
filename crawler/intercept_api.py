import asyncio
from playwright.async_api import async_playwright
import json

URL = "https://www.sasa.com.hk/v2/official/SalePageCategory/5886?sortMode=PageView"

captured = []

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context(
            user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
            locale="zh-HK",
        )
        page = await context.new_page()

        # Capture all network requests
        def on_request(request):
            url = request.url
            if any(k in url for k in ["91app", "sasa.com.hk"]) and "product" in url.lower() or \
               any(k in url for k in ["salepage", "SalePage", "category", "catalog", "Catalog"]):
                if ".js" not in url and ".css" not in url and "gtm" not in url and "google" not in url:
                    captured.append({
                        "method": request.method,
                        "url": url,
                        "headers": dict(request.headers),
                    })
                    print(f"[REQ] {request.method} {url}")

        async def on_response(response):
            url = response.url
            if any(k in url for k in ["salepage", "SalePage", "category", "catalog", "fts-api", "webapi"]):
                if ".js" not in url and ".css" not in url and "gtm" not in url:
                    try:
                        body = await response.body()
                        print(f"[RES] {response.status} {url}")
                        print(f"      Body preview: {body[:200]}")
                    except:
                        pass

        page.on("request", on_request)
        page.on("response", on_response)

        print(f"Navigating to {URL}...")
        await page.goto(URL, wait_until="networkidle", timeout=30000)
        
        # Wait a bit for lazy-loaded content
        await page.wait_for_timeout(3000)

        await browser.close()

    print("\n\n=== ALL CAPTURED REQUESTS ===")
    for req in captured:
        print(f"\n{req['method']} {req['url']}")
        # Print relevant headers
        for h in ["authorization", "x-api-key", "x-91app", "x-shop", "Cookie"]:
            if h in req["headers"]:
                print(f"  {h}: {req['headers'][h][:100]}")

asyncio.run(main())
