import logging
import json
from postgre_service import (
    get_chat,
    get_chat_history, 
    get_character_state, 
    get_world_state, 
    save_message,
    get_skeleton,
    get_skills,
    get_achievements,
    save_llm_call
)
from time import perf_counter
from qdrant_service  import EmbeddingService
from qdrant_service import QdrantMemory
from core.schemas import ChatRequest, ChatResponse
from .tools.tool_registry import MAIN_TOOL_SCHEMAS,TOOL_HANDLERS, SEARCH_TOOL_SCHEMAS



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

    def __init__(self, llm,emdedding_service,qdrant_storage):
        self.llm = llm
        self.embedding_service=emdedding_service
        self.qdrant_storage=qdrant_storage

    async def _execute_tool(self, tool_name: str, chat_id: str, args: dict):
        if tool_name not in TOOL_HANDLERS:
            raise ValueError(f"Неизвестный инструмент: {tool_name}")
           
        handler = TOOL_HANDLERS[tool_name]

        # Исключение только для search_memory, так как ему нужны базы данных (qdrant, embedding)
        if tool_name == "search_memory":
            return await handler(
                qdrant_memory=self.qdrant_storage,
                embedding_service=self.embedding_service,
                chat_id=chat_id,
                **args 
            )
        else:
            # Для всех остальных инструментов (достижения, навыки и будущие)
            return await handler(
                chat_id=chat_id,
                **args 
            )


    async def _run_tool_loop(
        self,
        *,
        inputs,
        tools,
        chat_id,
        component: str,
        max_rounds=5,
    ):
    # История и результаты принадлежат только этому вызову.
        inputs = list(inputs)
        tool_results = []
        allowed_names = {tool["name"] for tool in tools}

        for _ in range(max_rounds):
            started_at = perf_counter()

            response = await self.llm.generate(
                input=inputs,
                tools=tools,
            )

            latency_ms = round((perf_counter() - started_at) * 1000)

            usage = response.usage

            if usage is None:
                raise RuntimeError("В ответе LLM отсутствует статистика токенов")

            input_details = usage.input_tokens_details
            output_details = usage.output_tokens_details

            await save_llm_call(
                chat_id=chat_id,
                component=component,
                model=response.model,
                content={
                    "response_id": response.id,
                    "status": response.status,
                    "output": [
                        item.model_dump(mode="json")
                        for item in response.output
                    ],
                },
                input_tokens=usage.input_tokens,
                output_tokens=usage.output_tokens,
                total_tokens=usage.total_tokens,
                cached_tokens=(
                    getattr(input_details, "cached_tokens", 0) or 0
                ),
                reasoning_tokens=(
                    getattr(output_details, "reasoning_tokens", 0) or 0
                ),
                latency_ms=latency_ms,
                success=response.status == "completed",
            )

            # Ниже остаётся твой код:
            # проверка response.status,
            # inputs.extend(response.output),
            # поиск function_call и выполнение tools.

            if response.status != "completed":
                raise RuntimeError(
                    f"Модель не завершила ответ: {response.status}"
                )

            # Сохраняем все элементы для stateless-продолжения.
            inputs.extend(response.output)

            calls = [
                item
                for item in response.output
                if item.type == "function_call"
            ]

            if not calls:
                return response.output_text, tool_results

            for call in calls:
                # Поисковому этапу нельзя выдавать навыки,
                # даже если модель неожиданно запросит этот tool.
                if call.name not in allowed_names:
                    result = {
                        "status": "error",
                        "message": "Инструмент недоступен на этом этапе",
                    }
                else:
                    # Перед выполнением проверяем JSON и обязательные ключи.
                    schema = next(
                        tool["parameters"]
                        for tool in tools
                        if tool["name"] == call.name
                    )

                    try:
                        args = json.loads(call.arguments)

                        if not isinstance(args, dict):
                            raise ValueError("Аргументы должны быть объектом")

                        required = set(schema.get("required", []))
                        allowed = set(schema.get("properties", {}))

                        if required - args.keys():
                            raise ValueError("Не хватает обязательных аргументов")

                        if args.keys() - allowed:
                            raise ValueError("Переданы неизвестные аргументы")

                    except ValueError as error:
                        result = {
                            "status": "error",
                            "message": str(error),
                        }
                    else:
                        # Ошибки БД здесь не маскируем как успех.
                        result = await self._execute_tool(
                            tool_name=call.name,  # <--- Передаем имя
                            chat_id=chat_id,
                            args=args 
                        )

                tool_results.append({
                    "name": call.name,
                    "result": result,
                })

                inputs.append({
                    "type": "function_call_output",
                    "call_id": call.call_id,
                    "output": json.dumps(result, ensure_ascii=False),
                })

        raise RuntimeError("Превышен лимит раундов")


    #Todo: Считать  кол во токенов в сообщения и ограничиват ьименно по токенам а не кол ву сообщений
    #Todo: подумать над тем чтобы, Добавить агента критика котоырйц будет проверять поиск и наличие нужной информации
    #Todo: подумать над тем чтобы, доабвить агента планировщика котоырй будет составлять план и делить задачи между агентами
    async def process_turn(self, request: ChatRequest) -> ChatResponse:
        logger.info(
            "Начало игрового хода: chat_id=%s",
            request.chat_id,
        )

        try:
            # 1. Получаем информацию о текущем чате и скелете персонажа
            chat = await get_chat(request.chat_id)
            skelet = await get_skeleton(chat.skeleton_id)
            #2 Добавляем сообщение в чат истории
            await save_message(request.chat_id, request.content, sender="player")
        
            # 3. Получаем актуальные состояния
            world_state = await get_world_state(request.chat_id)
            character_state = await get_character_state(request.chat_id)

            # 4. Получаем последние сообщения
            messages = await get_chat_history(request.chat_id,limit=50)

            search_context = f'''
            Ты формируешь поисковые запросы для долговременной памяти RPG.
            Память хранится в Qdrant.
            Каждый объект памяти — одно атомарное событие из истории игры,
            например:
            "Игрок вернул королю Эдварду украденное королевское кольцо."

            Поиск семантический:
            - каждый твой запрос преобразуется в embedding;
            - используется multilingual-e5-base;
            - твои строки кодируются как "query: <текст>";
            - события памяти были закодированы как "passage: <событие>";
            - используется cosine similarity;
            - по каждому запросу возвращаются наиболее похожие события.
            Формулируй запросы по смыслу.

            Если для понимания действия игрока нужно восстановить несколько разных фактов,
            сформируй несколько независимых запросов.

            Пример:
            Сообщение игрока:
            "Я всё-таки отдаю ему кольцо."
            Сначала нужно понять кому "ему" отдал кольцо игрок и потом делать запросы.
            Хорошие запросы:
            - "Кому принадлежит кольцо у героя?" 
            - "Как герой получил это кольцо?"
            - "Отношения героя с владельцем кольца"

            Плохие запросы:
            - "кольцо"
            - "ему"
            - "найти событие"
            У тебя есть инструмент search_memory, который осуществляет поиск релевантной информации по запросу в qdrant
            Ищи только сведения, необходимые для ответа на текущее действие.
            Не ищи информацию обо всех сущностях из истории переписки.
            Не вызывай поиск, если нужные сведения уже есть в контексте.
            Повторный поиск выполняй только для конкретного пробела,
            который остался после предыдущих результатов. 
            Последние 50 сообщений — контекст для понимания текущего
            действия игрока, включая имена, местоимения и отсылки.: {messages}
            
            Тебе нужно вызвать инстурмент по необходимости и передать в него запросы для посика информации.
            Правила формулировки запросов:
            1. Пиши вопросы на естественном языке, как будто спрашиваешь человека.
            2. Максимум 10-12 слов. Убирай служебные слова: "который", "сейчас", "именно".
            3. Один запрос = один факт. Не смешивай "кто" и "когда".
            4. Используй глаголы: "получил", "отдал", "встретил", "убил", "обманул".
            5. Не используй вопросительный знак — он не помогает.
            6. Избегай "что произошло" — слишком размыто. Конкретизируй: "конфликт", "встреча", "сделка".
            '''
            #5. Вызываем LLM SEARCH INFO
            search_summary,search_tool_results  = await self._run_tool_loop(
                inputs=[
                {"role": "system", "content": search_context},
                {"role": "user", "content": request.content},
            ],
            tools=SEARCH_TOOL_SCHEMAS,
            chat_id=request.chat_id,
            component="llm_search",
            max_rounds = 5,
            )
    

            achievements = await get_achievements(chat.character_id)
            skills = await get_skills(chat.character_id)

            messages = await get_chat_history(request.chat_id,limit=50)
            # 5. Собираем контекст
            context = f'''
            Ты основа текстовой игры,который генерирует последствия после дейтсвий игрока
            skelet основной сюжетный каркас мира: {skelet}
            Состояние мира на данный момент: {world_state}
            Состояние персонажа на данный момент: {character_state}
            История чата последние 50 сообщений: {messages}
            найденная информация :{search_summary}
            Навыки персонажа: {skills}
            Достижения персонажа: {achievements}
            '''
             # 6. Вызываем LLM
            final_text, main_tool_results = await self._run_tool_loop(
                inputs=[
                    {"role": "system", "content": context},
                    {"role": "user", "content": request.content},
                ],
                tools=MAIN_TOOL_SCHEMAS,
                chat_id=request.chat_id,
                component="llm_turn",
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