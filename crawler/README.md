# Skincare App — Web Crawler

A Python CLI tool that scrapes skincare product information from **CosDNA**, **Sasa**, or any generic product page, then upserts the data into the shared **PostgreSQL** database.

---

## Project Structure

```
crawler/
├── main.py                  # CLI entry point
├── requirements.txt
├── .env.example             # Copy to .env and fill in DATABASE_URL
├── models/
│   └── product.py           # ProductData & IngredientDetail dataclasses
├── scrapers/
│   ├── base.py              # Shared HTTP session + helpers
│   ├── cosdna.py            # CosDNA ingredient table scraper
│   ├── sasa.py              # Sasa HK product scraper
│   └── generic.py           # Fallback scraper for any shop (JSON-LD / HTML)
└── db/
    ├── connection.py         # psycopg2 connection from DATABASE_URL
    └── upsert.py             # Upsert product + availability into PostgreSQL
```

---

## Setup

```bash
cd crawler

# 1. Create a virtual environment
python3 -m venv .venv
source .venv/bin/activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Configure database
cp .env.example .env
# Edit .env and paste your Railway DATABASE_URL
```

---

## Usage

### 1 — Scrape CosDNA (ingredients) with manual metadata

```bash
python main.py cosdna https://www.cosdna.com/eng/cosmetic_6583659346.html \
    --name "Extreme Centella B5 Repair Serum" \
    --brand "Neogence" --category "Serum" \
    --country HK --store "Sasa" --store-type local \
    --price 298 --currency HKD
```

### 2 — Scrape CosDNA + merge a shop page for price/image

```bash
python main.py cosdna https://www.cosdna.com/eng/cosmetic_XYZ.html \
    --shop-url https://www.sasa.com/en/product/... \
    --brand "Some Brand" --category "Moisturizer" \
    --country HK --store "Sasa" --store-type local --price 198
```

### 3 — Scrape a Sasa product page directly

```bash
python main.py sasa https://www.sasa.com/en/product/... \
    --category "Cleanser"
```

### 4 — Scrape any generic shop page

```bash
python main.py generic https://some-shop.com/product/xyz \
    --brand "CeraVe" --category "Cleanser" \
    --country SG --store "Guardian" --store-type local \
    --price 28.90 --currency SGD
```

### Dry-run (preview without saving)

Add `--dry-run` to any command to preview the parsed data without touching the DB.

---

## Supported Countries & Currency Codes

| Country | Code | Currency |
|---------|------|----------|
| Hong Kong | HK | HKD |
| Singapore | SG | SGD |
| Malaysia | MY | MYR |
| Taiwan | TW | TWD |
| Japan | JP | JPY |

Stores are automatically created if they don't exist. They are matched by `(country, name, type)`.

---

## Extending — Adding a New Shop Scraper

1. Create `scrapers/yourshop.py` extending `BaseScraper`
2. Implement `scrape(url) -> ProductData`
3. Add a new `mode` choice in `main.py`

---

## Data Flow

```
URL(s) → Scraper → ProductData → upsert_product()
                                       │
                      ┌────────────────┼───────────────────┐
                      ▼                ▼                   ▼
                  products    product_availability      stores
                  (upserted)   (price per country)   (auto-created)
```
