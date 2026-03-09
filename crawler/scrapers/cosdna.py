"""
CosDNA scraper — extracts product name, image URL, and ingredient list.

Strategy:
  • Product page (static HTML): ingredient names come from <a> links
  • Individual ingredient pages (static HTML): Function + Safety score
  • Local DB (data/ingredient_db.py): Acne Risk + Irritant values

Usage:
    from scrapers.cosdna import CosDNAScraper

    # Quick — names + local DB ratings only
    data = CosDNAScraper().scrape(url)

    # Full — also fetches each ingredient page for Function + Safety
    data = CosDNAScraper().scrape(url, fetch_ingredient_pages=True)
"""
from __future__ import annotations
import re
from typing import List, Optional
from models.product import ProductData, IngredientDetail
from data.ingredient_db import lookup
from .base import BaseScraper

BASE = "https://www.cosdna.com"


class CosDNAScraper(BaseScraper):
    """Scrapes a single CosDNA product page."""

    def scrape(self, url: str, fetch_ingredient_pages: bool = False) -> ProductData:
        soup = self.get(url)

        # ── Product name ───────────────────────────────────────────────────
        name = ""
        h1 = soup.find("h1")
        if h1:
            name = self.clean(h1.get_text())

        # ── Image ──────────────────────────────────────────────────────────
        image_url = ""
        img_tag = soup.select_one("img[src*='/images/cos/']")
        if img_tag and img_tag.get("src"):
            src = img_tag["src"]
            if src.startswith("//"):
                src = "https:" + src
            elif src.startswith("/"):
                src = BASE + src
            if "blank_" not in src:
                image_url = src

        # ── Ingredient names from static <a> anchor links ──────────────────
        # CosDNA embeds ingredient names as <a> tags pointing to ingredient
        # detail pages like /eng/fc86a9293.html (no 'cosmetic_' in href).
        lang = self._lang_prefix(url)
        ingredient_links: List[tuple] = []
        seen: set = set()
        for a in soup.find_all("a", href=True):
            href: str = a["href"]
            # Match pattern: /lang/alphanumericID.html  (no 'cosmetic_')
            if (re.search(r"/[a-z]+/[a-z0-9]+\.html$", href)
                    and "cosmetic_" not in href
                    and "help/" not in href
                    and "user/" not in href):
                ing_name = self.clean(a.get_text())
                if ing_name and ing_name not in seen:
                    seen.add(ing_name)
                    ingredient_links.append((ing_name, href))

        # ── Build per-ingredient detail ────────────────────────────────────
        ingredient_details: List[IngredientDetail] = []
        ingredients: List[str] = []

        for ing_name, href in ingredient_links:
            ingredients.append(ing_name)

            # Acne Risk + Irritant from local DB
            local = lookup(ing_name)
            acne_risk: Optional[int] = local.acne_risk if local else None
            irritant: Optional[int] = local.irritant if local else None
            function_text: Optional[str] = None
            safety: Optional[int] = None

            if fetch_ingredient_pages:
                full_href = href if href.startswith("http") else BASE + href
                try:
                    ing_soup = self.get(full_href)
                    function_text, safety = self._parse_ingredient_page(ing_soup)
                except Exception:
                    pass

            ingredient_details.append(IngredientDetail(
                name=ing_name,
                function=function_text,
                acne_risk=acne_risk,
                irritant=irritant,
                safety=safety,
            ))

        return ProductData(
            name=name,
            brand="",
            category="",
            ingredients=ingredients,
            ingredient_details=ingredient_details,
            image_url=image_url,
            source_url=url,
        )

    @staticmethod
    def _lang_prefix(url: str) -> str:
        m = re.search(r"cosdna\.com/([a-z]+)/", url)
        return m.group(1) if m else "eng"

    def _parse_ingredient_page(self, soup) -> tuple:
        """Extract (function_text, safety_score) from a CosDNA ingredient page."""
        lines = [l.strip() for l in soup.get_text().split("\n") if l.strip()]
        function_text: Optional[str] = None
        safety: Optional[int] = None
        for i, line in enumerate(lines):
            if line == "Safety" and i + 1 < len(lines):
                safety = self.safe_int(lines[i + 1])
            # Function lines contain semicolons, no digits, min 5 chars
            if ";" in line and not any(c.isdigit() for c in line) and len(line) > 5:
                if function_text is None:
                    function_text = line.replace(";", ",")
        return function_text, safety

