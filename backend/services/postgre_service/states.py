import json
import asyncpg
from postgre_conn import get_pool
from core.schemas import CharacterState, WorldState, WorldEvent



# 1. РАБОТА С ПЕРСОНАЖЕМ
async def get_character_state(character_id: str) -> CharacterState:
        pool=get_pool()
        async with pool.acquire() as conn:
            row = await conn.fetchrow(
                "SELECT state FROM character_states WHERE character_id = $1",
                character_id
            )
            if row:
                return CharacterState(**row['state'])
            raise ValueError(f"Character {character_id} not found")

async def save_character_state( schema: CharacterState):
        pool=get_pool()
        async with pool.acquire() as conn:
            await conn.execute(
                """
                INSERT INTO character_states (character_id, world_id, state, updated_at)
                VALUES ($1, $2, $3, NOW())
                ON CONFLICT (character_id)
                DO UPDATE SET state = $3, updated_at = NOW()
                """,
                schema.character_id,
                schema.chat_id,
                json.dumps(schema.model_dump())
            )

    # 2. РАБОТА С МИРОМ
async def get_world_state( world_id: str) -> WorldState:
        pool=get_pool()
        async with pool.acquire() as conn:
            row = await conn.fetchrow(
                "SELECT state FROM world_states WHERE world_id = $1",
                world_id
            )
            if row:
                return WorldState(**row['state'])
            raise ValueError(f"WorldState {world_id} not found")

async def save_world_state(self, schema: WorldState):
        pool=get_pool()
        async with pool.acquire() as conn:
            await conn.execute(
                """
                INSERT INTO world_states (world_id, state, updated_at)
                VALUES ($1, $2, NOW())
                ON CONFLICT (world_id)
                DO UPDATE SET state = $2, updated_at = NOW()
                """,
                schema.world_id,
                json.dumps(schema.model_dump())
            )

    # 3. РАБОТА С СОБЫТИЯМИ
async def add_event(self, event: WorldEvent):
        pool=get_pool()
        async with pool.acquire() as conn:
            await conn.execute(
                """
                INSERT INTO world_events (world_id, character_id, event_type, summary, data, created_at)
                VALUES ($1, $2, $3, $4, $5, NOW())
                """,
                event.world_id,
                event.character_id,
                event.event_type,
                event.summary,
                json.dumps(event.data)
            )
