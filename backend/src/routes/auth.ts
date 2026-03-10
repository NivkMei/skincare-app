import { Router, Request, Response } from "express";
import { body } from 'express-validator';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import pool from '../config/database';
import { validate, asyncHandler } from '../middleware/errorHandler';
import { authenticate } from '../middleware/auth';
import { User } from '../types/models';

const router = Router();

// POST /api/auth/register
router.post(
  '/register',
  [
    body('name').trim().notEmpty().withMessage('Name is required'),
    body('email').isEmail().normalizeEmail().withMessage('Valid email required'),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  ],
  validate,
  asyncHandler(async (req, res) => {
    const { name, email, password } = req.body as { name: string; email: string; password: string };

    const existing = await pool.query('SELECT id FROM users WHERE email=$1', [email]);
    if (existing.rows.length > 0) {
      res.status(409).json({ message: 'Email already registered' });
      return;
    }

    const passwordHash = await bcrypt.hash(password, 12);
    const result = await pool.query<User>(
      `INSERT INTO users (email, password_hash, name, role)
       VALUES ($1,$2,$3,'user') RETURNING id, email, name, role, created_at`,
      [email, passwordHash, name]
    );

    const user = result.rows[0];
    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET as string,
      { expiresIn: (process.env.JWT_EXPIRES_IN || '7d') as any }
    );

    res.status(201).json({ token, user });
  })
);

// POST /api/auth/login
router.post(
  '/login',
  [
    body('email').isEmail().normalizeEmail().withMessage('Valid email required'),
    body('password').notEmpty().withMessage('Password is required'),
  ],
  validate,
  asyncHandler(async (req, res) => {
    const { email, password } = req.body as { email: string; password: string };

    const result = await pool.query<User & { password_hash: string }>(
      'SELECT id, email, name, role, password_hash, created_at FROM users WHERE email=$1',
      [email]
    );

    if (result.rows.length === 0) {
      res.status(401).json({ message: 'Invalid credentials' });
      return;
    }

    const user = result.rows[0];
    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) {
      res.status(401).json({ message: 'Invalid credentials' });
      return;
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET as string,
      { expiresIn: (process.env.JWT_EXPIRES_IN || '7d') as any }
    );

    const { password_hash, ...safeUser } = user;
    res.json({ token, user: safeUser });
  })
);

// GET /api/auth/me
router.get('/me', authenticate, asyncHandler(async (req, res) => {
  const result = await pool.query<User>(
    'SELECT id, email, name, role, created_at FROM users WHERE id=$1',
    [req.user!.id]
  );

  if (result.rows.length === 0) {
    res.status(404).json({ message: 'User not found' });
    return;
  }

  res.json({ user: result.rows[0] });
}));

export default router;
