/**
 * Seed script — run once to populate the database.
 * Usage: npm run db:seed
 */
import pool from '../config/database';
import bcrypt from 'bcrypt';
import dotenv from 'dotenv';

dotenv.config();

// ── Countries ─────────────────────────────────────────────────────────────────
const COUNTRIES = [
  { code: 'HK', name: 'Hong Kong', flag: '🇭🇰', currency: 'HKD',
    localStores: ['SaSa', 'Watsons', 'Manning'],
    onlineStores: ['HKTVmall', 'LOG-ON Online', 'SASA.com'] },
  { code: 'SG', name: 'Singapore', flag: '🇸🇬', currency: 'SGD',
    localStores: ['Guardian', 'Watsons', 'Sephora'],
    onlineStores: ['Lazada', 'Shopee', 'Zalora'] },
  { code: 'MY', name: 'Malaysia', flag: '🇲🇾', currency: 'MYR',
    localStores: ['Watsons', 'Guardian', 'Caring Pharmacy'],
    onlineStores: ['Lazada', 'Shopee', 'Zalora'] },
  { code: 'TW', name: 'Taiwan', flag: '🇹🇼', currency: 'TWD',
    localStores: ['Watsons', 'Cosmed', 'Poya'],
    onlineStores: ['Momo', 'PChome', 'shopee.tw'] },
  { code: 'JP', name: 'Japan', flag: '🇯🇵', currency: 'JPY',
    localStores: ['Matsumoto Kiyoshi', 'Sundrug', 'Ain Pharmacy'],
    onlineStores: ['Amazon JP', 'Rakuten', 'Cosme-de.com'] },
];

