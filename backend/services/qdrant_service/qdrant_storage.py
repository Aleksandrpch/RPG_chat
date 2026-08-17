from typing import Any
from qdrant_client import models
from .qdrant_conn import get_qdrant_client



COLLECTION_NAME = "game_memory"


class QdrantStorage:
    """Хранилище векторов и метаданных в Qdrant."""


    def __init__(self):
        self.client = get_qdrant_client()


    def add(
        self,
        point_id: str,
        vector: list[float],
        payload: dict[str, Any],
    ) -> None:
        """Добавляет или обновляет один документ."""
        self.client.upsert(
            collection_name=COLLECTION_NAME,
            points=[
                models.PointStruct(
                    id=point_id,
                    vector=vector,
                    payload=payload,
                )
            ],
        )


    def add_many(
        self,
        points: list[models.PointStruct],
    ) -> None:
        """Добавляет или обновляет несколько документов."""
        self.client.upsert(
            collection_name=COLLECTION_NAME,
            points=points,
        )


    def search(
        self,
        vector: list[float],
        chat_id: str,
        limit: int = 10,
    ) -> list:
        """Ищет релевантные документы только внутри указанного чата."""
        return self.client.query_points(
            collection_name=COLLECTION_NAME,
            query=vector,
            query_filter=models.Filter(
                must=[
                    models.FieldCondition(
                        key="chat_id",
                        match=models.MatchValue(value=chat_id),
                    )
                ]
            ),
            limit=limit,
        ).points


    def delete(self, point_id: str) -> None:
        """Удаляет один документ."""
        self.client.delete(
            collection_name=COLLECTION_NAME,
            points_selector=models.PointIdsList(
                points=[point_id],
            ),
        )