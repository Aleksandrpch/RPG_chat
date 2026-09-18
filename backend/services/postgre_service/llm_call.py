import json
from uuid import UUID

from .postgre_conn import get_pool


async def save_llm_call(
    *,
    chat_id: str,
    component: str,
    model: str,
    content: dict,
    input_tokens: int,
    output_tokens: int,
    total_tokens: int,
    cached_tokens: int = 0,
    reasoning_tokens: int = 0,
    latency_ms: int,
    success: bool,
) -> str:
    pool = get_pool()

    async with pool.acquire() as conn:
        call_id = await conn.fetchval(
            """
            INSERT INTO llm_call (
                chat_id,
                component,
                model,
                content,
                input_tokens,
                cached_tokens,
                output_tokens,
                reasoning_tokens,
                total_tokens,
                latency_ms,
                success
            )
            VALUES (
                $1, $2, $3, $4, $5, $6,
                $7, $8, $9, $10, $11
            )
            RETURNING id
            """,
            UUID(str(chat_id)),
            component,
            model,
            json.dumps(content, ensure_ascii=False),
            input_tokens,
            cached_tokens,
            output_tokens,
            reasoning_tokens,
            total_tokens,
            latency_ms,
            success,
        )

    return str(call_id)