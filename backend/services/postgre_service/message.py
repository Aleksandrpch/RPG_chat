from datetime import datetime
from typing import Any
from postgre_conn import get_pool


async def save_message(
    chat_id: str,
    sender_id: str,
    sender_name: str,
    sender_type: str,  # 'NPC', 'Narrator', 'Hero'
    content: str,
    sender_avatar_url: str | None = None,
    model_id: str | None = None,
    tokens: int | None = None,
    cost: float | None = None,
) -> str:
    """Сохраняет сообщение в историю чата."""
    pool = get_pool()
    async with pool.acquire() as conn:
        row = await conn.fetchrow(
            """
            INSERT INTO message (
                chat_id,
                sender_id,
                sender_name,
                sender_type,
                sender_avatar_url,
                content,
                model_id,
                tokens,
                cost
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            RETURNING id
            """,
            chat_id,
            sender_id,
            sender_name,
            sender_type,
            sender_avatar_url,
            content,
            model_id,
            tokens,
            cost,
        )
        return row["id"]


async def get_chat_history(
    chat_id: str,
    limit: int = 50,
    offset: int = 0,
) -> list[dict[str, Any]]:
    """
    Возвращает историю сообщений чата.
    """
    pool = get_pool()
    async with pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                id,
                sender_id,
                sender_name,
                sender_type,
                sender_avatar_url,
                content,
                timestamp
            FROM message
            WHERE chat_id = $1
            ORDER BY timestamp ASC
            LIMIT $2
            OFFSET $3
            """,
            chat_id,
            limit,
            offset,
        )
        return [dict(row) for row in rows]


async def get_last_messages(
    chat_id: str,
    limit: int = 10,
) -> list[dict[str, Any]]:
    """Возвращает последние N сообщений."""
    pool = get_pool()
    async with pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                sender_id,
                sender_name,
                sender_type,
                sender_avatar_url,
                content,
                timestamp
            FROM message
            WHERE chat_id = $1
            ORDER BY timestamp ASC
            LIMIT $2
            """,
            chat_id,
            limit,
        )
        return [dict(row) for row in rows]  