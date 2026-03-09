"""
Generic product page scraper — heuristic fallback for any shop not
explicitly supported. Extracts name, brand, image and price via
JSON-LD structured data (scheme.org/Product), then falls back to
common CSS patterns.
"""
import re
import json
from models.product import ProductData
from .base import BaseScraper


class GenericScraper(BaseScraper):
    def scrape(self, url: str, country_code: str = "", store_name: str = "",
               store_type: str = "online", currency: str = "") -> ProductData:
        soup = self.get(url)

        name = brand = category = description = image_url = ""
        price = 0.0

        # ── JSON-LD structured data ────────────────────────────────────────
        for script in soup.find_all("script", type="application/ld+json"):
            try:
                data = json.loads(script.string or "{}")
                if isinstance(data, list):
                    data = next((d for d in data if d.get("@type") == "Product"), {})
                if data.get("@type") == "Product":
                    name = self.clean(data.get("name", ""))
                    brand_val = data.get("brand", "")
                    brand = self.clean(
                        brand_val.get("name", "") if isinstance(brand_val, dict) else brand_val
                    )
                    description = self.clean(data.get("description", ""))
                    image_val = data.get("image", "")
                    image_url = image_val[0] if isinstance(image_val, list) else image_val
                    offers = data.get("offers", {})
                    if isinstance(offers, list):
                        offers = offers[0]
                    price_str = str(offers.get("price", "0"))
                    price = float(re.sub(r"[^\d.]", "", price_str) or 0)
                    if not currency:
                        currency = offers.get("priceCurrency", "")
                    break
            except Exception:
                continue

        # ── HTML fallbacks ────────────────────────────────────────────────
        if not name:
            h1 = soup.find("h1")
            name = self.clean(h1.get_text()) if h1 else ""

        if not image_url:
            img = soup.select_one(
                "img[itemprop='image'], img[class*='product'], img[class*='gallery']"
            )
            if img:
                image_url = img.get("src", img.get("data-src", ""))

        if price == 0.0:
            price_tag = soup.select_one(
                "[itemprop='price'], [class*='price'], [class*='Price']"
            )
            if price_tag:
                raw = re.sub(r"[^\d.]", "", price_tag.get_text())
                price = float(raw) if raw else 0.0

        return ProductData(
            name=name,
            brand=brand,
            category=category,
            description=description,
            image_url=image_url,
            country_code=country_code,
            store_name=store_name,
            store_type=store_type,
            price=price,
            currency=currency,
            source_url=url,
        )
