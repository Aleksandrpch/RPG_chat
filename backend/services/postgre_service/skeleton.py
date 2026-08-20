import asyncpg
from postgre_conn import get_pool


async def get_skeleton(skeleton_id: str) -> dict | None:
    pool=get_pool
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


async def save_skeleton(skelet: dict) -> None:
    pool=get_pool()
    async with pool.acquire() as conn:
        row= await conn.execute(
            """
            INSERT INTO skeleton (id, skelet)
            VALUES ($1, $2::jsonb)
            ON CONFLICT (id)
            DO UPDATE SET skelet = EXCLUDED.skelet
            """,
            skelet,
        ) 
    return row['id']