// ── Products ──────────────────────────────────────────────────────────────────
const PRODUCTS = [
  {
    name: 'Gentle Foam Cleanser', brand: 'CeraVe', category: 'Cleanser',
    functionalities: ['Barrier Repair', 'Soothing'],
    description: "A gentle cleanser that removes impurities while maintaining the skin's natural barrier.",
    ingredients: ['Water','Glycerin','Niacinamide','Ceramide NP','Ceramide AP','Ceramide EOP','Cholesterol','Phytosphingosine'],
    image_url: 'https://picsum.photos/seed/cerave-cleanser/400/400',
    availability: [
      { country: 'HK', price: 158, stores: ['Watsons','Manning','HKTVmall','SASA.com'] },
      { country: 'SG', price: 28,  stores: ['Guardian','Watsons','Lazada'] },
      { country: 'MY', price: 52,  stores: ['Watsons','Guardian','Shopee'] },
      { country: 'TW', price: 520, stores: ['Watsons','Cosmed'] },
      { country: 'JP', price: 1800,stores: ['Matsumoto Kiyoshi','Rakuten'] },
    ],
  },
  {
    name: 'Low pH Good Morning Gel Cleanser', brand: 'COSRX', category: 'Cleanser',
    functionalities: ['Acne-fighting', 'Exfoliating'],
    description: 'A low pH cleanser with BHA that gently removes dead skin cells and excess sebum.',
    ingredients: ['Water','Cocamidopropyl Betaine','Butylene Glycol','Tea Tree Leaf Oil','Willow Bark Extract','Citric Acid','Allantoin'],
    image_url: 'https://picsum.photos/seed/cosrx-cleanser/400/400',
    availability: [
      { country: 'HK', price: 119, stores: ['SaSa','Manning','HKTVmall','SASA.com'] },
      { country: 'SG', price: 22,  stores: ['Watsons','Shopee'] },
      { country: 'MY', price: 42,  stores: ['Caring Pharmacy','Lazada'] },
      { country: 'TW', price: 420, stores: ['Cosmed'] },
    ],
  },
  {
    name: 'Kombucha Facial Essence Toner', brand: 'TATCHA', category: 'Toner',
    functionalities: ['Hydrating', 'Brightening'],
    description: 'A three-in-one toner with Japanese superfoods to smooth, brighten and hydrate skin.',
    ingredients: ['Water','Glycerin','Radish Root Ferment Filtrate','Saccharomyces Ferment Filtrate','Camellia Sinensis Leaf Extract','Niacinamide','Sodium Hyaluronate'],
    image_url: 'https://picsum.photos/seed/tatcha-toner/400/400',
    availability: [
      { country: 'HK', price: 398, stores: ['SaSa','SASA.com','LOG-ON Online'] },
      { country: 'SG', price: 68,  stores: ['Sephora','Lazada'] },
      { country: 'JP', price: 4500,stores: ['Sundrug'] },
    ],
  },
  {
    name: 'Alcohol-Free Toner with Rose Water', brand: 'Thayers', category: 'Toner',
    functionalities: ['Hydrating', 'Soothing'],
    description: 'An alcohol-free facial toner with witch hazel and rose petal water.',
    ingredients: ['Water','Aloe Barbadensis Leaf Juice','Witch Hazel Extract','Rosa Damascena Flower Water','Glycerin','Panthenol','Allantoin'],
    image_url: 'https://picsum.photos/seed/thayers-toner/400/400',
    availability: [
      { country: 'HK', price: 148, stores: ['Watsons','Manning','HKTVmall','Shopee'] },
      { country: 'SG', price: 26,  stores: ['Guardian','Lazada'] },
      { country: 'MY', price: 48,  stores: ['Watsons','Shopee'] },
      { country: 'TW', price: 480, stores: ['Watsons'] },
    ],
  },
  {
    name: 'Hyaluronic Acid 2% + B5', brand: 'The Ordinary', category: 'Serum',
    functionalities: ['Hydrating', 'Barrier Repair'],
    description: 'A hydration support formula combining multiple weights of hyaluronic acid with Vitamin B5.',
    ingredients: ['Water','Sodium Hyaluronate','Sodium Hyaluronate Crosspolymer','Panthenol','Glycerin'],
    image_url: 'https://picsum.photos/seed/ordinary-ha/400/400',
    availability: [
      { country: 'HK', price: 89,  stores: ['SaSa','Manning','HKTVmall','SASA.com','LOG-ON Online'] },
      { country: 'SG', price: 16,  stores: ['Sephora','Guardian','Shopee','Lazada'] },
      { country: 'MY', price: 30,  stores: ['Watsons','Shopee'] },
      { country: 'TW', price: 320, stores: ['Cosmed'] },
      { country: 'JP', price: 1200,stores: ['Matsumoto Kiyoshi','Rakuten'] },
    ],
  },
  {
    name: 'Niacinamide 10% + Zinc 1%', brand: 'The Ordinary', category: 'Serum',
    functionalities: ['Brightening', 'Acne-fighting'],
    description: 'High-strength niacinamide with zinc to reduce blemishes and balance sebum.',
    ingredients: ['Water','Niacinamide','Pentylene Glycol','Zinc PCA','Dimethyl Isosorbide','Xanthan Gum'],
    image_url: 'https://picsum.photos/seed/ordinary-niacinamide/400/400',
    availability: [
      { country: 'HK', price: 79,  stores: ['SaSa','Manning','HKTVmall','SASA.com','LOG-ON Online'] },
      { country: 'SG', price: 14,  stores: ['Sephora','Guardian','Shopee','Lazada'] },
      { country: 'MY', price: 28,  stores: ['Watsons','Shopee'] },
      { country: 'TW', price: 290, stores: ['Cosmed'] },
      { country: 'JP', price: 1100,stores: ['Matsumoto Kiyoshi','Rakuten'] },
    ],
  },
  {
    name: 'Vitamin C Brightening Serum', brand: 'Skinceuticals', category: 'Serum',
    functionalities: ['Brightening', 'Anti-aging'],
    description: 'CE Ferulic — 15% pure vitamin C with 1% vitamin E and 0.5% ferulic acid.',
    ingredients: ['Water','L-Ascorbic Acid (15%)','Tocopherol (1%)','Ferulic Acid (0.5%)','Glycerin','Propylene Glycol'],
    image_url: 'https://picsum.photos/seed/skinceuticals-vitc/400/400',
    availability: [
      { country: 'HK', price: 1280,stores: ['SaSa','SASA.com','LOG-ON Online'] },
      { country: 'SG', price: 228, stores: ['Sephora','Lazada'] },
      { country: 'JP', price: 16000,stores: ['Rakuten'] },
    ],
  },
  {
    name: 'Moisturizing Cream with Ceramides', brand: 'CeraVe', category: 'Moisturizer',
    functionalities: ['Hydrating', 'Barrier Repair'],
    description: 'Developed with dermatologists. Contains three essential ceramides to protect the skin barrier.',
    ingredients: ['Water','Glycerin','Cetearyl Alcohol','Ceramide NP','Ceramide AP','Ceramide EOP','Cholesterol','Niacinamide','Sodium Hyaluronate'],
    image_url: 'https://picsum.photos/seed/cerave-moisturizer/400/400',
    availability: [
      { country: 'HK', price: 178, stores: ['Watsons','Manning','HKTVmall','SASA.com'] },
      { country: 'SG', price: 32,  stores: ['Guardian','Watsons','Shopee','Lazada'] },
      { country: 'MY', price: 60,  stores: ['Watsons','Guardian','Shopee'] },
      { country: 'TW', price: 580, stores: ['Watsons','Cosmed'] },
      { country: 'JP', price: 2000,stores: ['Matsumoto Kiyoshi','Rakuten'] },
    ],
  },
  {
    name: 'Moisture Surge™ 100H Auto-Replenishing Hydrator', brand: 'Clinique', category: 'Moisturizer',
    functionalities: ['Hydrating', 'Soothing'],
    description: 'Oil-free water-gel formula that delivers intense hydration lasting 100 hours.',
    ingredients: ['Water','Aloe Barbadensis Leaf Juice','Glycerin','Trehalose','Sodium Hyaluronate','Caffeine','Betaine'],
    image_url: 'https://picsum.photos/seed/clinique-moisturizer/400/400',
    availability: [
      { country: 'HK', price: 399, stores: ['SaSa','Manning','HKTVmall','SASA.com'] },
      { country: 'SG', price: 70,  stores: ['Sephora','Guardian','Shopee','Lazada'] },
      { country: 'MY', price: 130, stores: ['Watsons','Shopee'] },
      { country: 'TW', price: 1300,stores: ['Cosmed','Poya','Momo'] },
      { country: 'JP', price: 5000,stores: ['Sundrug','Rakuten'] },
    ],
  },
  {
    name: 'Anessa Perfect UV Sunscreen SPF50+', brand: 'Anessa', category: 'Sunscreen',
    functionalities: ['Sun Protection'],
    description: "Japan's No.1 sunscreen with Auto Booster Technology. Super waterproof formula.",
    ingredients: ['Water','Cyclopentasiloxane','Ethanol','Ethylhexyl Methoxycinnamate','Titanium Dioxide','Glycerin'],
    image_url: 'https://picsum.photos/seed/anessa-sunscreen/400/400',
    availability: [
      { country: 'HK', price: 218, stores: ['SaSa','Watsons','Manning','HKTVmall','SASA.com'] },
      { country: 'SG', price: 38,  stores: ['Guardian','Watsons','Sephora','Shopee','Lazada'] },
      { country: 'MY', price: 70,  stores: ['Watsons','Guardian','Shopee'] },
      { country: 'TW', price: 680, stores: ['Watsons','Cosmed'] },
      { country: 'JP', price: 2200,stores: ['Matsumoto Kiyoshi','Sundrug','Ain Pharmacy','Rakuten'] },
    ],
  },
  {
    name: 'Ultra Light Daily UV Defense SPF50', brand: 'SkinCeuticals', category: 'Sunscreen',
    functionalities: ['Sun Protection', 'Soothing'],
    description: 'Featherweight mineral sunscreen with invisible finish for all skin tones.',
    ingredients: ['Zinc Oxide (5.7%)','Titanium Dioxide (4.7%)','Water','Cyclopentasiloxane','Glycerin','Niacinamide'],
    image_url: 'https://picsum.photos/seed/skinceuticals-spf/400/400',
    availability: [
      { country: 'HK', price: 698, stores: ['SaSa','SASA.com','LOG-ON Online'] },
      { country: 'SG', price: 122, stores: ['Sephora','Lazada'] },
    ],
  },
  {
    name: 'Watermelon Glow Sleeping Mask', brand: 'Glow Recipe', category: 'Mask',
    functionalities: ['Brightening', 'Hydrating', 'Exfoliating'],
    description: 'Overnight sleeping mask with watermelon extract, hyaluronic acid and AHA.',
    ingredients: ['Water','Citrullus Lanatus Fruit Extract','Glycerin','Sodium Hyaluronate','Lactic Acid','Niacinamide','Xanthan Gum'],
    image_url: 'https://picsum.photos/seed/glow-recipe-mask/400/400',
    availability: [
      { country: 'HK', price: 338, stores: ['SaSa','SASA.com','LOG-ON Online'] },
      { country: 'SG', price: 60,  stores: ['Sephora','Lazada'] },
      { country: 'TW', price: 1100,stores: ['Poya','Momo'] },
    ],
  },
  {
    name: 'Advanced Génifique Eye Cream', brand: 'Lancôme', category: 'Eye Care',
    functionalities: ['Anti-aging', 'Hydrating'],
    description: 'Rejuvenating eye cream targeting dark circles, puffiness and fine lines.',
    ingredients: ['Water','Glycerin','Bifida Ferment Lysate','Lactobacillus Ferment','Caffeine','Niacinamide','Retinol','Panthenol'],
    image_url: 'https://picsum.photos/seed/lancome-eye/400/400',
    availability: [
      { country: 'HK', price: 688, stores: ['SaSa','Manning','HKTVmall','SASA.com'] },
      { country: 'SG', price: 120, stores: ['Sephora','Shopee','Lazada'] },
      { country: 'MY', price: 220, stores: ['Watsons','Shopee'] },
      { country: 'TW', price: 2200,stores: ['Cosmed','Momo'] },
      { country: 'JP', price: 8800,stores: ['Matsumoto Kiyoshi','Rakuten'] },
    ],
  },
  {
    name: 'AHA 30% + BHA 2% Peeling Solution', brand: 'The Ordinary', category: 'Exfoliant',
    functionalities: ['Exfoliating', 'Brightening'],
    description: 'Exfoliating solution with AHA and BHA for radiance and smoother texture.',
    ingredients: ['Glycolic Acid (30%)','Salicylic Acid (2%)','Water','Aloe Barbadensis Leaf Juice','Sodium Hyaluronate Crosspolymer'],
    image_url: 'https://picsum.photos/seed/ordinary-peel/400/400',
    availability: [
      { country: 'HK', price: 128, stores: ['SaSa','Manning','HKTVmall','SASA.com'] },
      { country: 'SG', price: 22,  stores: ['Sephora','Shopee','Lazada'] },
      { country: 'MY', price: 42,  stores: ['Watsons','Shopee'] },
      { country: 'TW', price: 420, stores: ['Cosmed'] },
      { country: 'JP', price: 1500,stores: ['Matsumoto Kiyoshi','Rakuten'] },
    ],
  },
];

