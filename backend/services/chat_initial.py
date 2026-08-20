from uuid import uuid4
from services.generators import WorldGenerator, StateGenerator

from services.postgre_service import (
    get_skeleton, #  Поулчает скелет из бд
    save_skeleton, # Сохраняет скелет в бд
    create_character, # Добавляет героя в бд и его способности, достижения
    create_chat, # Создает чат
    save_world_state,
    add_event,
    save_character_state
)
from app.models.schemas import (
    CreateWorldRequest,
    CreateWorldResponse,
    RegenerateWorldRequest,
    ChatRequest,
    ChatResponse,
    CharacterState, 
    WorldState, 
    WorldEvent
)


'''class ChatService:
    """
    Отвечает за подготовку чата(создание бд, начальных состояний)  для игры.

    ChatService не содержит SQL и не занимается
    непосредственной генерацией текста LLM.
    """

    def __init__(self):
        self.world_gen = WorldGenerator()
        self.state_gen= StateGenerator()


    async def create_world(self, character_data: dict) -> dict:
        """
        Создаёт новый skelet мира.

        1. Генерирует skeleton через WorldGenerator.
        2. Создаёт UUID skeleton.
        3. Сохраняет skeleton в PostgreSQL.
        4. Возвращает данные созданного skeleton.
        """
        # 1. Сохраняем героя
        character_id = await create_character(
            character_data
        )
        skelet = await self.world_gen(character_data)
        
        # 2. Сохраняем skeleton
        skeleton_id = await save_skeleton(
            skelet=skelet,
        )


        # 3. Создаем чат в бд
        chat_schema = ChatSchema(
            character_id=character_id,
            skeleton_id=skeleton_id,
            name=skelet.get("world").get("name"),  # опционально
        )
        chat_id = await create_chat(
            chat = chat_schema
        )
        # 4. Создаем начальные состояние мира и персонажа и  версию ивента
        save_world_state(
            chat_id=skeleton_id,
            schema= self.state_gen(character_data)
        )
        add_event()

        main_char = skelet.get("main_character", {})
        main_char.pop("lore_friendly", None)
        character_state_schema = CharacterState(
            character_id = character_id,
            chat_id = skeleton_id,
            state= main_char
        )

        save_character_state(
            schema = character_state_schema
        )
        return {
            "skeleton_id": skeleton_id,
            "skelet": skelet,
        }'''
import logging

logger = logging.getLogger(__name__)

class ChatService:
    def __init__(self):
        self.world_gen = WorldGenerator()
        self.state_gen = StateGenerator()

    async def create_world(self, character_data: dict) -> dict:
        try:
            # 1. Сохраняем героя
            character_id = await create_character(character_data)
            logger.info(f"✅ Персонаж создан: {character_id}")

            # 2. Генерируем скелет
            skelet = await self.world_gen(character_data)
            logger.info("✅ Скелет сгенерирован")

            # 3. Сохраняем скелет
            skeleton_id = await save_skeleton(skelet=skelet)
            logger.info(f"✅ Скелет сохранён: {skeleton_id}")

            # 4. Создаём чат
            chat_schema = ChatSchema(
                character_id=character_id,
                skeleton_id=skeleton_id,
                name=skelet.get("world", {}).get("name", "Новый мир"),
            )
            chat_id = await create_chat(chat=chat_schema)
            logger.info(f"✅ Чат создан: {chat_id}")

            # 5. Состояние мира
            world_state_schema = await self.state_gen(skelet)
            await save_world_state(chat_id=chat_id, schema=world_state_schema)
            logger.info("✅ Состояние мира сохранено")

            # 6. Состояние персонажа
            main_char = skelet.get("main_character", {}).copy()
            main_char.pop("lore_friendly", None)

            character_state_schema = CharacterState(
                character_id=character_id,
                chat_id=chat_id,
                state=main_char,
            )
            await save_character_state(schema=character_state_schema)
            logger.info("✅ Состояние персонажа сохранено")

            # 7. Добавляем событие (если нужно)
            #await add_event(chat_id=chat_id, ...)
            #logger.info("✅ Событие добавлено")

            return {
                "character_id": character_id,
                "skeleton_id": skeleton_id,
                "chat_id": chat_id,
                "skelet": skelet,
            }

        except Exception as e:
            logger.error(f"❌ Ошибка в create_world: {e}", exc_info=True)
            raise  # ← пробрасываем дальше, чтобы FastAPI вернул 500