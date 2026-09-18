from typing import Any

from qdrant_client import models

from .qdrant_conn import get_qdrant_client


COLLECTION_NAME = "game_memory"


class QdrantMemory:
    """Хранилище векторов и метаданных в Qdrant."""

    def __init__(self):
        self.client = get_qdrant_client()

    async def add(
        self,
        point_id: str,
        vector: list[float],
        payload: dict[str, Any],
    ) -> None:

        await self.client.upsert(
            collection_name=COLLECTION_NAME,
            points=[
                models.PointStruct(
                    id=point_id,
                    vector=vector,
                    payload=payload,
                )
            ],
        )

    async def add_many(
        self,
        points: list[models.PointStruct],
    ) -> None:

        await self.client.upsert(
            collection_name=COLLECTION_NAME,
            points=points,
        )

    async def search(
        self,
        vector: list[float],
        chat_id: str,
        limit: int = 10,
    ) -> list:

        result = await self.client.query_points(
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
        )

        return result.points

    async def search_many(
        self,
        vectors: list[list[float]],
        chat_id: str,
        limit: int = 5,
    ):

        filter_ = models.Filter(
            must=[
                models.FieldCondition(
                    key="chat_id",
                    match=models.MatchValue(value=chat_id),
                )
            ]
        )
        # todo: потом кастомизировать возвращаемый payload для экономии:
        # with_payload=[
        #     "summary",
        #     "event_id",
        #     "importance",
        #     "entities",
        #     "cause_event_ids",
        # ]
        requests = [
            models.QueryRequest(
                query=vector,
                filter=filter_,
                limit=limit,
                with_payload=True,
                with_vector=False,
            )
            for vector in vectors
        ]

        return await self.client.query_batch_points(
            collection_name=COLLECTION_NAME,
            requests=requests,
        )
    

    async def delete(
        self,
        point_id: str,
    ) -> None:

        await self.client.delete(
            collection_name=COLLECTION_NAME,
            points_selector=models.PointIdsList(
                points=[point_id],
            ),
        )