import { Router, Request, Response } from "express";
import { body, param, query } from 'express-validator';
import pool from '../config/database';
import { authenticate, requireAdmin } from '../middleware/auth';
import { validate, asyncHandler } from '../middleware/errorHandler';

const router = Router();

// GET /api/products
// Query params: country, category, functionality, brand, maxPrice, search, page, limit
router.get('/', async (req, res, next) => {
  try {
  const {
    country, category, functionality, brand,
    maxPrice, search,
    page = '1', limit = '20',
  } = req.query as Record<string, string>;

  const countryCode = country ? country.toUpperCase() : null;
  const pageNum = Math.max(1, parseInt(page, 10));
  const limitNum = Math.min(100, Math.max(1, parseInt(limit, 10)));
  const offset = (pageNum - 1) * limitNum;

  // Build params and WHERE clauses shared between count + data queries
  const params: unknown[] = [];
  const whereConditions: string[] = [];
  let paramIdx = 1;

  // JOIN to filter by country (replaces correlated subqueries)
  let fromClause: string;
  if (countryCode) {
    params.push(countryCode);
    paramIdx++;
    fromClause = `
      FROM products p
      JOIN product_availability pa ON pa.product_id = p.id
      JOIN countries c ON c.id = pa.country_id AND c.code = $1
      LEFT JOIN reviews r ON r.product_id = p.id
    `;
    if (maxPrice) {
      whereConditions.push(`pa.price <= $${paramIdx++}`);
      params.push(Number(maxPrice));
    }
  } else {
    fromClause = `
      FROM products p
      LEFT JOIN reviews r ON r.product_id = p.id
    `;
  }

  if (category) {
    whereConditions.push(`p.category = $${paramIdx++}`);
    params.push(category);
  }
  if (functionality) {
    whereConditions.push(`$${paramIdx++} = ANY(p.functionalities)`);
    params.push(functionality);
  }
  if (brand) {
    whereConditions.push(`p.brand ILIKE $${paramIdx++}`);
    params.push(`%${brand}%`);
  }
  if (search) {
    whereConditions.push(
      `(p.name ILIKE $${paramIdx} OR p.brand ILIKE $${paramIdx} OR p.description ILIKE $${paramIdx}` +
      ` OR p.name_zh ILIKE $${paramIdx} OR p.brand_zh ILIKE $${paramIdx} OR p.description_zh ILIKE $${paramIdx})`
    );
    params.push(`%${search}%`);
    paramIdx++;
  }

  const whereClause = whereConditions.length > 0 ? `WHERE ${whereConditions.join(' AND ')}` : '';

  // Efficient count via COUNT(DISTINCT p.id) — no subquery wrapping
  const countSql = `SELECT COUNT(DISTINCT p.id) ${fromClause} ${whereClause}`;

  // Data query — JOIN-based price/currency, no correlated subqueries
  const dataSql = `
    SELECT
      p.id, p.name, p.brand, p.category, p.functionalities,
      p.description, p.ingredients, p.image_url, p.created_at,
      COALESCE(AVG(DISTINCT r.rating), 0)::numeric(3,1) AS avg_rating,
      COUNT(DISTINCT r.id)::int AS review_count
      ${countryCode ? ', MIN(pa.price) AS price, MAX(pa.currency) AS currency' : ''}
    ${fromClause}
    ${whereClause}
    GROUP BY p.id
    ORDER BY p.brand, p.name
    LIMIT ${limitNum} OFFSET ${offset}
  `;

  const [countResult, dataResult] = await Promise.all([
    pool.query(countSql, params),
    pool.query(dataSql, params),
  ]);

  res.json({
    total: parseInt(countResult.rows[0].count, 10),
    page: pageNum,
    limit: limitNum,
    products: dataResult.rows,
  });
  } catch (err) { next(err); }
});

