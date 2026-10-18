import json
import logging
import re

from services.orchestrator_service.init_LLM import LLMConnection


logger = logging.getLogger(__name__)


def clean_json_response(text: str) -> str:
    """Удаляет внешнее Markdown-ограждение, если модель его добавила."""
    text = text.strip()

    if text.startswith("```"):
        text = re.sub(
            r"\A```(?:json)?[ \t]*\r?\n?",
            "",
            text,
            count=1,
            flags=re.IGNORECASE,
        )
        text = re.sub(r"\s*```\Z", "", text, count=1)

    return text.strip()


WORLD_PROMPT = """
Ты — архитектор открытых игровых миров для текстовой игры.

Создай СТАТИЧЕСКИЙ СКЕЛЕТ МИРА — неизменную основу
для дальнейшей динамической игры.

Верни только валидный JSON-объект.
Не добавляй Markdown, комментарии или текст вне JSON.

Ниже пример структуры. Количество элементов в примере
не ограничивает количество элементов в результате.
Количество определяют правила после примера.

{
    "world": {
        "world_overview" : "жанр(детектив, фентези, историческое фентези и тд зависит от выбранного жанра), небольшое описание без спойлеров",
        "name": "Название мира",
        "core_mysteries": ["Главная загадка"],
        "rules": "Основные законы мира, 1–2 предложения"
    },
    "regions": [
        {
            "id": "region_1",
            "name": "Название региона",
            "description": "Визуальная и эмоциональная атмосфера",
            "feature": "Особенность региона",
            "locations": [
                {
                    "id": "loc_1_1",
                    "name": "Название локации",
                    "description": "Что это за место",
                    "inhabitants": ["npc_1"],
                    "points_of_interest": ["Интересное место"],
                    "possible_events": ["Что может здесь случиться"]
                }
            ],
            "inhabitants": ["npc_1"],
            "factions": ["faction_1"],
            "connections": [
                {
                    "region_2": [
                        ["loc_2_1", "Найти зеркало"],
                        ["loc_2_1", "Уговорить стражника"]
                    ]
                }
            ]
        },
        {
            "id": "region_2",
            "name": "Название второго региона",
            "description": "Визуальная и эмоциональная атмосфера",
            "feature": "Особенность региона",
            "locations": [
                {
                    "id": "loc_2_1",
                    "name": "Название локации",
                    "description": "Что это за место",
                    "inhabitants": [],
                    "points_of_interest": ["Интересное место"],
                    "possible_events": ["Что может здесь случиться"]
                }
            ],
            "inhabitants": [],
            "factions": [],
            "connections": [
                {
                    "region_1": [
                        ["loc_1_1", "Активировать зеркало"],
                        ["loc_1_1", "Получить помощь проводника"]
                    ]
                }
            ]
        }
    ],
    "npcs": [
        {
            "id": "npc_1",
            "name": "Имя NPC",
            "region": "region_1",
            "location": "loc_1_1",
            "role": "Кто он",
            "backstory": "Происхождение и возраст, 1–2 предложения",
            "personality": "Таланты, достоинства, недостатки и страхи",
            "secret": "Что знает или скрывает, 1–2 предложения",
            "motivation": "Чего хочет, почему и насколько сильно",
            "quests": ["Описание квеста"]
        }
    ],
    "factions": [
        {
            "id": "faction_1",
            "name": "Название фракции",
            "description": "Кто они",
            "goal": "Чего добиваются",
            "attitude_to_stranger": "Как относятся к герою"
        }
    ],
    "main_character": {
        "name": "Имя героя",
        "origin_region": "region_1",
        "backstory": "Связная предыстория героя",
        "skills": [
            {"name": "Навык", "description": "Уникальная способность"}
        ],
        "achievements": [
            {"name": "Достижение", "description": "Причина и эффект"}
        ],
        "lore_friendly": true
    }
}

ПРАВИЛА СТРУКТУРЫ:
- Все ID должны быть уникальными в пределах своего типа.
- Ссылки на регионы, локации, NPC и фракции должны вести
  на существующие сущности этого скелета.
- В inhabitants и factions используй ID соответствующих сущностей.
- connections: ключ — ID региона назначения.
  Значение — список путей в этот регион.
  Первый элемент каждого пути — ID локации назначения,
  остальные элементы описывают условия или способы перехода.
- quests — массив строк с описаниями квестов.
- lore_friendly — булево значение true или false.
  При true используй лор и мифологию героя в основном сюжете.
  При false не привязывай основной сюжет к его исходной мифологии.

ПРАВИЛА ДЛЯ ПЕРСОНАЖЕЙ:
- Сохраняй переданные пользователем параметры героя.
  Недостающие параметры дополни.
- Предыстория главного героя: 5–8 связанных предложений.
  Раскрой происхождение, возраст, цель, способ её достижения,
  мотивацию, ставки, страх, недостаток, секрет и главное
  открытие, которое герою ещё предстоит сделать.
- Не используй в предыстории заголовки и перечисления
  вроде «Мотивация:» или «Страх:».
- origin_region — регион, где герой оказывается в начале игры.
- У главного героя ровно 2 уникальных навыка.
  Они дают качественные способности без процентов
  и числовых бонусов к характеристикам.
- У главного героя ровно 2 уникальных достижения,
  полученных до начала игры и связанных с его предысторией.
  Их эффекты могут быть положительными, отрицательными
  или отсутствовать. Не используй числовые бонусы.
- Цели персонажей должны пересекаться с загадками мира.
- Объясняй, зачем NPC помогает герою, если помогает.

ПРАВИЛА СОЗДАНИЯ:
1. Никаких choices и готовых сцен — только структура мира.
2. Создай 3–5 регионов: этажи, области или другие территории.
3. В каждом регионе создай 2–3 локации или больше при необходимости.
4. Создай 5–8 NPC с тайнами и, где уместно, 1–3 квестами.
5. Связи между регионами не обязаны быть линейными.
6. Главных загадок в core_mysteries должно быть больше трёх.
   Не раскрывай их решения в общедоступных описаниях локаций.
7. Для каждого связанного региона предложи минимум
   два разных способа перехода: предмет, помощь NPC,
   награда, обходной путь, способность героя и другие варианты.
   Уникальный навык героя не должен быть единственным способом.
8. Укладывайся примерно в 20000 токенов.
   При нехватке места используй нижние границы количества
   регионов и NPC, сокращай описания, сохраняя валидный JSON.
"""


