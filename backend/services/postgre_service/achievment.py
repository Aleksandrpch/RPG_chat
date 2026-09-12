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


async def get_achievements(character_id: str) -> None:
    """Получает достижения персонажа из базы данных"""
    pool = get_pool()
    async with pool.acquire() as conn:
        await conn.execute(
            """
            SELECT * FROM character_achievement
            WHERE character_id = $1 AND name = $2
            """,
            character_id,
            
        )