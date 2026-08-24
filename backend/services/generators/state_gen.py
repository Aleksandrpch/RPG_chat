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


class StateGenerator:

    def __init__(self):
            self.config = Config()
            if not self.config.YANDEX_ID_KEY or not self.config.YANDEX_API_KEY:
                raise ValueError("YANDEX_API_KEY и YANDEX_ID_KEY должны быть установлены в .env файле.")
            # 1. Формируем путь к модели
            self.model=self.config.model
            # self.tools = [self.search_tool.to_yandex_format()]
            self.client = AsyncOpenAI(
                api_key=self.config.YANDEX_API_KEY,
                project=self.config.YANDEX_ID_KEY,
                base_url="https://rest-assistant.api.cloud.yandex.net/v1"              
            )


       
    async def __call__(self, question: dict) -> dict:
        #Вызов агента (объект можно вызывать как функцию)
        print(self.model)
        response = await self.client.responses.create(  
        model=self.model,
        max_output_tokens=12000,
        # instructions=self.config.prompt,
        instructions="""Ты создаёшь начальное динамическое состояние игры на основе предоставленного skeleton.
                Состояние должно описывать только динамические данные, которые могут изменяться во время игры:
                - местоположение персонажа;
                - состояние и местоположение NPC;
                - состояние важных объектов;
                - отношения, репутацию и другие динамические параметры, если они необходимы для текущего мира.

                Не изменяй и не дублируй неизменяемые данные skeleton без необходимости.
                Не создавай сущности, которых нет в skeleton.

                СТРОГО СОБЛЮДАЙ СТРУКТУРУ:

                Каждый конечный параметр состояния должен иметь вид:

                    {
                        "value": <значение>,
                        "description": "<краткое описание того, что означает значение value для этого параметра>"
                    }

                    Пример:

                    {
                        "character_location": {
                            "value": "loc_1_1",
                            "description": "Главный герой в локации (название локации loc_1_1)"
                        },
                        "npc_states": {
                            "npc_1": {
                                "location": {
                                    "value": "loc_1_1",
                                    "description": "Текущее местоположение NPC в локации такой то (название локации loc_1_1)"
                                },
                                "status": {
                                    "value": "alive_and_available",
                                    "description": "Текущее состояние NPC: живой и доступный"
                                }
                            }
                        }
                    }

                Не помещай value и description на уровень контейнеров.
                Не добавляй description отдельно для всей сущности, если у неё есть отдельные параметры.
                Используй существующие ID из skeleton.

                Верни только валидный JSON без пояснений.
            """,
          

        #tools=self.tools,
        
       # input = f"Верни только json",
    
        
        #max_output_tokens=self.config.MAX_TOKENS,
        #temperature=self.config.TEMPERATURE,
        #store=True
        )
        try:
            # Парсим ответ
            result_data = json.loads(response.output_text)
            
            # Сохраняем в файл
            with open('story.json', 'w', encoding='utf-8') as f:
                json.dump(result_data, f, ensure_ascii=False, indent=2)
            
            print("✅ JSON сохранён в story.json")
            return result_data  # ← ГЛАВНОЕ: возвращаем результат
            
        except (json.JSONDecodeError, KeyError) as e:
            print(f"❌ Ошибка парсинга JSON: {e}")
            generated_text = response.output_text
            print(f"Ответ модели (первые 500 символов): {generated_text[:500] if generated_text else 'None'}")
            
            # Пробуем очистить от markdown
            cleaned_json_text = clean_json_response(generated_text)
            
            try:
                world_data = json.loads(cleaned_json_text)
                # Сохраняем очищенный JSON
                with open('story.json', 'w', encoding='utf-8') as f:
                    json.dump(world_data, f, ensure_ascii=False, indent=2)
                print("✅ Очищенный JSON сохранён в story_cleaned.json")
                return world_data  # ← ГЛАВНОЕ: возвращаем результат
            except json.JSONDecodeError as e2:
                print(f"❌ Ошибка парсинга очищенного JSON: {e2}")
                print(f"Текст: {cleaned_json_text[:500]}")
                raise RuntimeError("Ошибка парсинга очищенного JSON") from e
