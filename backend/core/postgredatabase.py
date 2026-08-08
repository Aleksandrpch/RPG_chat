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

    pool = await asyncpg.create_pool(
        DATABASE_URL,
        min_size=2,
        max_size=10,
    )


async def close_db():
    if pool:
        await pool.close()


async def get_skeleton(skeleton_id: str) -> dict | None:
    async with pool.acquire() as conn:
        row = await conn.fetchrow(
            """
            SELECT skeleton
            FROM skeleton
            WHERE id = $1
            """,
            skeleton_id,
        )

        return dict(row["skeleton"]) if row else None


async def save_skeleton(skeleton_id: str, skelet: dict) -> None:
    async with pool.acquire() as conn:
        await conn.execute(
            """
            INSERT INTO skeleton (id, skelet)
            VALUES ($1, $2::jsonb)
            ON CONFLICT (id)
            DO UPDATE SET skelet = EXCLUDED.skelet
            """,
            skeleton_id,
            skelet,
        )