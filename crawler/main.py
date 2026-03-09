#!/usr/bin/env python3
"""
Skincare App — Web Crawler CLI
===============================
Scrape product info from CosDNA (and shop pages) and upsert into PostgreSQL.

USAGE EXAMPLES
--------------

1) Scrape a CosDNA page and save with manual metadata:
   python main.py cosdna https://www.cosdna.com/eng/cosmetic_6583659346.html \\
       --name "Extreme Centella B5 Repair Serum" \\
       --brand "Neogence" --category "Serum" \\
       --country HK --store "Sasa" --store-type local \\
       --price 298 --currency HKD

2) Scrape a Sasa product page (name/brand auto-detected):
   python main.py sasa https://www.sasa.com/en/product/... \\
       --category "Moisturizer"

3) Scrape any generic shop page:
   python main.py generic https://some-shop.com/product/xyz \\
       --country SG --store "Guardian" --store-type local \\
       --price 28.90 --currency SGD \\
       --brand "CeraVe" --category "Cleanser"

4) Scrape CosDNA then merge with a Sasa shop page in one run:
   python main.py cosdna <cosdna-url> --shop-url <sasa-url> \\
       --brand "Neogence" --category "Serum" --country HK --store Sasa --price 298

OPTIONS
-------
  --name        Override / supply product name
  --brand       Brand name
  --category    Product category (Cleanser, Serum, Moisturizer, Toner, …)
  --country     2-letter country code (HK, SG, MY, TW, JP, …)
  --store       Store name (Sasa, Guardian, Watsons, …)
  --store-type  'local' or 'online'  (default: online)
  --price       Numeric price
  --currency    3-letter currency code (HKD, SGD, …)
  --shop-url    Additional shop URL to merge name/brand/price when using cosdna mode
  --dry-run     Print parsed data without saving to DB
"""
import argparse
import sys
from rich.console import Console
from rich.table import Table
from rich import box

from models.product import ProductData
from scrapers.cosdna import CosDNAScraper
from scrapers.sasa import SasaScraper
from scrapers.generic import GenericScraper
from db.upsert import upsert_product

console = Console()


def _merge(base: ProductData, extra: ProductData) -> ProductData:
    """Merge extra fields into base (base takes priority for non-empty values)."""
    if not base.name and extra.name:
        base.name = extra.name
    if not base.brand and extra.brand:
        base.brand = extra.brand
    if not base.category and extra.category:
        base.category = extra.category
    if not base.description and extra.description:
        base.description = extra.description
    if not base.image_url and extra.image_url:
        base.image_url = extra.image_url
    if not base.country_code and extra.country_code:
        base.country_code = extra.country_code
    if not base.store_name and extra.store_name:
        base.store_name = extra.store_name
    if not base.store_type and extra.store_type:
        base.store_type = extra.store_type
    if base.price == 0.0 and extra.price > 0:
        base.price = extra.price
    if not base.currency and extra.currency:
        base.currency = extra.currency
    return base


def _apply_overrides(data: ProductData, args: argparse.Namespace) -> ProductData:
    if args.name:
        data.name = args.name
    if args.brand:
        data.brand = args.brand
    if args.category:
        data.category = args.category
    if args.country:
        data.country_code = args.country.upper()
    if args.store:
        data.store_name = args.store
    if args.store_type:
        data.store_type = args.store_type
    if args.price is not None:
        data.price = args.price
    if args.currency:
        data.currency = args.currency.upper()
    return data


def _print_summary(data: ProductData) -> None:
    console.print()
    console.print(f"[bold cyan]Product:[/] {data.name or '[red]MISSING[/]'}")
    console.print(f"[bold cyan]Brand:[/]   {data.brand or '[red]MISSING[/]'}")
    console.print(f"[bold cyan]Category:[/]{data.category or '[yellow]not set[/]'}")
    console.print(f"[bold cyan]Image:[/]   {data.image_url or '[yellow]none[/]'}")
    if data.price > 0:
        console.print(f"[bold cyan]Price:[/]   {data.currency} {data.price:.2f}  "
                      f"@ {data.store_name} ({data.country_code})")

    if data.ingredient_details:
        t = Table(
            "No.", "Ingredient", "Function", "Acne Risk", "Irritant", "Safety",
            box=box.SIMPLE_HEAVY,
            show_header=True,
            header_style="bold magenta",
        )
        for i, ing in enumerate(data.ingredient_details, 1):
            def fmt(val):
                if val is None:
                    return "[dim]—[/]"
                if val == 0:
                    return f"[green]{val}[/]"
                if val <= 2:
                    return f"[yellow]{val}[/]"
                return f"[red]{val}[/]"

            t.add_row(
                str(i),
                ing.name,
                ing.function or "—",
                fmt(ing.acne_risk),
                fmt(ing.irritant),
                fmt(ing.safety),
            )
        console.print(t)
    elif data.ingredients:
        console.print(f"[bold cyan]Ingredients ({len(data.ingredients)}):[/] "
                      + ", ".join(data.ingredients[:6])
                      + ("…" if len(data.ingredients) > 6 else ""))


