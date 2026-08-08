from datetime import datetime, timezone
from services.Generators.story_generator.world_gen import WorldGenerator
from core.postgredatabase import *
from fastapi import APIRouter
from services.game_orchestrator import GameOrchestrator
from services.world_service import WorldService
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
@router.put("/skeleton/update")
async def update_skeleton(request: UpdateSkeletonRequest):
    skeleton = await world_service.get_skeleton(request.skeleton_id)
    if not skeleton:
        raise HTTPException(404, "Skeleton not found")
    skeleton["main_character"].update(request.character.model_dump())
    await world_service.save_skeleton(
        request.skeleton_id,
        skeleton,
    )
    return skeleton

# главный роут ответ  ллм котоырй летит в чат потом
@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest) -> ChatResponse:
    return await orchestrator.process_turn(request)