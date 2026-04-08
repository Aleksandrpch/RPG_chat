import json

# Загружаем story.json
with open('story.json', 'r', encoding='utf-8') as f:
    story = json.load(f)

# Генерируем Mermaid-код
mermaid = "graph TD\n"
mermaid += "    classDef start fill:#51cf66,stroke:#333,stroke-width:2px\n"
mermaid += "    classDef ending fill:#ff6b6b,stroke:#333,stroke-width:2px\n"
mermaid += "    classDef normal fill:#4dabf7,stroke:#333,stroke-width:2px\n\n"

start_scene = story.get('start_scene', '1')

# Добавляем все сцены
for scene in story['scenes']:
    scene_id = scene['scene_id']
    text = scene['text'][:60].replace('"', '\\"').replace('\n', ' ')
    
    mermaid += f'    {scene_id}["{scene_id}. {text}"]\n'

mermaid += "\n"

# Добавляем переходы
for scene in story['scenes']:
    for choice in scene.get('choices', []):
        next_scene = choice.get('next_scene')
        if next_scene:
            choice_text = choice.get('text', '...')[:40].replace('"', '\\"')
            mermaid += f'    {scene["scene_id"]} -->|"{choice_text}"| {next_scene}\n'

mermaid += "\n"
mermaid += f'    class {start_scene} start\n'
for scene in story['scenes']:
    if scene.get('is_ending'):
        mermaid += f'    class {scene["scene_id"]} ending\n'
    elif scene["scene_id"] != start_scene:
        mermaid += f'    class {scene["scene_id"]} normal\n'

# Сохраняем в файл
with open('story_graph.mmd', 'w', encoding='utf-8') as f:
    f.write(mermaid)

print("✅ Mermaid-код сохранён в story_graph.mmd")
print("\n📌 Что делать:")
print("1. Открой https://mermaid.live/")
print("2. Скопируй ВСЁ содержимое файла story_graph.mmd")
print("3. Вставь в левую панель на сайте")
print("4. Справа появится граф!")
print("\nИли просто открой story_graph.mmd в блокноте и скопируй оттуда")