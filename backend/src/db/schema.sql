-- ============================================================
-- Skincare App — PostgreSQL Schema
-- Run: psql $DATABASE_URL -f src/db/schema.sql
-- ============================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ── Users ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id            SERIAL PRIMARY KEY,
  email         TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name          TEXT NOT NULL,
  role          TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user','admin')),
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ── Countries ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS countries (
  id       SERIAL PRIMARY KEY,
  code     CHAR(2) UNIQUE NOT NULL,   -- e.g. HK
  name     TEXT NOT NULL,
  flag     TEXT NOT NULL,
  currency CHAR(3) NOT NULL
);

-- ── Stores ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS stores (
  id         SERIAL PRIMARY KEY,
  country_id INTEGER NOT NULL REFERENCES countries(id) ON DELETE CASCADE,
  name       TEXT NOT NULL,
  type       TEXT NOT NULL CHECK (type IN ('local','online')),
  UNIQUE (country_id, name, type)
);

-- ── Products ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS products (
  id              SERIAL PRIMARY KEY,
  name            TEXT NOT NULL,
  brand           TEXT NOT NULL,
  category        TEXT NOT NULL,          -- product type: Cleanser, Serum, etc.
  functionalities TEXT[] NOT NULL DEFAULT '{}',
  description     TEXT NOT NULL DEFAULT '',
  ingredients     TEXT[] NOT NULL DEFAULT '{}',
  image_url       TEXT NOT NULL DEFAULT '',
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_products_updated_at ON products;
CREATE TRIGGER trg_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ── Product Availability (per country + store) ────────────────
CREATE TABLE IF NOT EXISTS product_availability (
  id         SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  country_id INTEGER NOT NULL REFERENCES countries(id) ON DELETE CASCADE,
  store_id   INTEGER NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  price      NUMERIC(10,2) NOT NULL,
  currency   CHAR(3) NOT NULL,
  UNIQUE (product_id, country_id, store_id)
);

-- ── Favorites ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS favorites (
  id         SERIAL PRIMARY KEY,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, product_id)
);

-- ── Reviews ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS reviews (
  id         SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rating     INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  title      TEXT NOT NULL DEFAULT '',
  body       TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (product_id, user_id)
);

DROP TRIGGER IF EXISTS trg_reviews_updated_at ON reviews;
CREATE TRIGGER trg_reviews_updated_at
  BEFORE UPDATE ON reviews
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ── Indexes ──────────────────────────────────────────────────
CREATE UNIQUE INDEX IF NOT EXISTS uq_products_name_brand ON products (lower(name), lower(brand));
CREATE INDEX IF NOT EXISTS idx_products_brand       ON products(brand);
CREATE INDEX IF NOT EXISTS idx_products_brand_name  ON products(brand, name);
CREATE INDEX IF NOT EXISTS idx_products_category    ON products(category);
CREATE INDEX IF NOT EXISTS idx_pa_product           ON product_availability(product_id);
CREATE INDEX IF NOT EXISTS idx_pa_product_id        ON product_availability(product_id);
CREATE INDEX IF NOT EXISTS idx_pa_country           ON product_availability(country_id);
CREATE INDEX IF NOT EXISTS idx_pa_country_id        ON product_availability(country_id);
CREATE INDEX IF NOT EXISTS idx_countries_code       ON countries(code);
CREATE INDEX IF NOT EXISTS idx_reviews_product      ON reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_favorites_user       ON favorites(user_id);
