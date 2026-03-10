import { Router, Response } from 'express';
import { param } from 'express-validator';
import pool from '../config/database';
import { authenticate } from '../middleware/auth';
import { validate, asyncHandler } from '../middleware/errorHandler';

const router = Router();

// All favorites routes require authentication
router.use(authenticate);

// GET /api/favorites
router.get('/', asyncHandler(async (req, res) => {
  const result = await pool.query(
    `SELECT p.id, p.name, p.brand, p.category, p.functionalities,
            p.description, p.name_zh, p.brand_zh, p.category_zh,
            p.functionalities_zh, p.description_zh, p.image_url,
            COALESCE(AVG(r.rating), 0)::numeric(3,1) AS avg_rating,
            COUNT(DISTINCT r.id)::int AS review_count,
            BOOL_OR(s.type = 'online') AS available_online,
            BOOL_OR(s.type = 'local')  AS available_in_store,
            MIN(pa.price) AS min_price,
            MAX(pa.price) AS max_price,
            MAX(pa.currency) AS currency,
            f.created_at AS favorited_at
     FROM favorites f
     JOIN products p ON p.id = f.product_id
     LEFT JOIN reviews r ON r.product_id = p.id
     LEFT JOIN product_availability pa ON pa.product_id = p.id
     LEFT JOIN stores s ON s.id = pa.store_id
     WHERE f.user_id = $1
     GROUP BY p.id, f.created_at
     ORDER BY f.created_at DESC`,
    [req.user!.id]
  );
  res.json({ favorites: result.rows });
}));

// POST /api/favorites/:productId
router.post(
  '/:productId',
  [param('productId').isInt()],
  validate,
  asyncHandler(async (req, res) => {
    const productId = parseInt(req.params.productId, 10);
    const userId = req.user!.id;

    // Check product exists
    const product = await pool.query('SELECT id FROM products WHERE id=$1', [productId]);
    if (product.rows.length === 0) {
      res.status(404).json({ message: 'Product not found' });
      return;
    }

    await pool.query(
      `INSERT INTO favorites (user_id, product_id) VALUES ($1,$2)
       ON CONFLICT (user_id, product_id) DO NOTHING`,
      [userId, productId]
    );

    res.status(204).send();
  })
);

// DELETE /api/favorites/:productId
router.delete(
  '/:productId',
  [param('productId').isInt()],
  validate,
  asyncHandler(async (req, res) => {
    await pool.query(
      'DELETE FROM favorites WHERE user_id=$1 AND product_id=$2',
      [req.user!.id, req.params.productId]
    );
    res.status(204).send();
  })
);

export default router;
