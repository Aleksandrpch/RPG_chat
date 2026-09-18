async def save_skill(
    character_id: str,
    name: str,
    description: str | None = None,
) -> dict[str, str]:
    """Добавляет навык, если такого названия ещё нет."""
    pool = get_pool()

    async with pool.acquire() as conn:
        row = await conn.fetchrow(
            """
            INSERT INTO character_skill (
                character_id, name, description
            )
            VALUES ($1, $2, $3)
            ON CONFLICT (character_id, name) DO NOTHING
            RETURNING name
            """,
            character_id,
            name,
            description,
        )

    return {
        "status": "created" if row is not None else "already_exists",
        "name": name,
    }

        
async def get_skills(character_id: str) -> None:
    """Получает навыки  персонажа из базы данных"""
    pool = get_pool()
    async with pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT * FROM character_skill
            WHERE character_id = $1
            ORDER BY earned_at DESC
            """,
            character_id,
        )
    return [dict(row) for row in rows]