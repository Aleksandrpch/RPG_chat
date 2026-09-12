import asyncio




SEARCH_INFO_SCHEMA = {
    "type": "function",
    "name": "search_memory",
    "description": (
        "Выполняет семантический поиск информации в памяти игры (RAG). "
        "ВСЕГДА вызывай этот тул, если в действии игрока встречается: "
        "имя NPC, название локации, предмета, фракции, события или любого другого игрового объекта, "
        "о котором ты не знаешь из текущего контекста. "
        "Не выдумывай факты о неизвестных сущностях — сначала найди их через этот тул. "
        "Передавай список запросов: по одному запросу на каждую неизвестную сущность. "
        "Не вызывай для обычных действий (атака, движение, разговор с уже известным NPC). "
        "Примеры: "
        "Игрок: 'Иду к королю Артуру' → search(['король Артур']). "
        "Игрок: 'Атакую гоблина дубиной' → НЕ вызывать (гоблин — обычный враг). "
        "Игрок: 'Что я знаю о Леди Моргане?' → search(['Леди Моргана']). "
        "Игрок: 'Открываю сундук в пещере Забвения' → search(['сундук в пещере Забвения'])."   
        ),

    "parameters": {
        "type": "object",
        "properties": {
            "queries": {
                "type": "array",
                "description": "Список запросов для поиска информации",
                "items": {"type": "string", "maxLength": 200},
                "minItems": 1,
                "maxItems": 10, 
            },
        },
        "required": [
            "queries",
        ],
        "additionalProperties": False,
    },
}


async def search_memory(
    qdrant_memory: QdrantMemory,
    embedding_service: EmbeddingService,
    chat_id: str,
    queries: list[str],
):
    if not queries:
        return []

    vectors = await asyncio.to_thread(
        embedding_service.encode_queries,
        queries,
    )

    batch_results = await qdrant_memory.search_many(
        vectors=vectors,
        chat_id=chat_id,
    )

    unique_points = {}

    for result in batch_results:
        for point in result.points:
            point_id = str(point.id)

            if (
                point_id not in unique_points
                or point.score > unique_points[point_id]["score"]
            ):
                unique_points[point_id] = {
                    "id": point_id,
                    "score": point.score,
                    "payload": point.payload,
                }

    return list(unique_points.values())