import requests, re

headers = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "Accept": "*/*",
    "Referer": "https://www.sasa.com.hk/",
}

# Fetch the category client module
js_url = "https://cms-static.cdn.91app.hk/lib/cms-theme-core/3.90.0/js/nineyi.themeCore.desktop.category.client.module.js?timestamp=1693903690"
r = requests.get(js_url, headers=headers, timeout=15)
print(f"Status: {r.status_code}, Size: {len(r.text)} chars")
js = r.text

# Search for API path patterns
patterns = [
    r'["\`](/[a-z0-9_\-/]+sale[a-z\-/]+["\`])',
    r'["\`](/[a-z0-9_\-/]+categor[a-z\-/]+["\`])',
    r'["\`](/api[^"\'`]{5,60}["\`])',
    r'["\`](/v\d/[^"\'`]{5,60}["\`])',
    r'sale.page.categor',
    r'SalePage',
    r'category.*product',
]

for pat in patterns:
    matches = re.findall(pat, js, re.IGNORECASE)
    if matches:
        print(f"\nPattern '{pat}' → {matches[:10]}")

# Search for fetch/axios calls
xhr_calls = re.findall(r'(?:get|post|fetch)\(["\`]([^"\'`]{10,120})["\`]', js)
for call in xhr_calls[:20]:
    print(f"  XHR: {call}")

# Find all strings containing "sale-page" or "SalePage"
salepage_strings = re.findall(r'["\`][^"\'`]*[Ss]ale.?[Pp]age[^"\'`]*["\`]', js)
for s in salepage_strings[:30]:
    print(f"  SP: {s}")
