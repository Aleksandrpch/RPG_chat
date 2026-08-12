from qdrant_client import models        # Библиотека
from .qdrant_conn import get_qdrant_client

# Файл запускается один раз и создает структуру бд
COLLECTION_NAME = "game_memory"
VECTOR_SIZE = 768  # Размер должен совпадать с размером векторов (моделью которая их создает)

def create_collection() -> None:
    client = get_qdrant_client()

    if not client.collection_exists(COLLECTION_NAME):
        client.create_collection(
                collection_name=COLLECTION_NAME,
                vectors_config=models.VectorParams(
                    size=VECTOR_SIZE,
                    distance=models.Distance.COSINE,
                ),
            )

    client.create_payload_index(
        collection_name=COLLECTION_NAME,
        field_name="chat_id",
        feild_schema= PayloadSchemaType.KEYWORD,
    )