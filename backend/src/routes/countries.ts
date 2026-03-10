import { Router, Request, Response } from "express";
import { param } from 'express-validator';
import pool from '../config/database';
import { validate, asyncHandler } from '../middleware/errorHandler';

const router = Router();

// GET /api/countries
router.get('/', asyncHandler(async (_req: Request, res: Response) => {
  const result = await pool.query(
    'SELECT id, code, name, flag, currency FROM countries ORDER BY name'
  );
  res.json({ countries: result.rows });
}));

// GET /api/countries/:code
router.get(
  '/:code',
  [param('code').trim().isLength({ min: 2, max: 5 })],
  validate,
  asyncHandler(async (req, res) => {
    const code = req.params.code.toUpperCase();
    const result = await pool.query(
      'SELECT id, code, name, flag, currency FROM countries WHERE code=$1',
      [code]
    );
    if (result.rows.length === 0) {
      res.status(404).json({ message: 'Country not found' });
      return;
    }
    res.json({ country: result.rows[0] });
  })
);

// GET /api/countries/:code/stores
router.get(
  '/:code/stores',
  [param('code').trim().isLength({ min: 2, max: 5 })],
  validate,
  asyncHandler(async (req, res) => {
    const code = req.params.code.toUpperCase();
    const result = await pool.query(
      `SELECT s.id, s.name, s.type, s.website_url
       FROM stores s
       JOIN countries c ON c.id = s.country_id
       WHERE c.code = $1
       ORDER BY s.type, s.name`,
      [code]
    );
    res.json({ stores: result.rows });
  })
);

export default router;
