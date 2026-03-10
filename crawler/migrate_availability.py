"""
DB migration: redesign availability schema.
- Drop global available_online/available_in_store booleans from products
- Seed Sasa physical store (store_id=31) rows for all products at 5% in-store markup
"""
import psycopg2, os
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))
conn = psycopg2.connect(os.environ['DATABASE_URL'])
cur = conn.cursor()

# 1. Drop global boolean flag columns (now derived per-country from product_availability)
cur.execute("ALTER TABLE products DROP COLUMN IF EXISTS available_online")
cur.execute("ALTER TABLE products DROP COLUMN IF EXISTS available_in_store")
print("Dropped global available_online / available_in_store from products")

# 2. Add a unique constraint on product_availability if not present
#    (prevents duplicate rows on re-run)
cur.execute("""
    DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM pg_constraint
            WHERE conname = 'pa_product_store_unique'
        ) THEN
            ALTER TABLE product_availability
            ADD CONSTRAINT pa_product_store_unique
            UNIQUE (product_id, store_id);
        END IF;
    END $$;
""")
print("Ensured unique constraint on (product_id, store_id)")

# 3. Insert Sasa LOCAL store rows — price = online price * 1.05 (5% in-store markup)
#    store_id=32 = Sasa online (HK country_id=1)
#    store_id=31 = Sasa physical shop (HK country_id=1)
cur.execute("""
    INSERT INTO product_availability (product_id, country_id, store_id, price, currency)
    SELECT pa.product_id, pa.country_id, 31, ROUND(pa.price * 1.05, 2), pa.currency
    FROM product_availability pa
    WHERE pa.store_id = 32
    ON CONFLICT (product_id, store_id) DO NOTHING
""")
inserted = cur.rowcount
print(f"Inserted {inserted} Sasa physical-store availability rows")

conn.commit()

# Verify
cur.execute("""
    SELECT s.name, s.type, COUNT(*) AS cnt, MIN(pa.price), MAX(pa.price)
    FROM product_availability pa
    JOIN stores s ON s.id = pa.store_id
    GROUP BY s.id, s.name, s.type
    ORDER BY s.id
""")
print("\nAvailability summary:")
for r in cur.fetchall():
    print(f"  store={r[0]} ({r[1]}): {r[2]} rows, price {r[3]}–{r[4]}")

cur.execute("""
    SELECT p.name,
           MIN(pa.price) AS min_price,
           MAX(pa.price) AS max_price,
           BOOL_OR(s.type = 'online') AS avail_online,
           BOOL_OR(s.type = 'local')  AS avail_instore,
           MAX(pa.currency) AS currency
    FROM products p
    JOIN product_availability pa ON pa.product_id = p.id
    JOIN stores s ON s.id = pa.store_id
    GROUP BY p.id, p.name
    LIMIT 5
""")
print("\nSample price ranges (first 5 products):")
for r in cur.fetchall():
    print(f"  {r[0][:40]}: {r[5]} {r[1]}–{r[2]}  online={r[3]} instore={r[4]}")

conn.close()
print("\nDone.")
