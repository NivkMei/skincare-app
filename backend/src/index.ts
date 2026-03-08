import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import pool from './config/database';
import { errorHandler } from './middleware/errorHandler';
import authRouter from './routes/auth';
import productsRouter from './routes/products';
import countriesRouter from './routes/countries';
import favoritesRouter from './routes/favorites';
import reviewsRouter from './routes/reviews';

dotenv.config();

const app = express();
const PORT = parseInt(process.env.PORT || '3000', 10);

// ── Middleware ────────────────────────────────────────────────────────────────
app.use(cors({
  origin: process.env.CORS_ORIGINS?.split(',') ?? '*',
  credentials: true,
}));
app.use(express.json());

// ── Routes ────────────────────────────────────────────────────────────────────
app.use('/api/auth',       authRouter);
app.use('/api/products',   productsRouter);
app.use('/api/countries',  countriesRouter);
app.use('/api/favorites',  favoritesRouter);

// Reviews are mounted both as a sub-route of products AND standalone
app.use('/api/products/:productId/reviews', reviewsRouter);
app.use('/api/reviews',    reviewsRouter);

// Health check
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', ts: new Date().toISOString() });
});

// ── Global error handler ──────────────────────────────────────────────────────
app.use(errorHandler);

// ── Start ─────────────────────────────────────────────────────────────────────
async function start() {
  // Verify DB connection before accepting traffic
  try {
    await pool.query('SELECT 1');
    console.log('✅ Database connected');
  } catch (err) {
    console.error('❌ Cannot connect to database:', err);
    process.exit(1);
  }

  app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
  });
}

start();
