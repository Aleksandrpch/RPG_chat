async def save_skill(
    character_id: str, 
    name: str,
    description: str | None = None,
    ) -> None:
    """Сохраняет навык персонажа в базе данных"""
    pool = get_pool()
    async with pool.acquire() as conn:
        await conn.execute(
            """
            INSERT INTO character_skill (character_id, name, description)
            VALUES ($1, $2, $3)
            ON CONFLICT (character_id, name)
            DO UPDATE SET description = EXCLUDED.description
            """,
            character_id,
            name,
            description,
        )
async def get_skills(character_id: str) -> None:
    """Получает навыки  персонажа из базы данных"""
    pool = get_pool()
    async with pool.acquire() as conn:
        await conn.execute(
            """
            SELECT * FROM character_skill
            WHERE character_id = $1 AND name = $2
            """,
            character_id,
            
        )