from sentence_transformers import SentenceTransformer



class EmbeddingService:
    """Создаёт embeddings с помощью multilingual-e5-base."""

    def __init__(
        self,
        model_name: str = "intfloat/multilingual-e5-base",
    ):
        self.model = SentenceTransformer(model_name)

    def encode_query(self, text: str) -> list[float]:
        return self.model.encode(
            f"query: {text}",
            normalize_embeddings=True,
        ).tolist()

    def encode_queries(
        self,
        texts: list[str],
    ) -> list[list[float]]:
        return self.model.encode(
            [f"query: {text}" for text in texts],
            normalize_embeddings=True,
            batch_size=32,
        ).tolist()

    def encode_passage(self, text: str) -> list[float]:
        return self.model.encode(
            f"passage: {text}",
            normalize_embeddings=True,
        ).tolist()