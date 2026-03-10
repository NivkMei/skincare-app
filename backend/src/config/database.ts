import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

// Lazy singleton — evaluated at first query, not at import time.
// This allows Railway (and other platforms) to inject DATABASE_URL
// as a runtime env var without crashing during startup.
let _pool: Pool | null = null;

function getPool(): Pool {
  if (!_pool) {
    if (!process.env.DATABASE_URL) {
      throw new Error('DATABASE_URL environment variable is required');
    }
    _pool = new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
      connectionTimeoutMillis: 15000,
      idleTimeoutMillis: 60000,
      max: 10,
      options: '-c statement_timeout=12000',
    });
    // Log the error but do NOT exit — a transient connection error should not
    // crash the server and cause Railway to enter a restart loop.
    _pool.on('error', (err) => {
      console.error('Unexpected PostgreSQL client error (non-fatal):', err.message);
    });
  }
  return _pool;
}

// Proxy object so callers can use `pool.query(...)` unchanged.
const pool = new Proxy({} as Pool, {
  get(_target, prop) {
    return (getPool() as any)[prop];
  },
});

export default pool;
