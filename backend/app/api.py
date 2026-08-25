from datetime import datetime, timezone
from services.Generators.story_generator.world_gen import WorldGenerator
from core.postgredatabase import *
from fastapi import APIRouter
from services.game_orchestrator import GameOrchestrator
from backend.services.chat_initial import ChatService
from app.models.schemas import (
    CreateWorldRequest,
    CreateWorldResponse,
    RegenerateWorldRequest,
    ChatRequest,
    ChatResponse,
)



router = APIRouter()
chat_service = ChatService()
orchestrator = GameOrchestrator()

# Создание skelet
@router.post("/world/create", response_model=CreateWorldResponse)
async def create_world(request: CreateWorldRequest) -> CreateWorldResponse:
    return await chat_service.create_world(request)


#  Нужен для кнопки заполнить пустые поля случайно
@router.post("/world/fill_missing", response_model=CreateWorldResponse)
async def create_world(request: CreateWorldRequest) -> FillMissingResponse:
    """
    Генерирует скелет мира и состояния на основе переданных данных.
    НЕ СОХРАНЯЕТ в БД — только возвращает для заполнения полей на фронте.
    """
    return await chat_service.create_skeletforfillmising(request)


# главный роут ответ  ллм который летит в чат потом
@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest) -> ChatResponse:
    # 1. Сохраняет сообщение пользователя
    # 2. Вызывает оркестратор → LLM → RAG → ответ
    # 3. Сохраняет ответ LLM
    # 4. Возвращает ответ фронт
    return await orchestrator.process_turn(request)