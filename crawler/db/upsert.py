"""
Upsert scraped ProductData into the PostgreSQL schema:
    products  ->  product_availability  (via countries + stores)

Matching strategy:
  - product:  UNIQUE (lower(name), lower(brand))
  - country:  matched by code (e.g. 'HK')
  - store:    matched by (country_id, lower(name), type)
  - availability: UNIQUE (product_id, country_id, store_id)
"""
import psycopg2
from models.product import ProductData
from .connection import get_conn


def upsert_product(data: ProductData, verbose: bool = True) -> int:
    """
    Insert or update the product and its availability.
    Returns the product_id.
    """
    conn = get_conn()
    try:
        with conn:
            with conn.cursor() as cur:
                # ── 1. Upsert product ────────────────────────────────────
                cur.execute(
                    """
                    INSERT INTO products
                        (name, brand, category, functionalities, description,
                         ingredients, image_url)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    ON CONFLICT (lower(name), lower(brand)) DO NOTHING
                    RETURNING id
                    """,
                    (
                        data.name,
                        data.brand,
                        data.category,
                        data.functionalities,
                        data.description,
                        data.ingredients,
                        data.image_url,
                    ),
                )
                row = cur.fetchone()
                if row:
                    product_id = row["id"]
                    if verbose:
                        print(f"  ✅ Inserted new product   id={product_id}")
                else:
                    # Already exists — fetch its id and update mutable fields
                    cur.execute(
                        """
                        UPDATE products
                        SET functionalities = %s,
                            description     = CASE WHEN description = '' THEN %s ELSE description END,
                            ingredients     = CASE WHEN array_length(ingredients,1) IS NULL THEN %s ELSE ingredients END,
                            image_url       = CASE WHEN image_url = '' THEN %s ELSE image_url END
                        WHERE lower(name) = lower(%s) AND lower(brand) = lower(%s)
                        RETURNING id
                        """,
                        (
                            data.functionalities,
                            data.description,
                            data.ingredients,
                            data.image_url,
                            data.name,
                            data.brand,
                        ),
                    )
                    row = cur.fetchone()
                    if not row:
                        raise RuntimeError(
                            f"Could not find product '{data.name}' by '{data.brand}' in DB."
                        )
                    product_id = row["id"]
                    if verbose:
                        print(f"  🔄 Updated existing product id={product_id}")

                # ── 2. Availability (optional) ───────────────────────────
                if data.country_code and data.store_name and data.price > 0:
                    # Look up country
                    cur.execute(
                        "SELECT id, currency FROM countries WHERE code = %s",
                        (data.country_code.upper(),),
                    )
                    country_row = cur.fetchone()
                    if not country_row:
                        raise RuntimeError(
                            f"Country code '{data.country_code}' not found in DB."
                        )
                    country_id = country_row["id"]
                    currency = data.currency or country_row["currency"]

                    # Upsert store
                    cur.execute(
                        """
                        INSERT INTO stores (country_id, name, type)
                        VALUES (%s, %s, %s)
                        ON CONFLICT (country_id, name, type) DO NOTHING
                        RETURNING id
                        """,
                        (country_id, data.store_name, data.store_type),
                    )
                    store_row = cur.fetchone()
                    if not store_row:
                        cur.execute(
                            "SELECT id FROM stores WHERE country_id=%s AND lower(name)=lower(%s) AND type=%s",
                            (country_id, data.store_name, data.store_type),
                        )
                        store_row = cur.fetchone()
                    store_id = store_row["id"]

                    # Upsert availability
                    cur.execute(
                        """
                        INSERT INTO product_availability
                            (product_id, country_id, store_id, price, currency)
                        VALUES (%s, %s, %s, %s, %s)
                        ON CONFLICT (product_id, country_id, store_id)
                        DO UPDATE SET price = EXCLUDED.price,
                                      currency = EXCLUDED.currency
                        RETURNING id
                        """,
                        (product_id, country_id, store_id, data.price, currency),
                    )
                    avail_row = cur.fetchone()
                    if verbose:
                        print(
                            f"  💰 Availability saved  "
                            f"country={data.country_code} store={data.store_name} "
                            f"price={currency} {data.price:.2f}  id={avail_row['id']}"
                        )

        return product_id
    finally:
        conn.close()
