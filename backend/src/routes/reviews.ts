import { Router, Request, Response } from 'express';
import { body, param } from 'express-validator';
import pool from '../config/database';
import { authenticate, requireAdmin } from '../middleware/auth';
import { validate } from '../middleware/errorHandler';

const router = Router({ mergeParams: true });

// GET /api/products/:productId/reviews
router.get(
  '/',
  [param('productId').isInt()],
  validate,
  async (req, res) => {
    const { productId } = req.params;

    const result = await pool.query(
      `SELECT r.id, r.rating, r.comment, r.created_at, r.updated_at,
              u.name AS user_name
       FROM reviews r
       JOIN users u ON u.id = r.user_id
       WHERE r.product_id = $1
       ORDER BY r.created_at DESC`,
      [productId]
    );

    const aggregate = await pool.query(
      `SELECT COALESCE(AVG(rating), 0)::numeric(3,1) AS avg_rating,
              COUNT(*)::int AS review_count
       FROM reviews WHERE product_id = $1`,
      [productId]
    );

    res.json({ reviews: result.rows, ...aggregate.rows[0] });
  }
);

// POST /api/products/:productId/reviews  (authenticated, one per user)
router.post(
  '/',
  authenticate,
  [
    param('productId').isInt(),
    body('rating').isInt({ min: 1, max: 5 }).withMessage('Rating must be 1-5'),
    body('comment').optional().trim().isLength({ max: 2000 }),
  ],
  validate,
  async (req, res) => {
    const { productId } = req.params;
    const { rating, comment } = req.body as { rating: number; comment?: string };
    const userId = req.user!.id;

    // Check product exists
    const product = await pool.query('SELECT id FROM products WHERE id=$1', [productId]);
    if (product.rows.length === 0) {
      res.status(404).json({ message: 'Product not found' });
      return;
    }

    const result = await pool.query(
      `INSERT INTO reviews (user_id, product_id, rating, comment)
       VALUES ($1,$2,$3,$4)
       ON CONFLICT (user_id, product_id)
       DO UPDATE SET rating=EXCLUDED.rating, comment=EXCLUDED.comment, updated_at=NOW()
       RETURNING *`,
      [userId, productId, rating, comment ?? null]
    );

    res.status(201).json({ review: result.rows[0] });
  }
);

// PUT /api/reviews/:id  (own review)
router.put(
  '/:id',
  authenticate,
  [
    param('id').isInt(),
    body('rating').optional().isInt({ min: 1, max: 5 }),
    body('comment').optional().trim().isLength({ max: 2000 }),
  ],
  validate,
  async (req, res) => {
    const { id } = req.params;
    const userId = req.user!.id;
    const isAdmin = req.user!.role === 'admin';

    const existing = await pool.query('SELECT user_id FROM reviews WHERE id=$1', [id]);
    if (existing.rows.length === 0) {
      res.status(404).json({ message: 'Review not found' });
      return;
    }
    if (!isAdmin && existing.rows[0].user_id !== userId) {
      res.status(403).json({ message: 'Forbidden' });
      return;
    }

    const { rating, comment } = req.body as { rating?: number; comment?: string };
    const result = await pool.query(
      `UPDATE reviews
       SET rating = COALESCE($1, rating),
           comment = COALESCE($2, comment),
           updated_at = NOW()
       WHERE id = $3 RETURNING *`,
      [rating ?? null, comment ?? null, id]
    );

    res.json({ review: result.rows[0] });
  }
);

// DELETE /api/reviews/:id  (own review or admin)
router.delete(
  '/:id',
  authenticate,
  [param('id').isInt()],
  validate,
  async (req, res) => {
    const { id } = req.params;
    const userId = req.user!.id;
    const isAdmin = req.user!.role === 'admin';

    const existing = await pool.query('SELECT user_id FROM reviews WHERE id=$1', [id]);
    if (existing.rows.length === 0) {
      res.status(404).json({ message: 'Review not found' });
      return;
    }
    if (!isAdmin && existing.rows[0].user_id !== userId) {
      res.status(403).json({ message: 'Forbidden' });
      return;
    }

    await pool.query('DELETE FROM reviews WHERE id=$1', [id]);
    res.status(204).send();
  }
);

export default router;
