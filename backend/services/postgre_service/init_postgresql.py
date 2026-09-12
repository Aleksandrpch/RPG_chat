from postgre_conn import get_pool


async def create_postgre():
    pool=get_pool()
    async with pool.acquire() as conn:
        row = await conn.execute('''
-- ============================================================
-- RPG_chat Database Schema (PostgreSQL)
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- 1. ШАБЛОНЫ МИРОВ
-- ============================================================

CREATE TABLE IF NOT EXISTS skeleton (
    
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name TEXT NOT NULL,
    
    skelet JSONB NOT NULL,

    rating REAL DEFAULT 0,

    votes_count INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 2. ПЕРСОНАЖИ
-- ============================================================

CREATE TABLE IF NOT EXISTS character (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name TEXT NOT NULL,

    backstory TEXT,

    avatar_url TEXT,

    visual_style TEXT,

    visual_description TEXT,

    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 3. НАВЫКИ
-- ============================================================

CREATE TABLE IF NOT EXISTS character_skill (

    character_id UUID NOT NULL REFERENCES character(id) ON DELETE CASCADE,

    name TEXT NOT NULL,

    description TEXT,

 	earned_at TIMESTAMPTZ,
     
    PRIMARY KEY(character_id, name)

);

-- ============================================================
-- 4. ДОСТИЖЕНИЯ
-- ============================================================

CREATE TABLE IF NOT EXISTS character_achievement (

    character_id UUID NOT NULL REFERENCES character(id) ON DELETE CASCADE,

    name TEXT NOT NULL,

    description TEXT,

    earned_at TIMESTAMPTZ,

    PRIMARY KEY(character_id, name)
);

-- ============================================================
-- 5. ИГРОВАЯ СЕССИЯ (ЧАТ)
-- ============================================================

CREATE TABLE IF NOT EXISTS chat (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    character_id UUID NOT NULL
        REFERENCES character(id)
        ON DELETE CASCADE,

    skeleton_id UUID NOT NULL
        REFERENCES skeleton(id)
        ON DELETE CASCADE,

    name TEXT,

    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    last_played TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 6. СОСТОЯНИЕ МИРА
-- ============================================================

CREATE TABLE IF NOT EXISTS world_state (

    chat_id UUID PRIMARY KEY
        REFERENCES chat(id)
        ON DELETE CASCADE,

    state JSONB NOT NULL DEFAULT '{}',

    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 7. СОСТОЯНИЕ ПЕРСОНАЖА
-- ============================================================

CREATE TABLE IF NOT EXISTS character_state (

    chat_id UUID PRIMARY KEY
        REFERENCES chat(id)
        ON DELETE CASCADE,

    state JSONB NOT NULL DEFAULT '{}',

    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 8. ИСТОРИЯ СОБЫТИЙ
-- ============================================================

CREATE TABLE IF NOT EXISTS event_state (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    chat_id UUID NOT NULL
        REFERENCES chat(id)
        ON DELETE CASCADE,

    event_type TEXT NOT NULL,

    cause_event_id UUID REFERENCES event_state(id)

    importance SMALLINT NOT NULL
        CHECK (importance BETWEEN 1 AND 10),

    summary TEXT NOT NULL,

    payload JSONB DEFAULT '{}',

    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 9. СООБЩЕНИЯ
-- ============================================================

CREATE TABLE IF NOT EXISTS message (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    chat_id UUID NOT NULL
        REFERENCES chat(id)
        ON DELETE CASCADE,

    sender_id TEXT NOT NULL,

    sender_type TEXT NOT NULL CHECK (
        sender_type IN ('NPC', 'Narrator', 'Hero')
        )

    sender_name TEXT NOT NULL,

    sender_avatar_url TEXT,

    content TEXT NOT NULL,

    model_id TEXT,

    tokens INTEGER,
    
    cost REAL,

    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
-- ============================================================
-- 10. ВЫЗОВЫ LLM
-- ============================================================

CREATE TABLE llm_call (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    chat_id UUID REFERENCES chat(id) ON DELETE CASCADE,
    message_id UUID REFERENCES message(id) ON DELETE SET NULL,

    -- Где произошёл вызов
    component TEXT NOT NULL,

    -- Модель, которую фактически использовал API
    model TEXT NOT NULL,

    -- Usage из ответа API
    input_tokens INTEGER NOT NULL,
    cached_tokens INTEGER DEFAULT 0,

    output_tokens INTEGER NOT NULL,
    reasoning_tokens INTEGER DEFAULT 0,

    total_tokens INTEGER NOT NULL,

    -- Рассчитываем сами по актуальному тарифу
    cost NUMERIC(12, 8),

    -- Наша техническая статистика
    latency_ms INTEGER,
    success BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- ИНДЕКСЫ
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_chat_character
ON chat(character_id);

CREATE INDEX IF NOT EXISTS idx_chat_skeleton
ON chat(skeleton_id);

CREATE INDEX IF NOT EXISTS idx_message_chat
ON message(chat_id);

CREATE INDEX IF NOT EXISTS idx_message_time
ON message(timestamp);

CREATE INDEX IF NOT EXISTS idx_event_chat
ON event_state(chat_id);

CREATE INDEX IF NOT EXISTS idx_event_importance
ON event_state(importance);

CREATE INDEX IF NOT EXISTS idx_event_payload
ON event_state
USING GIN(payload);

CREATE INDEX idx_llm_call_message_id
ON llm_call(message_id);

CREATE INDEX idx_llm_call_chat_created_at
ON llm_call(chat_id, created_at DESC);

CREATE INDEX idx_llm_call_component
ON llm_call(component);
''')