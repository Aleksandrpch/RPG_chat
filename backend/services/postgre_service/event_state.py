from uuid import UUID

from .postgre_conn import get_pool



     

async def get_related_events(
    *,
    chat_id: str,
    seed_ids: list[str],
    max_depth: int = 3,
    max_events: int = 30,
) -> list[dict]:
    if not seed_ids:
        return []

    if max_depth < 0 or max_events < 1:
        raise ValueError("Некорректные ограничения обхода")

    # Сохраняем порядок кандидатов, убираем повторы.
    seed_ids = list(dict.fromkeys(
        UUID(value) for value in seed_ids
    ))[:max_events]

    pool = get_pool()

    async with pool.acquire() as conn:
        seeds = await conn.fetch(
            """
            SELECT id, cause_event_id, summary, created_at, importance
            FROM event_state
            WHERE chat_id = $1
              AND id = ANY($2::uuid[])
            ORDER BY array_position($2::uuid[], id)
            """,
            UUID(chat_id),
            seed_ids,
        )

        found = {
            row["id"]: {**dict(row), "depth": 0}
            for row in seeds
        }
        frontier = list(found.values())

        for depth in range(1, max_depth + 1):
            remaining = max_events - len(found)

            if not frontier or remaining <= 0:
                break

            frontier_ids = [row["id"] for row in frontier]
            parent_ids = [
                row["cause_event_id"]
                for row in frontier
                if row["cause_event_id"] is not None
            ]

            rows = await conn.fetch(
                """
                SELECT id, cause_event_id, summary,
                       created_at, importance
                FROM event_state
                WHERE chat_id = $1
                  AND (
                      id = ANY($2::uuid[])
                      OR cause_event_id = ANY($3::uuid[])
                  )
                  AND NOT (id = ANY($4::uuid[]))
                ORDER BY importance DESC, created_at DESC, id
                LIMIT $5
                """,
                UUID(chat_id),
                parent_ids,
                frontier_ids,
                list(found),
                remaining,
            )

            frontier = []

            for row in rows:
                event = {**dict(row), "depth": depth}
                found[row["id"]] = event
                frontier.append(event)

    # UUID и datetime превращаем в JSON-совместимые значения.
    return [
        {
            **event,
            "id": str(event["id"]),
            "cause_event_id": (
                str(event["cause_event_id"])
                if event["cause_event_id"] else None
            ),
            "created_at": event["created_at"].isoformat(),
        }
        for event in found.values()
    ]


async def add_event(self, event: WorldEvent, cause_event_id : str = None) -> str:
        pool=get_pool()
        async with pool.acquire() as conn:
            event_id = await conn.fetchval(
                """
                INSERT INTO world_events (chat_id, character_id, event_type, summary, data, cause_event_id, created_at)
                VALUES ($1, $2, $3, $4, $5, $6 NOW())
                """,
                event.chat_id,
                event.character_id,
                event.event_type,
                event.summary,
                json.dumps(event.data),
                cause_event_id
            )
            return str(event_id)
