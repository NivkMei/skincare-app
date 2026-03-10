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
    name_zh: '溫和泡沫潔面乳', brand_zh: 'CeraVe', category_zh: '潔面乳',
    functionalities_zh: ['修護屏障', '舒緩鎮靜'],
    description_zh: '專為保留肌膚天然屏障而設計的溫和潔面乳，有效去除污垢雜質。',
    ingredients_zh: ['水','甘油','菸鹼醯胺','神經醯胺NP','神經醯胺AP','神經醯胺EOP','膽固醇','植物鞘氨醇'],
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
    name_zh: '低pH早安啫喱潔面乳', brand_zh: 'COSRX', category_zh: '潔面乳',
    functionalities_zh: ['抗痘控油', '去角質'],
    description_zh: '含有BHA的低pH值潔面乳，溫和去除死皮細胞及多餘油脂。',
    ingredients_zh: ['水','椰油醯胺丙基甜菜鹼','丁二醇','茶樹油','柳樹皮提取物','檸檬酸','尿囊素'],
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
    name_zh: '昆布茶精華化妝水', brand_zh: 'TATCHA', category_zh: '化妝水',
    functionalities_zh: ['深層保濕', '美白提亮'],
    description_zh: '三合一化妝水，富含日本超級食物成分，撫平、提亮並滋潤肌膚。',
    ingredients_zh: ['水','甘油','蘿蔔根發酵液','酵母發酵液','山茶花葉提取物','菸鹼醯胺','透明質酸鈉'],
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
    name_zh: '無酒精玫瑰化妝水', brand_zh: 'Thayers', category_zh: '化妝水',
    functionalities_zh: ['深層保濕', '舒緩鎮靜'],
    description_zh: '不含酒精的爽膚水，含有金縷梅及玫瑰花水成分。',
    ingredients_zh: ['水','蘆薈葉汁','金縷梅提取物','玫瑰花水','甘油','泛醇','尿囊素'],
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
    name_zh: '2%玻尿酸+B5精華液', brand_zh: 'The Ordinary', category_zh: '精華液',
    functionalities_zh: ['深層保濕', '修護屏障'],
    description_zh: '結合多種分子量玻尿酸與維生素B5的複合保濕精華。',
    ingredients_zh: ['水','透明質酸鈉','交聯透明質酸鈉','泛醇','甘油'],
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
    name_zh: '10%菸鹼醯胺+1%鋅精華液', brand_zh: 'The Ordinary', category_zh: '精華液',
    functionalities_zh: ['美白提亮', '抗痘控油'],
    description_zh: '高濃度菸鹼醯胺複合鋅配方，有效淡化瑕疵並平衡油脂分泌。',
    ingredients_zh: ['水','菸鹼醯胺','戊二醇','PCA鋅','二甲基異山梨醇','黃原膠'],
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
    name_zh: '維生素C亮白精華液', brand_zh: 'SkinCeuticals', category_zh: '精華液',
    functionalities_zh: ['美白提亮', '抗老緊緻'],
    description_zh: 'CE Ferulic — 含15%純維生素C、1%維生素E及0.5%阿魏酸的抗氧化精華。',
    ingredients_zh: ['水','左旋維生素C (15%)','生育酚 (1%)','阿魏酸 (0.5%)','甘油','丙二醇'],
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
    name_zh: '神經醯胺保濕霜', brand_zh: 'CeraVe', category_zh: '保濕霜',
    functionalities_zh: ['深層保濕', '修護屏障'],
    description_zh: '由皮膚科醫生共同研發，含三種必需神經醯胺，有效修護及保護肌膚屏障。',
    ingredients_zh: ['水','甘油','鯨蠟硬脂醇','神經醯胺NP','神經醯胺AP','神經醯胺EOP','膽固醇','菸鹼醯胺','透明質酸鈉'],
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
    name_zh: '水磁場全天候自動補水凝露', brand_zh: 'Clinique', category_zh: '保濕霜',
    functionalities_zh: ['深層保濕', '舒緩鎮靜'],
    description_zh: '無油水凝膠配方，持續提供長達100小時的高效保濕。',
    ingredients_zh: ['水','蘆薈葉汁','甘油','海藻糖','透明質酸鈉','咖啡因','甜菜鹼'],
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
    name_zh: '安耐曬完美UV防曬乳SPF50+', brand_zh: '安耐曬', category_zh: '防曬乳',
    functionalities_zh: ['防曬保護'],
    description_zh: '日本銷售冠軍防曬乳，搭載Auto Booster科技，超強防水配方。',
    ingredients_zh: ['水','環戊矽氧烷','酒精','甲氧基肉桂酸乙基己酯','二氧化鈦','甘油'],
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
    name_zh: '超輕盈全天候礦物防曬SPF50', brand_zh: 'SkinCeuticals', category_zh: '防曬乳',
    functionalities_zh: ['防曬保護', '舒緩鎮靜'],
    description_zh: '羽量級礦物防曬，無色透明妝感，適合所有膚色使用。',
    ingredients_zh: ['氧化鋅 (5.7%)','二氧化鈦 (4.7%)','水','環戊矽氧烷','甘油','菸鹼醯胺'],
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
    name_zh: '西瓜發光睡眠面膜', brand_zh: 'Glow Recipe', category_zh: '面膜',
    functionalities_zh: ['美白提亮', '深層保濕', '去角質'],
    description_zh: '含西瓜萃取物、玻尿酸及AHA的夜間睡眠面膜，照亮暗沉肌膚。',
    ingredients_zh: ['水','西瓜果提取物','甘油','透明質酸鈉','乳酸','菸鹼醯胺','黃原膠'],
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
    name_zh: '超進化精華眼霜', brand_zh: 'Lancôme', category_zh: '眼霜',
    functionalities_zh: ['抗老緊緻', '深層保濕'],
    description_zh: '針對黑眼圈、浮腫及細紋的青春活化眼霜。',
    ingredients_zh: ['水','甘油','雙歧桿菌發酵產物','乳酸桿菌發酵液','咖啡因','菸鹼醯胺','視黃醇','泛醇'],
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
    name_zh: 'AHA 30% + BHA 2%去角質液', brand_zh: 'The Ordinary', category_zh: '去角質',
    functionalities_zh: ['去角質', '美白提亮'],
    description_zh: '含AHA及BHA的煥膚去角質精華，有效提亮膚色並改善肌膚紋理。',
    ingredients_zh: ['乙醇酸 (30%)','水楊酸 (2%)','水','蘆薈葉汁','交聯透明質酸鈉'],
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
        `INSERT INTO products
           (name, brand, category, functionalities, description, ingredients, image_url,
            name_zh, brand_zh, category_zh, functionalities_zh, description_zh, ingredients_zh)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
         ON CONFLICT DO NOTHING
         RETURNING id`,
        [
          p.name, p.brand, p.category, p.functionalities, p.description, p.ingredients, p.image_url,
          p.name_zh ?? '', p.brand_zh ?? '', p.category_zh ?? '',
          p.functionalities_zh ?? [], p.description_zh ?? '', p.ingredients_zh ?? [],
        ]
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
