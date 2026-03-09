"""
PostgreSQL connection using the same DATABASE_URL as the Railway backend.
"""
import os
import psycopg2
import psycopg2.extras
from dotenv import load_dotenv

load_dotenv()


def get_conn():
    """Return a new psycopg2 connection."""
    db_url = os.environ.get("DATABASE_URL")
    if not db_url:
        raise RuntimeError("DATABASE_URL is not set in environment / .env file")
    conn = psycopg2.connect(db_url, cursor_factory=psycopg2.extras.RealDictCursor)
    conn.autocommit = False
    return conn
