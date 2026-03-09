"""
Sasa (sasa.com) product scraper — Hong Kong.

Extracts: name, brand, category, price (HKD), image_url, description.
Ingredients are typically NOT on Sasa pages; pair with CosDNA for those.

Usage:
    from scrapers.sasa import SasaScraper
    scraper = SasaScraper()
    data = scraper.scrape("https://www.sasa.com/en/product/...")
"""
import re
import json
from models.product import ProductData
from .base import BaseScraper


class SasaScraper(BaseScraper):
    STORE_NAME = "Sasa"
    COUNTRY_CODE = "HK"
    CURRENCY = "HKD"

    def scrape(self, url: str) -> ProductData:
        soup = self.get(url)

        # ── Try JSON-LD structured data first (most reliable) ────────────
        name = brand = category = description = image_url = ""
        price = 0.0

        for script in soup.find_all("script", type="application/ld+json"):
            try:
                data = json.loads(script.string or "{}")
                if isinstance(data, list):
                    data = data[0]
                if data.get("@type") in ("Product", "product"):
                    name = self.clean(data.get("name", ""))
                    brand = self.clean(
                        data.get("brand", {}).get("name", "")
                        if isinstance(data.get("brand"), dict)
                        else data.get("brand", "")
                    )
                    description = self.clean(data.get("description", ""))
                    image_url = (
                        data.get("image", [""])[0]
                        if isinstance(data.get("image"), list)
                        else data.get("image", "")
                    )
                    offers = data.get("offers", {})
                    if isinstance(offers, list):
                        offers = offers[0]
                    price_str = str(offers.get("price", "0"))
                    price = float(re.sub(r"[^\d.]", "", price_str) or 0)
                    break
            except (json.JSONDecodeError, AttributeError, ValueError):
                continue

        # ── Fallback: parse HTML directly ─────────────────────────────────
        if not name:
            h1 = soup.find("h1")
            name = self.clean(h1.get_text()) if h1 else ""

        if not brand:
            # Sasa often shows brand as a link above the product title
            brand_tag = soup.select_one(".brand-name, [class*='brand']")
            brand = self.clean(brand_tag.get_text()) if brand_tag else ""

        if not image_url:
            img = soup.select_one(".product-image img, [class*='gallery'] img")
            if img:
                image_url = img.get("src", img.get("data-src", ""))

        if price == 0.0:
            price_tag = soup.select_one(
                "[class*='price'], [class*='Price'], span[itemprop='price']"
            )
            if price_tag:
                raw = re.sub(r"[^\d.]", "", price_tag.get_text())
                price = float(raw) if raw else 0.0

        # Guess category from URL or breadcrumb
        if not category:
            crumbs = soup.select("[class*='breadcrumb'] a, nav[aria-label*='breadcrumb'] a")
            if len(crumbs) >= 2:
                category = self.clean(crumbs[-2].get_text())

        return ProductData(
            name=name,
            brand=brand,
            category=category,
            description=description,
            image_url=image_url,
            country_code=self.COUNTRY_CODE,
            store_name=self.STORE_NAME,
            store_type="local",
            price=price,
            currency=self.CURRENCY,
            source_url=url,
        )
