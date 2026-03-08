import { Router, Request, Response } from "express";
import { body, param, query } from 'express-validator';
import pool from '../config/database';
import { authenticate, requireAdmin } from '../middleware/auth';
import { validate } from '../middleware/errorHandler';

const router = Router();

// GET /api/products
// Query params: country, category, functionality, brand, maxPrice, search, page, limit
router.get('/', async (req, res) => {
  const {
    country, category, functionality, brand,
    maxPrice, search,
    page = '1', limit = '20',
  } = req.query as Record<string, string>;

  const params: unknown[] = [];
  const havingConditions: string[] = [];
  const whereConditions: string[] = [];
  let paramIdx = 1;

  const countryCode = country ? country.toUpperCase() : null;

  // Base SELECT — include price/currency via subquery when country is specified
  let sql = `
    SELECT
      p.id, p.name, p.brand, p.category, p.functionalities,
      p.description, p.ingredients, p.image_url, p.created_at,
      COALESCE(AVG(r.rating), 0)::numeric(3,1) AS avg_rating,
      COUNT(DISTINCT r.id)::int AS review_count
      ${countryCode ? `, (
          SELECT MIN(pa_price.price) FROM product_availability pa_price
          JOIN countries c_price ON c_price.id = pa_price.country_id
          WHERE pa_price.product_id = p.id AND c_price.code = $${paramIdx}
        ) AS price,
        (
          SELECT MAX(pa_cur.currency) FROM product_availability pa_cur
          JOIN countries c_cur ON c_cur.id = pa_cur.country_id
          WHERE pa_cur.product_id = p.id AND c_cur.code = $${paramIdx}
        ) AS currency` : ''}
    FROM products p
    LEFT JOIN reviews r ON r.product_id = p.id
  `;

  if (countryCode) {
    params.push(countryCode);
    paramIdx++;
    // Filter to only products available in this country
    whereConditions.push(`EXISTS (
      SELECT 1 FROM product_availability pa_f
      JOIN countries c_f ON c_f.id = pa_f.country_id
      WHERE pa_f.product_id = p.id AND c_f.code = $${paramIdx - 1}
      ${maxPrice ? `AND pa_f.price <= $${paramIdx}` : ''}
    )`);
    if (maxPrice) {
      params.push(Number(maxPrice));
      paramIdx++;
    }
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
    whereConditions.push(`(p.name ILIKE $${paramIdx} OR p.brand ILIKE $${paramIdx} OR p.description ILIKE $${paramIdx})`);
    params.push(`%${search}%`);
    paramIdx++;
  }

  if (whereConditions.length > 0) sql += ` WHERE ${whereConditions.join(' AND ')}`;
  sql += ` GROUP BY p.id`;

  // Pagination
  const pageNum = Math.max(1, parseInt(page, 10));
  const limitNum = Math.min(100, Math.max(1, parseInt(limit, 10)));
  const offset = (pageNum - 1) * limitNum;

  const countSql = `SELECT COUNT(*) FROM (${sql}) sub`;
  const [countResult, dataResult] = await Promise.all([
    pool.query(countSql, params),
    pool.query(sql + ` ORDER BY p.brand, p.name LIMIT ${limitNum} OFFSET ${offset}`, params),
  ]);

  res.json({
    total: parseInt(countResult.rows[0].count, 10),
    page: pageNum,
    limit: limitNum,
    products: dataResult.rows,
  });
});

// GET /api/products/:id
router.get(
  '/:id',
  [param('id').isInt().withMessage('Product id must be an integer')],
  validate,
  async (req, res) => {
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
  ],
  validate,
  async (req, res) => {
    const { name, brand, category, functionalities, description, ingredients, image_url } = req.body as Record<string, unknown>;
    const result = await pool.query(
      `INSERT INTO products (name, brand, category, functionalities, description, ingredients, image_url)
       VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *`,
      [name, brand, category, functionalities, description, ingredients, image_url]
    );
    res.status(201).json({ product: result.rows[0] });
  }
);

// PUT /api/products/:id  (admin)
router.put(
  '/:id',
  authenticate,
  requireAdmin,
  [param('id').isInt()],
  validate,
  async (req, res) => {
    const { id } = req.params;
    const fields = req.body as Record<string, unknown>;

    const allowed = ['name','brand','category','functionalities','description','ingredients','image_url'];
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
  }
);

// DELETE /api/products/:id  (admin)
router.delete(
  '/:id',
  authenticate,
  requireAdmin,
  [param('id').isInt()],
  validate,
  async (req, res) => {
    const result = await pool.query('DELETE FROM products WHERE id=$1 RETURNING id', [req.params.id]);
    if (result.rows.length === 0) {
      res.status(404).json({ message: 'Product not found' });
      return;
    }
    res.status(204).send();
  }
);

export default router;
