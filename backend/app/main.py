from contextlib import asynccontextmanager
from fastapi import FastAPI
from services.postgre_service.init_postgresql  import create_postgre
from services.postgre_service.postgre_conn  import init_db, close_db
from services.qdrant_service.init_qdrant import create_qdrant
from backend.services.orchestrator_service.init_LLM import LLMConnection

@asynccontextmanager
async def lifespan(app: FastAPI):

     # PostgreSQL
    await init_db()
    await create_postgre()

    # LLM
    app.state.llm = LLMConnection()
    app.state.orchestrator = GameOrchestrator(llm=app.state.llm,)
    # Qdrant
    app.state.qdrant = await create_qdrant()

    yield

    # Закрываем ресурсы
    await app.state.llm.close()
    await app.state.qdrant.close()
    await close_db()


app = FastAPI(lifespan=lifespan)