from qdrant_client import AsyncQdrantClient, models # Библиотеки
from qdrant_client.models import PayloadSchemaType


async def create_qdrant() -> AsyncQdrantClient:
    COLLECTION_NAME = "game_memory"
    VECTOR_SIZE = 768

    client = AsyncQdrantClient(
        url="http://localhost:6333"
    )

    if not await client.collection_exists(COLLECTION_NAME):
        await client.create_collection(
            collection_name=COLLECTION_NAME,
            vectors_config=models.VectorParams(
                size=VECTOR_SIZE,
                distance=models.Distance.COSINE,
            ),
        )

        await client.create_payload_index(
            collection_name=COLLECTION_NAME,
            field_name="chat_id",
            field_schema=PayloadSchemaType.KEYWORD,
        )

    return client