from datetime import datetime
from services.llm.story_generator.world_gen import WorldGenerator
from core.postgredatabase import *

@router.get("/world/{world_id}/characters")
async def get_characters(world_id: str):
    # Загружаем story.json (потом из БД)
    with open("story.json", "r", encoding="utf-8") as f:
        data = json.load(f)
    return {"characters": data.get("characters", [])}


@router.post("/world/{world_id}/character/generate")
async def generate_character(
    character_template: dict,  # ← JSON от Flutter
    background_tasks: BackgroundTasks
):
    world = await db.get_world(world_id)
    
    generator = CharacterGenerator()
    new_character = await generator.generate_for_world(
        world_skeleton=world['skeleton'],
        user_character_json=character_template
    )
    
    return new_character


@router.post("")


@router.post("/create_world")
async def create_world_id(
     character_data: dict, 
):
    world_id=DateTime.now().microsecondsSinceEpoch.toString()
    try:
        gen=WorldGenerator()
        world_skelet=await gen(character_data)   # Сделать цикл из агентов чтобы проверять мир
        character= world_skelet.get("main_character")
        db=save_world
        await db.save_world(world_id,world_skelet )
        return {
            "world_id": world_id,
            "character": character
        }
    except: 
        print("Ошибка в '/create_world'")

@router.put("/character/update")
async def update_character(world_id:str, character_data: dict):
    world_skelet=await get_world(world_id) 
    if not world_skeleton:
        raise HTTPException(404, "World not found")
    world_skelet["main_character"].update(character_data)
    await save_world(world_id, world_skelet)
    