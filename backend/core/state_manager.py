import json
import asyncpg
from core.schemas import CharacterState, WorldState, WorldEvent

class StateManager:
    def __init__(self, pool: asyncpg.Pool):
        self.pool = pool

    # 1. РАБОТА С ПЕРСОНАЖЕМ
    async def get_character_state(self, character_id: str) -> CharacterState:
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                "SELECT state FROM character_states WHERE character_id = $1",
                character_id
            )
            if row:
                return CharacterState(**row['state'])
            raise ValueError(f"Character {character_id} not found")

    async def save_character_state(self, state: CharacterState):
        async with self.pool.acquire() as conn:
            await conn.execute(
                """
                INSERT INTO character_states (character_id, world_id, state, updated_at)
                VALUES ($1, $2, $3, NOW())
                ON CONFLICT (character_id)
                DO UPDATE SET state = $3, updated_at = NOW()
                """,
                state.character_id,
                state.world_id,
                json.dumps(state.model_dump())
            )

    # 2. РАБОТА С МИРОМ
    async def get_world_state(self, world_id: str) -> WorldState:
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                "SELECT state FROM world_states WHERE world_id = $1",
                world_id
            )
            if row:
                return WorldState(**row['state'])
            raise ValueError(f"WorldState {world_id} not found")

    async def save_world_state(self, state: WorldState):
        async with self.pool.acquire() as conn:
            await conn.execute(
                """
                INSERT INTO world_states (world_id, state, updated_at)
                VALUES ($1, $2, NOW())
                ON CONFLICT (world_id)
                DO UPDATE SET state = $2, updated_at = NOW()
                """,
                state.world_id,
                json.dumps(state.model_dump())
            )

    # 3. РАБОТА С СОБЫТИЯМИ
    async def add_event(self, event: WorldEvent):
        async with self.pool.acquire() as conn:
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