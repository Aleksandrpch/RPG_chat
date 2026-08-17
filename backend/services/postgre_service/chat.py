import asyncpg
from postgre_conn import get_pool
from core.schemas import ChatSchema



async def create_chat(chat: ChatSchema) -> str:
    """Создаёт чат (игровую сессию) и возвращает его ID."""
    pool = get_pool()
    async with pool.acquire() as conn:
        row = await conn.fetchrow(
            """
            INSERT INTO chat (character_id, skeleton_id, name, created_at, last_played:)
            VALUES ($1, $2, $3, NOW(),NOW())
            RETURNING id
            """,
            chat.character_id,
            chat.skeleton_id,
            chat.name,
        )
        chat_id = row["id"]
        return chat_id
