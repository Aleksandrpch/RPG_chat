from qdrant_client import QdrantClient
import os
from dotenv import load_dotenv

load_dotenv()


def get_qdrant_client() -> QdrantClient:
    ''' Возвращает соединение с бд'''
    return QdrantClient(
        host=os.getenv("QDRANT_HOST", "localhost"),
        port=int(os.getenv("QDRANT_PORT", "6333")),
    )