def _validate(data: ProductData) -> list[str]:
    errors = []
    if not data.name:
        errors.append("--name is required (could not detect product name)")
    if not data.brand:
        errors.append("--brand is required")
    if not data.category:
        errors.append("--category is required (e.g. Serum, Cleanser, Moisturizer)")
    return errors


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="main.py",
        description="Skincare App Web Crawler — scrape & save product data",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    p.add_argument(
        "mode",
        choices=["cosdna", "sasa", "generic"],
        help="Scraper mode",
    )
    p.add_argument("url", help="Primary URL to scrape")

    p.add_argument("--name", help="Override product name")
    p.add_argument("--brand", help="Brand name")
    p.add_argument("--category", help="Product category")
    p.add_argument("--country", help="2-letter country code")
    p.add_argument("--store", help="Store name")
    p.add_argument("--store-type", choices=["local", "online"], default="online")
    p.add_argument("--price", type=float, help="Price (numeric)")
    p.add_argument("--currency", help="3-letter currency code")
    p.add_argument(
        "--shop-url",
        dest="shop_url",
        help="Optional shop page URL to merge data (use alongside cosdna mode)",
    )
    p.add_argument(
        "--fetch-details",
        action="store_true",
        dest="fetch_details",
        help="(CosDNA mode) Fetch each ingredient page for Function + Safety score — slower but richer",
    )
    p.add_argument(
        "--dry-run",
        action="store_true",
        help="Print parsed data without saving to DB",
    )
    return p


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    console.rule("[bold blue]Skincare Crawler")

    # ── Scrape primary URL ─────────────────────────────────────────────────
    console.print(f"\n[bold]Mode:[/] {args.mode}  [bold]URL:[/] {args.url}\n")

    if args.mode == "cosdna":
        console.print("🔍 Scraping CosDNA…")
        data = CosDNAScraper().scrape(args.url, fetch_ingredient_pages=getattr(args, "fetch_details", False))

        # Optional: merge a shop page for price / image
        if args.shop_url:
            console.print(f"🔍 Scraping shop page: {args.shop_url}")
            shop_data = GenericScraper().scrape(
                args.shop_url,
                country_code=args.country or "",
                store_name=args.store or "",
                store_type=args.store_type or "online",
                currency=args.currency or "",
            )
            data = _merge(data, shop_data)

    elif args.mode == "sasa":
        console.print("🔍 Scraping Sasa…")
        data = SasaScraper().scrape(args.url)

    else:  # generic
        console.print("🔍 Scraping (generic)…")
        data = GenericScraper().scrape(
            args.url,
            country_code=args.country or "",
            store_name=args.store or "",
            store_type=args.store_type or "online",
            currency=args.currency or "",
        )

    # ── Apply CLI overrides ────────────────────────────────────────────────
    data = _apply_overrides(data, args)

    # ── Print summary ──────────────────────────────────────────────────────
    _print_summary(data)

    # ── Validate required fields ───────────────────────────────────────────
    errors = _validate(data)
    if errors:
        console.print()
        for e in errors:
            console.print(f"[bold red]✖ {e}[/]")
        console.print(
            "\n[yellow]Fix the errors above and re-run. Nothing was saved.[/]"
        )
        sys.exit(1)

    if args.dry_run:
        console.print("\n[yellow]Dry-run mode — nothing saved to DB.[/]")
        return

    # ── Save to DB ─────────────────────────────────────────────────────────
    console.print("\n[bold]Saving to database…[/]")
    try:
        product_id = upsert_product(data)
        console.print(
            f"\n[bold green]✅ Done! Product saved with id={product_id}[/]"
        )
    except Exception as exc:
        console.print(f"\n[bold red]✖ DB error: {exc}[/]")
        sys.exit(1)


if __name__ == "__main__":
    main()
