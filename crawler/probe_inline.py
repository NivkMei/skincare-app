import requests, re, json

s = requests.Session()
headers = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "zh-TW,zh;q=0.9,en-US;q=0.8",
}

url = "https://www.sasa.com.hk/v2/official/SalePageCategory/5886?sortMode=PageView"
r = s.get(url, headers=headers, timeout=15)
html = r.text
print(f"Status: {r.status_code}, Cookies: {dict(s.cookies)}")

# Print all inline scripts
scripts = re.findall(r'<script(?:[^>]*)>(.*?)</script>', html, re.DOTALL)
print(f"\nFound {len(scripts)} inline scripts")
for i, sc in enumerate(scripts):
    sc = sc.strip()
    if sc:
        print(f"\n--- Inline Script {i+1} ({len(sc)} chars) ---")
        print(sc[:1000])
