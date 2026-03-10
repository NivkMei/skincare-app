"""
migrate_images_to_cloudinary.py
--------------------------------
Uploads every product image from the DB to Cloudinary (fetched directly
from the source URL — no local download needed) and updates the DB row.

Usage:
    python3 migrate_images_to_cloudinary.py            # migrate all
    python3 migrate_images_to_cloudinary.py --dry-run  # preview only

Requirements:
    pip install cloudinary psycopg2-binary python-dotenv
    Fill in CLOUDINARY_* vars in crawler/.env

Idempotent: runs already-migrated images are skipped (public_id already
exists on Cloudinary → returned immediately without re-uploading).
"""
import os
import sys
import time
import argparse
import random
from pathlib import Path

import psycopg2
import psycopg2.extras
from dotenv import load_dotenv
import cloudinary
import cloudinary.uploader

# ── Config ────────────────────────────────────────────────────────────────────
load_dotenv(Path(__file__).parent / ".env")

CLOUDINARY_CLOUD_NAME = os.environ["CLOUDINARY_CLOUD_NAME"]
CLOUDINARY_API_KEY    = os.environ["CLOUDINARY_API_KEY"]
CLOUDINARY_API_SECRET = os.environ["CLOUDINARY_API_SECRET"]
DATABASE_URL          = os.environ["DATABASE_URL"]

cloudinary.config(
    cloud_name = CLOUDINARY_CLOUD_NAME,
    api_key    = CLOUDINARY_API_KEY,
    api_secret = CLOUDINARY_API_SECRET,
    secure     = True,
)

# URLs containing these strings are skipped (not worth migrating)
SKIP_PATTERNS = ["picsum.photos", "cloudinary.com", "placeholder"]


def should_skip(url: str) -> bool:
    if not url or not url.startswith("http"):
        return True
    return any(p in url for p in SKIP_PATTERNS)


def migrate_images(dry_run: bool = False, start_id: int = 0) -> None:
    conn = psycopg2.connect(DATABASE_URL, cursor_factory=psycopg2.extras.RealDictCursor)
    cur = conn.cursor()

    # Fetch all products that need migration
    cur.execute("""
        SELECT id, name, image_url
        FROM products
        WHERE image_url != ''
          AND image_url NOT LIKE '%%cloudinary.com%%'
          AND id > %s
        ORDER BY id
    """, (start_id,))
    products = cur.fetchall()
    total = len(products)
    if start_id:
        print(f"Resuming from id > {start_id}")
    print(f"Found {total} products to migrate (skipping mock/cloudinary images)\n")

    if dry_run:
        skippable = sum(1 for p in products if should_skip(p["image_url"]))
        print(f"[DRY RUN] Would upload {total - skippable} images, skip {skippable}")
        for p in products[:5]:
            print(f"  id={p['id']} url={p['image_url'][:80]}")
        return

    uploaded = 0
    skipped  = 0
    errors   = 0

    for i, product in enumerate(products, 1):
        product_id = product["id"]
        src_url    = product["image_url"]
        name       = product["name"][:40]

        if should_skip(src_url):
            skipped += 1
            continue

        public_id = f"skincare/products/{product_id}"

        try:
            result = cloudinary.uploader.upload(
                src_url,
                public_id     = public_id,
                overwrite     = False,   # idempotent: skip if public_id exists
                resource_type = "image",
                folder        = "",      # public_id already has the path
                quality       = "auto",
                fetch_format  = "auto",
                timeout       = 20,      # abort if Cloudinary takes >20s to fetch image
            )
            new_url = result["secure_url"]

            # Update DB
            cur.execute(
                "UPDATE products SET image_url = %s WHERE id = %s",
                (new_url, product_id)
            )
            conn.commit()

            uploaded += 1
            status = "NEW" if result.get("version") else "EXISTING"
            print(f"[{i}/{total}] ✅ {status:8s} id={product_id} {name}")
            errors = 0  # reset consecutive error counter on success

        except Exception as e:
            errors += 1
            print(f"[{i}/{total}] ⚠️  SKIP    id={product_id} {name}: {type(e).__name__}: {str(e)[:80]}")
            if errors > 20:
                print("\nToo many consecutive errors — stopping.")
                break

        # Respectful rate limit: ~2-4 uploads/sec (Cloudinary allows 500/hour on free)
        time.sleep(random.uniform(0.9, 1.5))

        if i % 50 == 0:
            print(f"\n── Progress: {uploaded} uploaded | {skipped} skipped | {errors} errors ──\n")

    print(f"\n{'='*50}")
    print(f"Done! uploaded={uploaded}, skipped={skipped}, errors={errors}")
    print(f"{'='*50}")
    conn.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Migrate product images to Cloudinary")
    parser.add_argument("--dry-run", action="store_true", help="Preview without uploading")
    parser.add_argument("--start-id", type=int, default=0, help="Resume from this product id (exclusive)")
    args = parser.parse_args()

    # Validate credentials before starting
    if CLOUDINARY_CLOUD_NAME == "your_cloud_name":
        print("❌ Fill in CLOUDINARY_* credentials in crawler/.env first!")
        print("   1. Go to https://console.cloudinary.com")
        print("   2. Create a free account")
        print("   3. Copy Cloud Name, API Key, API Secret into crawler/.env")
        sys.exit(1)

    migrate_images(dry_run=args.dry_run, start_id=args.start_id)
