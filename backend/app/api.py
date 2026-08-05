from datetime import datetime, timezone
from services.llm.story_generator.world_gen import WorldGenerator
from core.postgredatabase import *
from fastapi import APIRouter
from app.services.game_orchestrator import GameOrchestrator
from app.models.schemas import (
    CreateWorldRequest,
    CreateWorldResponse,
    RegenerateWorldRequest,
    ChatRequest,
    ChatResponse,
)



router = APIRouter()
world_service = WorldService()
orchestrator = GameOrchestrator()

# Создание skelet
@router.post("/world/create", response_model=CreateWorldResponse)
async def create_world(request: CreateWorldRequest) -> CreateWorldResponse:
    return await world_service.create_world(request)

# нужен когда пользователь поменял незначительные поля  и чтобы не переделывать весь скелет
@router.put("/skelet/update", response_model=CreateWorldResponse)
async def regenerate_world(request: RegenerateWorldRequest,) -> CreateWorldResponse:
    return await world_service.regenerate(request)

# главный роут ответ  ллм котоырй летит в чат потом
@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest) -> ChatResponse:
    return await orchestrator.process_turn(request)