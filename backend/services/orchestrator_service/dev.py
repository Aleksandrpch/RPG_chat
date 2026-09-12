import logging
from postgres import (
    get_chat_history, 
    get_character_state, 
    get_world_state, 
    save_message 
)
from core.schemas import ChatRequest, ChatResponse
from .tools import TOOL_SCHEMAS,TOOL_HANDLERS
logger = logging.getLogger(__name__)


class GameOrchestrator:
    """
    Координирует один игровой ход.

    Получает сообщение игрока и управляет последовательностью:
    1. Получение данных текущей игровой сессии.
    2. Получение актуальных CharacterState и WorldState.
    3. Поиск релевантной памяти в Qdrant.
    4. Получение последних сообщений чата.
    5. Формирование контекста для LLM.
    6. Вызов LLM.
    7. Сохранение сообщений, событий и изменений state.
    """

    def __init__(self, llm):
        self.llm = llm

    
    async def process_turn(self, request: ChatRequest) -> ChatResponse:
        logger.info(
            "Начало игрового хода: chat_id=%s",
            request.chat_id,
        )

        try:
            # 1. Получаем информацию о текущем чате
            #chat = await get_chat(request.chat_id)

            # добавляем сообщение в чат истории
            await save_message(request.chat_id, request.message)

            # 2. Получаем актуальные состояния
            world_state = await get_world_state(request.chat_id)
            character_state = await get_character_state(request.chat_id)

            # 3. Получаем последние сообщения
            messages = await get_chat_history(request.chat_id)

            # 5. Собираем контекст
            context = f'''
            Состояние мира на данный момент: {world_state}
            Состояние персонажа на данный момент: {character_state}
            История чата посоедние 50 сообщений: {messages}

            '''

            # 6. Вызываем LLM
            # llm_response = await ...
            response = await self.llm.generate(
            input=context,
            tools=TOOL_SCHEMAS,  
            )


            # 7. Сохраняем изменения
            # message
            # event_state
            # world_state
            # character_state
            # qdrant

            # Пока заглушка
            raise NotImplementedError(
                "GameOrchestrator.process_turn ещё не реализован"
            )

        except Exception:
            logger.exception(
                "Ошибка игрового хода: chat_id=%s",
                request.chat_id,
            )
            raise