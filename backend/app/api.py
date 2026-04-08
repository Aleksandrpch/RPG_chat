
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