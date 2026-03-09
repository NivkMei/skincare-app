import requests, re, json

headers = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9,zh-TW;q=0.8",
    "Accept-Encoding": "gzip, deflate, br",
    "Connection": "keep-alive",
    "Upgrade-Insecure-Requests": "1",
}

url = "https://www.sasa.com.hk/v2/official/SalePageCategory/5886?sortMode=PageView"
r = requests.get(url, headers=headers, timeout=15)
print(f"Status: {r.status_code}")
html = r.text

# Look for embedded JSON/initial state
patterns = [
    r'window\.__INITIAL_STATE__\s*=\s*(\{.*?\});',
    r'window\.__PRELOADED_STATE__\s*=\s*(\{.*?\});',
    r'window\.__NEXT_DATA__\s*=\s*(\{.*?\});',
    r'window\.SHOP_ID\s*=\s*(\d+)',
    r'"token"\s*:\s*"([^"]+)"',
    r'"clientToken"\s*:\s*"([^"]+)"',
    r'"accessToken"\s*:\s*"([^"]+)"',
    r'"authorization"\s*:\s*"([^"]+)"',
    r'Authorization["\s:]+([A-Za-z0-9\-._~+/]+=*)',
    r'token["\s:]+([A-Za-z0-9\-._~+/]{20,})',
]

for pat in patterns:
    m = re.search(pat, html, re.DOTALL | re.IGNORECASE)
    if m:
        val = m.group(1)
        print(f"\nPattern: {pat[:50]}")
        print(f"  Value: {val[:200]}")

# Look for fetch/XHR calls in scripts
print("\n--- API calls in scripts ---")
fetch_calls = re.findall(r'fetch\(["\']([^"\']+)["\']', html)
for f in fetch_calls[:20]:
    print(f"  fetch: {f}")

# Look for any apigw references
apigw_refs = re.findall(r'(https?://[^\s"\'<>]+apigw[^\s"\'<>]*)', html)
for ref in apigw_refs[:20]:
    print(f"  apigw: {ref}")

# Look for Authorization or Bearer
bearer = re.findall(r'[Bb]earer\s+([A-Za-z0-9\-._~+/]+=*)', html)
for b in bearer[:5]:
    print(f"  Bearer: {b}")

print("\n--- Script tags ---")
scripts = re.findall(r'<script[^>]*src=["\']([^"\']+)["\']', html)
for s in scripts[:15]:
    print(f"  {s}")
