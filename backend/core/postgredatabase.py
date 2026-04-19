import asyncpg
import os 
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"

async def get_db():
    """Создаёт и возвращает соединение с БД"""
    conn = await asyncpg.connect(DATABASE_URL)
    return conn

async def save_world(world_id: str, skeleton: dict):
    conn = await get_db()
    skeleton_json=json.dumps(skeleton)
    try:
        await conn.execute("""
            INSERT INTO worlds (world_id, skeleton) 
            VALUES ($1, $2) 
            ON CONFLICT (world_id) 
            DO UPDATE SET skeleton = EXCLUDED.skeleton
        """, world_id, skeleton_json)
    finally:
        await conn.close()

async def get_world(world_id: str) -> dict:
    """Получает скелет мира из БД"""
    conn = await get_db()
    try:
        row = await conn.fetchrow(
            "SELECT skeleton FROM worlds WHERE world_id = $1",
            world_id
        )
        return dict(row['skeleton']) if row else None
    finally:
        await conn.close()