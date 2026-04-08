import json
import re
from core.config import Config  # абсолютный импорт 
from openai import AsyncOpenAI


def clean_json_response(text: str) -> str:
    text = re.sub(r'^```(?:json)?\s*\n?', '', text, flags=re.MULTILINE)
    text = re.sub(r'\n?```\s*$', '', text, flags=re.MULTILINE)
    text = text.strip()
    
    # Если текст начинается с { и заканчивается }, это объект, а не массив
    # Нам нужен массив, но в ответе пришёл объект с полями world, locations и т.д.
    # Поэтому мы просто возвращаем текст как есть — он уже валидный JSON
    return text


class WorldGenerator:

    def __init__(self):
            self.config = Config()
            if not self.config.YANDEX_ID_KEY or not self.config.YANDEX_API_KEY:
                raise ValueError("YANDEX_API_KEY и YANDEX_ID_KEY должны быть установлены в .env файле.")
            # 1. Формируем путь к модели
            self.model=self.config.model
            # self.tools = [self.search_tool.to_yandex_format()]
            self.client = AsyncOpenAI(
                base_url="https://rest-assistant.api.cloud.yandex.net/v1",
                api_key=self.config.YANDEX_API_KEY,
                project=self.config.YANDEX_ID_KEY
            )
        
    async def __call__(self, question: dict) -> dict:
        #Вызов агента (объект можно вызывать как функцию)
        response = await self.client.responses.create(  
        model=self.model,
        # instructions=self.config.prompt,
        instructions="""Ты — архитектор открытых игровых миров для RPG.
            Твоя задача — создать СТАТИЧЕСКИЙ СКЕЛЕТ МИРА, который будет использоваться как неизменная база для динамической игры.

            ФОРМАТ ВЫВОДА:
            Верни ТОЛЬКО валидный JSON. Без комментариев, без markdown.

            СТРУКТУРА JSON:
            {
            "world": {
                "name": "Название мира",
                "core_mysteries": ["Загадка 1", "Загадка 2", "Загадка 3"],
                "rules": "Основные законы этого мира (1-2 предложения)"
            },
            "regions": [
                {
                "id": "region_1",
                "name": "Название региона (мира/этажа/области)",
                "description": "Одно предложение, передающее атмосферу",
                "locations": [
                    {
                    "id": "loc_1_1",
                    "name": "Конкретная локация внутри региона",
                    "description": "Что это за место",
                    "inhabitants": ["NPC 1", "NPC 2"],
                    "points_of_interest": ["Интересное место 1", "Интересное место 2"],
                    "possible_events": ["Что может здесь случиться", "Другой вариант"]
                    }
                ],
                "inhabitants": ["NPC 1", "NPC 2"],
                "factions": ["Фракция 1", "Фракция 2"],
                "connections": ["region_2", "region_3"]
                }
            ],
            "npcs": [
                {
                "id": "npc_1",
                "name": "Имя NPC",
                "region": "id региона",
                "location": "id конкретной локации",
                "role": "Кто он",
                "personality": "Краткое описание характера",
                "secret": "Что знает или скрывает (одно предложение)",
                "motivation": "Чего хочет от героя",
                "quests": ["Может дать квест 1", "Может дать квест 2"]
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
            "rumors": [
                {
                "id": "rumor_1",
                "text": "Информация,слух",
                "location": "где можно услышать",
                "truth": "Что на самом деле"
                }
            ]
            "characters": [
                {
                "id": "char_1",
                "name": "Имя",
                "origin_region": "id региона",
                "backstory": "Предыстория (4-5 предложения)",
                "goal": "Личная цель",
                "skills": [{"name": "...", "description": "..."}],
                "lore_friendly": true(P.S если этот параметр true, это говорит о том что в сюжете используетcя лор персонажа. Например локация олимпа и его мифология для зевса и остальных персонажей с олимпа и тд, а если false,продолжая пример, то персонаж зевс не учавствует в сюжете связанном с олимпом и богами с ним )
                }
            ]
            }
            ПРАВИЛА ДЛЯ ПЕРСОНАЖЕЙ:
            - У каждого 2 уникальных навыка (без цифр они дают  какие уникальные эффекты или способности)
            - Их цели должны пересекаться с загадками мира

            ПРАВИЛА СОЗДАНИЯ:
            1. **Никаких выборов (choices)** — только статические данные.
            2. **Никаких сцен с текстом** — только структура мира.
            3. **Регионов**: 3-5. Это могут быть этажи башни или регионы на одном этаже, но не обязательно.
            4. **В каждом регионе**: 2-3 конкретные локации или больше если потребуется.
            5. **NPC**: 5-8 персонажей, у каждого могут быть квесты или тайны.
            6. **Не зацикливайся на башне**. Пусть мир будет разнообразным.
            7. **Добавь слухи** — они создают атмосферу и дают подсказки.
            8. **Связи между регионами** не обязательно линейны. Игрок может выбирать, куда идти.
            9. **Не раскрывай все тайны сразу**. Главные загадки — только в core_mysteries.
            10. **Используй нейтральные термины**: "герой", "странник", "путник".

            ВАЖНО:
            - Описания должны быть КРАТКИМИ (1 предложение).
            - Не добавляй художественный текст.
            - Только факты и структура.
            Требования:
            - примерно 3-5 регионов (миров/этажей/областей) по необохдимости может быть больше или меньше
            - В каждом регионе примерно 2-3 конкретные локации по необохдимости может быть больше или меньше
            - NPC с квестами и тайнами
            - Слухи, которые можно услышать
            - Нелинейные связи между регионами
            - Главные загадки мира в core_mysteries
            
            Требования:
            - примерно 3-5 регионов (миров/этажей/областей) по необохдимости может быть больше или меньше
            - В каждом регионе примерно 2-3 конкретные локации по необохдимости может быть больше или меньше
            - NPC с квестами и тайнами
            - Слухи, которые можно услышать
            - Нелинейные связи между регионами
            - Главные загадки мира в core_mysteries
            """,
           # сделать настройку промпта по переданным параметрам 
           # - **Концепция**: {story_object.description}
           #- **Жанр**: {story_object.genre}
           # - **Ключевые персонажи**: {', '.join(story_object.heroes) if story_object.heroes else 'Не заданы, придумай сам'}
           #- **Настроение**: {story_object.mood}

        #tools=self.tools,
        
        input = f"Создай мир с главным персонажем со следующими параметрами: {question} если параметров нет, то сделай мир с 3 возможными для выбора персонажами.Верни только json",
    
        
        #max_output_tokens=self.config.MAX_TOKENS,
        #temperature=self.config.TEMPERATURE,
        #store=True
        )
        try:
                result_data = json.loads(response.output_text)
                with open('w','story.json') as f:
                    f.write(result_data)
        except (json.JSONDecodeError, KeyError):
                generated_text = response.output_text

                # Очищаем от markdown
                cleaned_json_text = clean_json_response(generated_text)

                # Парсим JSON
                try:
                    cleaned_json_text = json.loads(cleaned_json_text)
                except json.JSONDecodeError as e:
                    print(f"Ошибка парсинга JSON: {e}")
                    print("Текст, который не удалось распарсить:", cleaned_json_text[:500])
                    raise
