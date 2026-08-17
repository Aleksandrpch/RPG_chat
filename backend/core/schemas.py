from datetime import datetime, timezone
from typing import Any
from enum import Enum
from pydantic import BaseModel, Field



# ============================================================
# СОСТОЯНИЕ ПЕРСОНАЖА
# ============================================================
class CharacterState(BaseModel):
    character_id: str
    chat_id: str
    state: dict[str, Any] = Field(default_factory=dict)
    updated_at: datetime = Field(default_factory=datetime.now(timezone.utc))

# ============================================================
# СОСТОЯНИЕ МИРА
# ============================================================

class WorldState(BaseModel):
    chat_id: str
    state: dict[str, Any] = Field(default_factory=dict)
    updated_at: datetime = Field(default_factory=datetime.now(timezone.utc))


# ============================================================
# СОБЫТИЯ (RAG + история)
# ============================================================

class EventState(BaseModel):

    class EventType(str, Enum):
        DIALOG = "dialog"
        COMBAT = "combat"
        WORLD_CHANGE = "world_change"
        DISCOVERY = "discovery"
        ITEM = "item"
        SYSTEM = "system"

    id: int | None = None
    chat_id: str
    character_id: str | None = None
    importance: int = 5
    summary: str
    payload: dict[str, Any] = Field(default_factory=dict)
    created_at: datetime = Field(default_factory=datetime.now(timezone.utc))


class ChatRequest(BaseModel):
    chat_id: str
    content: str


class ChatResponse(BaseModel):
    answers: list[MessageResponse]
    

class ChatSchema(BaseModel):
    character_id: str
    skeleton_id: str
    name: str | None = None
    created_at: datetime | None = None
    last_played: datetime | None = None


class MessageResponse(BaseModel):
    sender_id: str
    sender_name: str
    sender_type : str
    sender_avatar_url: str | None = None
    content: str
    timestamp: datetime


class CharacterSchema(BaseModel):
    id: str
    name: str
    backstory: str
    avatar_url: str | None = None
    visual_style: str | None = None
    visual_description: str
    skills: list[dict]
    achievements: list[dict]


class CreateWorldRequest(BaseModel):
    character: CharacterSchema


class CreateWorldResponse(BaseModel):
    chat_id: str
    character: CharacterSchema


class UpdateSkeletonRequest(BaseModel): 
    skeleton_id: str
    character: CharacterSchema