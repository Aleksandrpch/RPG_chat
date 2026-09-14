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


'''async def get_character_id_by_chat_id(chat_id: str) -> str:
    """Получает character_id по chat_id"""
    pool = get_pool()
    async with pool.acquire() as conn:
        row = await conn.fetchrow(
            """
            SELECT character_id FROM chat  
            WHERE id = $1
            """,
            chat_id,
        )
        if row is None:
            raise ValueError(f"Chat with id {chat_id} not found")
        return row["character_id"]'''

async def get_character(character_id: str) -> CharacterSchema:
    """Возвращает информацию о персонаже по его ID."""
    pool = get_pool()
    async with pool.acquire() as conn:
        row = await conn.fetchrow(
            """
            SELECT id, name, backstory, avatar_url, visual_style, visual_description
            FROM character
            WHERE id = $1
            """,
            character_id,
        )
        if row:
            # Получаем навыки и достижения персонажа
            skills = await conn.fetch(
                """
                SELECT name, description FROM character_skill
                WHERE character_id = $1
                """,
                character_id,
            )
            achievements = await conn.fetch(
                """
                SELECT name, description FROM character_achievement
                WHERE character_id = $1
                """,
                character_id,
            )
            return CharacterSchema(
                id=row["id"],
                name=row["name"],
                backstory=row["backstory"],
                avatar_url=row["avatar_url"],
                visual_style=row["visual_style"],
                visual_description=row["visual_description"],
                skills=[dict(skill) for skill in skills],
                achievements=[dict(achievement) for achievement in achievements],
            )
        else:
            return None