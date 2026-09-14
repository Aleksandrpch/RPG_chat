import logging
from postgres import (
    get_chat,
    get_chat_history, 
    get_character_state, 
    get_world_state, 
    save_message,
    get_skeleton,
    get_skills,
    get_achievements
)
from core.schemas import ChatRequest, ChatResponse
from .tools import MAIN_TOOL_SCHEMAS,TOOL_HANDLERS, SEARCH_TOOL_SCHEMAS
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

    async def _execute_tool(self, call, chat_id):
        args = json.loads(call.arguments)
        if call.name == "search_memory":
            return await search_memory(
                qdrant_memory=self.qdrant_storage,
                embedding_service=self.embedding_service,
                chat_id=chat_id,
                queries=args["queries"],
            )

        if call.name == "add_achievement":
            return await tool_new_achievement(
                chat_id=chat_id,
                achievement_name=args["achievement_name"],
                achievement_description=args["achievement_description"],
            )

        if call.name == "add_skill":
            return await tool_new_skill(
                chat_id=chat_id,
                skill_name=args["skill_name"],
                skill_description=args["skill_description"],
            )

        raise ValueError(f"Неизвестный инструмент: {call.name}")

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
            inputs = [
            {"role": "system", "content": search_context},
            {"role": "user", "content": request.content},
            ]

            max_rounds = 5
            #5. Вызываем LLM SEARCH INFO
            for _ in range(max_rounds):
                llm_response = await self.llm.generate(
                input=inputs,
                tools=SEARCH_TOOL_SCHEMAS,  
                )
            

                # Добавляем ответ модели целиком:
                # вызовы tools и остальные элементы продолжения.
                inputs.extend(llm_response.output)
                calls = [item for item in llm_response.output if item.type == "function_call"]
                # Модель закончила поиск.
                if not calls:
                    search_summary = llm_response.output_text
                    return

                for call in calls:
                    result = await self._execute_tool(
                        call=call,
                        chat_id=request.chat_id,
                    )

                    inputs.append({
                        "type": "function_call_output",
                        "call_id": call.call_id,
                        "output": json.dumps(result, ensure_ascii=False),
                    })
            else:
                raise RuntimeError("Превышен лимит раундов поиска")

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
            main_response = await self.llm.generate(
            input=context,
            tools=MAIN_TOOL_SCHEMAS,  
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