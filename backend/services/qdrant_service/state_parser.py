from typing import Any

def parse_state(
    state: dict[str, Any], 
    *, 
    chat_id: str
) -> list[dict[str, Any]]:
    """
    Преобразует state в набор документов для Qdrant.

    Каждый параметр state становится отдельным документом.
    Embedding здесь НЕ создаём — этим займётся следующий слой.
    """

    documents = []

    def walk(
        data: dict[str, Any],
        path: list[str],
    ) -> None:
        for key, value in data.items():
            current_path = [*path, key]

            if isinstance(value, dict):
                # Если это объект с value + description,
                # считаем его конечным параметром.
                if "value" in value:
                    documents.append({
                        "text": _build_text(value),
                        "payload": {
                            "chat_id": chat_id,
                            "path": ".".join(current_path),
                            "value": value["value"],
                            "description": value.get("description"),
                        },
                    })
                else:
                    walk(value, current_path)

            elif isinstance(value, list):
                for index, item in enumerate(value):
                    if isinstance(item, dict):
                        walk(item, [*current_path, str(index)])

            else:
                documents.append({
                    "text": f"{'.'.join(current_path)}: {value}",
                    "payload": {
                        "chat_id": chat_id,
                        "path": ".".join(current_path),
                        "value": value,
                    },
                })

    walk(state, [])

    return documents

def _build_text(data: dict[str, Any]) -> str:
    """Формирует текст, который позже будет превращён в embedding."""

    value = data.get("value")
    description = data.get("description")

    if description:
        return f"{description}: {value}"

    return str(value)