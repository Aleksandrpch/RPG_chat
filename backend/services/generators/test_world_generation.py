import asyncio
import json
from services.Generators.story_generator.world_gen import WorldGenerator
#cd backend
#venv\Scripts\activate
#python -m services.llm.story_generator.test_story_generation
async def test_generation():
    # Создаём объект с параметрами (как в GUI)
    ''' description = "Наш персонаж оказывается в башне(он может быть как известным жителем так и неизвестным бродягой со своей историей), где каждый этаж отдельный мир(это может быть какой то известный мир из лора по типу асгарда и олимпа или что-то неизведанное со своей фауной и флорой), у этой башни нет начала и конца она покрывает бесконечное множество миров настолько она великая. Нунжо сгенерировать сюжет, который будет связывать какие то этажи между собой и параллельно отвечать на вопросы о башне кто ее создал зачем она существует.Сюжет должен заатвлять делать нравственные выборы и замечать какие то логические цепочки связности в сюежете. Не надо писать что игрок оказался в башне."
    genre = "RPG" #adventure
    heroes = ["Необходимые для сюжета персонажи"]
    mood = "Фантастическое"'''
    
    try:
        generator = WorldGenerator()    
        result = await generator({})
        # Сохраняем результат в файл
        with open('story.json', 'w', encoding='utf-8') as f:
            json.dump(result, f, ensure_ascii=False, indent=2)
        
        print("✅ Сюжет сгенерирован!")

        print(f"\n📊 Статистика:")
        print(f"  - Название мира: {result.get('world', {}).get('name', 'Нет')}")
        print(f"  - Регионов: {len(result.get('regions', []))}")
        print(f"  - NPC: {len(result.get('npcs', []))}")
        print(f"  - Фракций: {len(result.get('factions', []))}")
        print(f"  - Слухов: {len(result.get('rumors', []))}")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")



# Запускаем
asyncio.run(test_generation())
