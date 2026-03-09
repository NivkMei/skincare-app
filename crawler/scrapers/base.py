"""
Base scraper: shared session, headers, and helper utilities.
"""
from __future__ import annotations
import re
import time
import random
from typing import Optional
import requests
from bs4 import BeautifulSoup


HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/122.0.0.0 Safari/537.36"
    ),
    "Accept-Language": "en-US,en;q=0.9",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
}


class BaseScraper:
    def __init__(self, delay: float = 1.5):
        self.session = requests.Session()
        self.session.headers.update(HEADERS)
        self.delay = delay

    def get(self, url: str) -> BeautifulSoup:
        """Fetch a page and return a BeautifulSoup object."""
        time.sleep(self.delay + random.uniform(0, 0.8))
        resp = self.session.get(url, timeout=20)
        resp.raise_for_status()
        return BeautifulSoup(resp.text, "html.parser")

    @staticmethod
    def clean(text: str) -> str:
        """Strip and normalise whitespace."""
        return re.sub(r"\s+", " ", text or "").strip()

    @staticmethod
    def safe_int(text: str) -> Optional[int]:
        """Parse an integer, returning None on failure."""
        try:
            return int(text.strip())
        except (ValueError, AttributeError):
            return None
