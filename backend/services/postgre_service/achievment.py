async def save_achievement(
    character_id: str,
    name: str,
    description: str | None = None
    ) -> None:
    """Сохраняет достижение персонажа в базе данных"""
    pool = get_pool()
    async with pool.acquire() as conn:
        await conn.execute(
            """
            INSERT INTO character_achievement (character_id, name, description)
            VALUES ($1, $2, $3)
            ON CONFLICT (character_id, name)
            DO UPDATE SET description = EXCLUDED.description
            """,
            character_id,
            name,
            description,
        )
    return {
        "status": "created" if row is not None else "already_exists",
        "name": name,
    }
    


async def get_achievements(character_id: str) -> None:
    """Получает достижения персонажа из базы данных"""
    pool = get_pool()
    async with pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT id, character_id, name, description, earned_at 
            FROM character_achievement
            WHERE character_id = $1
            ORDER BY earned_at DESC
            """,
            character_id,
        )
    return [dict(row) for row in rows]