// ── Seed function ─────────────────────────────────────────────────────────────
async function seed() {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    console.log('🌱 Seeding countries & stores...');

    // Map code → DB id
    const countryIdMap: Record<string, number> = {};
    const storeIdMap: Record<string, number> = {};  // `country_HK_SaSa_local` → id

    for (const c of COUNTRIES) {
      const res = await client.query<{ id: number }>(
        `INSERT INTO countries (code, name, flag, currency)
         VALUES ($1,$2,$3,$4)
         ON CONFLICT (code) DO UPDATE SET name=EXCLUDED.name
         RETURNING id`,
        [c.code, c.name, c.flag, c.currency]
      );
      const countryId = res.rows[0].id;
      countryIdMap[c.code] = countryId;

      for (const storeName of c.localStores) {
        const sr = await client.query<{ id: number }>(
          `INSERT INTO stores (country_id, name, type)
           VALUES ($1,$2,'local')
           ON CONFLICT (country_id, name, type) DO UPDATE SET name=EXCLUDED.name
           RETURNING id`,
          [countryId, storeName]
        );
        storeIdMap[`${c.code}_${storeName}_local`] = sr.rows[0].id;
      }

      for (const storeName of c.onlineStores) {
        const sr = await client.query<{ id: number }>(
          `INSERT INTO stores (country_id, name, type)
           VALUES ($1,$2,'online')
           ON CONFLICT (country_id, name, type) DO UPDATE SET name=EXCLUDED.name
           RETURNING id`,
          [countryId, storeName]
        );
        storeIdMap[`${c.code}_${storeName}_online`] = sr.rows[0].id;
      }
    }

    console.log('🌱 Seeding products & availability...');

    for (const p of PRODUCTS) {
      const productRes = await client.query<{ id: number }>(
        `INSERT INTO products (name, brand, category, functionalities, description, ingredients, image_url)
         VALUES ($1,$2,$3,$4,$5,$6,$7)
         ON CONFLICT DO NOTHING
         RETURNING id`,
        [p.name, p.brand, p.category, p.functionalities, p.description, p.ingredients, p.image_url]
      );

      if (productRes.rows.length === 0) {
        // Already exists — fetch id
        const existing = await client.query<{ id: number }>(
          'SELECT id FROM products WHERE name=$1 AND brand=$2', [p.name, p.brand]
        );
        if (existing.rows.length === 0) continue;
        productRes.rows.push(existing.rows[0]);
      }

      const productId = productRes.rows[0].id;

      for (const avail of p.availability) {
        const countryId = countryIdMap[avail.country];
        const { currency } = COUNTRIES.find(c => c.code === avail.country)!;

        for (const storeName of avail.stores) {
          // Try local first, then online
          const storeId =
            storeIdMap[`${avail.country}_${storeName}_local`] ??
            storeIdMap[`${avail.country}_${storeName}_online`];

          if (!storeId) {
            console.warn(`  ⚠ Store not found: ${avail.country} / ${storeName}`);
            continue;
          }

          await client.query(
            `INSERT INTO product_availability (product_id, country_id, store_id, price, currency)
             VALUES ($1,$2,$3,$4,$5)
             ON CONFLICT (product_id, country_id, store_id) DO UPDATE
             SET price=EXCLUDED.price, currency=EXCLUDED.currency`,
            [productId, countryId, storeId, avail.price, currency]
          );
        }
      }
    }

    console.log('🌱 Seeding admin user...');
    const adminPassword = process.env.ADMIN_PASSWORD || 'Admin123!';
    const adminEmail = process.env.ADMIN_EMAIL || 'admin@skincare.com';
    const passwordHash = await bcrypt.hash(adminPassword, 12);

    await client.query(
      `INSERT INTO users (email, password_hash, name, role)
       VALUES ($1,$2,'Admin','admin')
       ON CONFLICT (email) DO NOTHING`,
      [adminEmail, passwordHash]
    );

    await client.query('COMMIT');
    console.log('✅ Seed complete!');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ Seed failed:', err);
    throw err;
  } finally {
    client.release();
    await pool.end();
  }
}

seed();
