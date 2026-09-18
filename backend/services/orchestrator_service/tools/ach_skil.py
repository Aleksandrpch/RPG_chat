from backend.services.postgre_service import (
    get_character_id_by_chat_id,
    add_achievement,
    add_skill
)
import logging



logger = logging.getLogger(__name__)

ADD_ACHIEVEMENT_SCHEMA = {
    "type": "function",
    "name": "add_achievement",
    "description": (
        "Добавляет достижение персонажу после действительно уникального,"
        "смешного, ироничного или значимого события.Не добавляй достижение, если оно уже есть у персонажа"
        "Если событие смешное, название и описание достижения тоже должны быть смешными."
        "Не вызывай для обычных действий."
        "примеры:"
        "name: Пьяный философ, description: Пытался объяснить дракону теорию относительности"
        "name: Куриный терминатор, description: Убил 50 куриця. Все куры в радиусе 10 метров убегают от тебя в ужасе",         
    ),
    "parameters": {
        "type": "object",
        "properties": {
            "achievement_name": {
                "type": "string",
                "description": "Название достижения",
                "maxLength": 50, 
            },
            "achievement_description": {
                "type": "string",
                "description": "Описание причины его получения и эффект который он дает, если есть",
                "maxLength": 130, 
            },
        },
        "required": [
            "achievement_name",
            "achievement_description",
        ],
        "additionalProperties": False,
    },
}

async def tool_new_achievement(chat_id, achievement_name, achievement_description):
    """
    Вызывай эту функцию, чтобы добавить достижение персонажу и сохранить его.
    Она автоматически сохраняет достижение.
    Добавляет достижение персонажу в базе данных.
             
    chat_id: UUID игрового чата
    achievement_name: Название достижения
    achievement_description: Описание достижения и его эффект, если есть
    """
    try:
        # Получаем character_id по chat_id
        character_id = await get_character_id_by_chat_id(chat_id)

        await add_achievement(character_id, name=achievement_name, description=achievement_description)
        logger.info("Достижение '%s' добавлено для персонажа с ID %s", achievement_name, character_id)

    except Exception as e:
        logger.exception("Ошибка при добавлении достижения: %s", e)
        raise


ADD_SKILL_SCHEMA = {
    "type": "function",
    "name": "add_skill",
    "description": (
        "Добавляет навык персонажу. Навык может быть получен после уникального события, или как награда за квест."
        "В навыке не должно быть процентов для увеличения характеристик, только описание эффекта. Не добавляй навык если он уже есть у персонажа."
        "примеры:"
        "name: Мастер меча, description: Увеличивает урон от атак мечом"
        "name: Ловкий, description: Увеличивает шанс уклонения от атак противника"
    ),
    "parameters": {
        "type": "object",
        "properties": {
            "skill_name": {
                "type": "string",
                "description": "Название навыка",
            },
            "skill_description": {
                "type": "string",
                "description": "Описание эффект который он дает",
            },
        },
        "required": [
            "skill_name",
            "skill_description",
        ],
        "additionalProperties": False,
    },
}    


async def tool_new_skill(chat_id, skill_name, skill_description):
    """
    Вызывай эту функцию, чтобы добавить навык персонажу и сохранить его.
    Она автоматически сохраняет навык.
    Добавляет навык персонажу в базе данных.
             
    chat_id: UUID игрового чата
    skill_name: Название навыка
    skill_description: Описание эффекта навыка
    """
    try:
        # Получаем character_id по chat_id
        character_id = await get_character_id_by_chat_id(chat_id)

        await add_skill(character_id, name=skill_name, description=skill_description)
        logger.info("Навык '%s' добавлен для персонажа с ID %s", skill_name, character_id)

    except Exception as e:
        logger.exception("Ошибка при добавлении навыка: %s", e)
        raise