// GET /api/products/:id
router.get(
  '/:id',
  [param('id').isInt().withMessage('Product id must be an integer')],
  validate,
  async (req, res, next) => {
    try {
    const { id } = req.params;

    const productResult = await pool.query(
      `SELECT p.*,
        COALESCE(AVG(r.rating), 0)::numeric(3,1) AS avg_rating,
        COUNT(DISTINCT r.id)::int AS review_count
       FROM products p
       LEFT JOIN reviews r ON r.product_id = p.id
       WHERE p.id = $1
       GROUP BY p.id`,
      [id]
    );

    if (productResult.rows.length === 0) {
      res.status(404).json({ message: 'Product not found' });
      return;
    }

    // Fetch availability across all countries
    const availResult = await pool.query(
      `SELECT pa.price, pa.currency,
        c.code AS country_code, c.name AS country_name,
        s.id AS store_id, s.name AS store_name, s.type AS store_type
       FROM product_availability pa
       JOIN countries c ON c.id = pa.country_id
       JOIN stores s ON s.id = pa.store_id
       WHERE pa.product_id = $1
       ORDER BY c.code, s.type, s.name`,
      [id]
    );

    // Group by country
    const availabilityByCountry: Record<string, { price: number; currency: string; stores: { id: number; name: string; type: string }[] }> = {};
    for (const row of availResult.rows) {
      if (!availabilityByCountry[row.country_code]) {
        availabilityByCountry[row.country_code] = {
          price: row.price,
          currency: row.currency,
          stores: [],
        };
      }
      availabilityByCountry[row.country_code].stores.push({
        id: row.store_id,
        name: row.store_name,
        type: row.store_type,
      });
    }

    res.json({ product: productResult.rows[0], availability: availabilityByCountry });
    } catch (err) { next(err); }
  }
);

// POST /api/products  (admin)
router.post(
  '/',
  authenticate,
  requireAdmin,
  [
    body('name').trim().notEmpty(),
    body('brand').trim().notEmpty(),
    body('category').trim().notEmpty(),
    body('functionalities').isArray(),
    body('description').trim().notEmpty(),
    body('ingredients').isArray(),
    body('image_url').optional().isURL(),
    body('name_zh').optional().trim(),
    body('brand_zh').optional().trim(),
    body('category_zh').optional().trim(),
    body('functionalities_zh').optional().isArray(),
    body('description_zh').optional().trim(),
    body('ingredients_zh').optional().isArray(),
  ],
  validate,
  asyncHandler(async (req, res) => {
    const {
      name, brand, category, functionalities, description, ingredients, image_url,
      name_zh = '', brand_zh = '', category_zh = '', functionalities_zh = [],
      description_zh = '', ingredients_zh = [],
    } = req.body as Record<string, unknown>;
    const result = await pool.query(
      `INSERT INTO products
         (name, brand, category, functionalities, description, ingredients, image_url,
          name_zh, brand_zh, category_zh, functionalities_zh, description_zh, ingredients_zh)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13) RETURNING *`,
      [name, brand, category, functionalities, description, ingredients, image_url,
       name_zh, brand_zh, category_zh, functionalities_zh, description_zh, ingredients_zh]
    );
    res.status(201).json({ product: result.rows[0] });
  })
);

// PUT /api/products/:id  (admin)
router.put(
  '/:id',
  authenticate,
  requireAdmin,
  [param('id').isInt()],
  validate,
  asyncHandler(async (req, res) => {
    const { id } = req.params;
    const fields = req.body as Record<string, unknown>;

    const allowed = [
      'name','brand','category','functionalities','description','ingredients','image_url',
      'name_zh','brand_zh','category_zh','functionalities_zh','description_zh','ingredients_zh',
    ];
    const setClauses: string[] = [];
    const values: unknown[] = [];
    let idx = 1;

    for (const key of allowed) {
      if (key in fields) {
        setClauses.push(`${key} = $${idx++}`);
        values.push(fields[key]);
      }
    }

    if (setClauses.length === 0) {
      res.status(400).json({ message: 'No valid fields to update' });
      return;
    }

    values.push(id);
    const result = await pool.query(
      `UPDATE products SET ${setClauses.join(', ')} WHERE id = $${idx} RETURNING *`,
      values
    );

    if (result.rows.length === 0) {
      res.status(404).json({ message: 'Product not found' });
      return;
    }

    res.json({ product: result.rows[0] });
  })
);

// DELETE /api/products/:id  (admin)
router.delete(
  '/:id',
  authenticate,
  requireAdmin,
  [param('id').isInt()],
  validate,
  asyncHandler(async (req, res) => {
    const result = await pool.query('DELETE FROM products WHERE id=$1 RETURNING id', [req.params.id]);
    if (result.rows.length === 0) {
      res.status(404).json({ message: 'Product not found' });
      return;
    }
    res.status(204).send();
  })
);

export default router;
