from sentence_transformers import SentenceTransformer



class EmbeddingService:
    """Создаёт embeddings из текстов с помощью локальной модели."""

    def __init__(self, model_name: str = "intfloat/multilingual-e5-base"):
        self.model = SentenceTransformer(model_name)

    def encode(self, text: str) -> list[float]:
        """Создаёт embedding для одного текста."""
        return self.model.encode(
            text,
            normalize_embeddings=True,
        ).tolist()

    def encode_many(self, texts: list[str]) -> list[list[float]]:
        """Создаёт embeddings для нескольких текстов."""
        return self.model.encode(
            texts,
            normalize_embeddings=True,
        ).tolist()