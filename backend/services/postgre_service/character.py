import asyncpg
from postgre_conn import get_pool
from core.schemas import CharacterSchema


async def create_character(character: CharacterSchema) -> None: 
    """Создает персонажа"""
    pool=get_pool()
    async with pool.acquire() as conn: 
      row=conn.fetchrow('''
    INSERT INTO character (name, backstory, avatar_url, visual_style, visual_description)
    VALUES ($1, $2, $3, $4, $5)
    RETURNING id
    ''',
    character.name,
    character.backstory,
    character.avatar_url,
    character.visual_style,
    character.visual_description,
        )
    character_id = row["id"]   

    # Сохраняем навыки (если есть)
    for skill in character.skills:
        await conn.execute("""
            INSERT INTO character_skill (character_id, name, description)
            VALUES ($1, $2, $3)
            ON CONFLICT (character_id, name)
            DO UPDATE SET description = EXCLUDED.description
            """,
            character_id,
            skill["name"],
            skill.get("description"),
            )
    for achievement in character.achievements:
            await conn.execute(
                """
                INSERT INTO character_achievement (character_id, name, description)
                VALUES ($1, $2, $3)
                ON CONFLICT (character_id, name)
                DO UPDATE SET description = EXCLUDED.description
                """,
                character_id,
                achievement["name"],
                achievement.get("description"),
            )
    return character_id