import asyncpg
import os

from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = (
    f"postgresql://{os.getenv('DB_USER')}:"
    f"{os.getenv('DB_PASSWORD')}@"
    f"{os.getenv('DB_HOST')}:"
    f"{os.getenv('DB_PORT')}/"
    f"{os.getenv('DB_NAME')}"
)

pool: asyncpg.Pool | None = None


async def init_db():
    global pool
    if pool is None:
        pool = await asyncpg.create_pool(
            DATABASE_URL,
            min_size=2,
            max_size=10,
        )

async def get_pool(): 
    if pool is None:
        raise RuntimeError("Database not initialized")
    return pool


async def close_db():
    if pool:
        await pool.close()