class WorldGenerator:
    def __init__(self, llm: LLMConnection):
        self.llm = llm

    async def __call__(self, question: dict) -> dict:
        logger.info("Начало генерации скелета мира")

        try:
            response = await self.llm.generate(
                input=[
                    {
                        "role": "system",
                        "content": WORLD_PROMPT,
                    },
                    {
                        "role": "user",
                        "content": (
                            "Создай мир по следующим параметрам героя. "
                            "Если параметры отсутствуют, придумай героя "
                            "и мир с глубоким сюжетом.\n"
                            + json.dumps(question, ensure_ascii=False)
                        ),
                    },
                ],
                tools=[],
                max_output_tokens=20000,
            )

            if response.status != "completed":
                raise RuntimeError(
                    "Генерация не завершена: "
                    f"status={response.status}, "
                    f"details={response.incomplete_details}"
                )

            generated_text = response.output_text

            if not generated_text or not generated_text.strip():
                raise RuntimeError("Модель вернула пустой ответ")

            try:
                world_data = json.loads(generated_text)

            except json.JSONDecodeError:
                logger.warning(
                    "Ответ не распознан как JSON; "
                    "пробуем удалить Markdown-ограждение"
                )

                cleaned_text = clean_json_response(generated_text)

                try:
                    world_data = json.loads(cleaned_text)
                except json.JSONDecodeError as error:
                    raise RuntimeError(
                        "Модель вернула невалидный JSON"
                    ) from error

            self._validate_world(world_data)

            logger.info(
                "Скелет мира сохранён в story.json: "
                "регионов=%d, NPC=%d",
                len(world_data["regions"]),
                len(world_data["npcs"]),
            )

            return world_data

        except Exception:
            logger.exception("Ошибка генерации скелета мира")
            raise

    @staticmethod
    def _validate_world(world_data: object) -> None:
        """Базовая проверка верхнего уровня структуры."""
        if not isinstance(world_data, dict):
            raise ValueError("Скелет мира должен быть JSON-объектом")

        expected_types = {
            "world": dict,
            "regions": list,
            "npcs": list,
            "factions": list,
            "main_character": dict,
        }

        for field, expected_type in expected_types.items():
            if field not in world_data:
                raise ValueError(
                    f"В скелете отсутствует поле: {field}"
                )

            if not isinstance(world_data[field], expected_type):
                raise ValueError(
                    f"Поле {field} должно иметь тип "
                    f"{expected_type.__name__}"
                )