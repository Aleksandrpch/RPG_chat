from openai import AsyncOpenAI
from config import Config


class LLMConnection:
    def __init__(self):
        self.config = Config()

        if not self.config.DEEPSEEK_API_KEY:
            raise ValueError(
                "DEEPSEEK_API_KEY должен быть установлен в .env"
            )

        self.model = self.config.model

        self.client = AsyncOpenAI(
            api_key=self.config.DEEPSEEK_API_KEY,
            base_url="https://api.deepseek.com",
        )

    async def generate(
        self,
        input,
        tools=None,
    ):
        response = await self.client.responses.create(
            model=self.model,
            input=input,
            tools=tools,
        )

        return response


    async def _execute_tool(
    self,
    tool_name: str,
    chat_id: str,
    args: dict,
    ):
        if tool_name == "search_memory":
            return await search_memory(
                qdrant_storage=self.qdrant_storage,
                embedding_service=self.embedding_service,
                chat_id=chat_id,
                queries=args["queries"],
            )

        if tool_name == "add_achievement":
            return await add_achievement(
                chat_id=chat_id,
                achievement_name=args["achievement_name"],
                achievement_description=args[
                    "achievement_description"
                ],
            )

        if tool_name == "add_skill":
            return await add_skill(
                chat_id=chat_id,
                skill_name=args["skill_name"],
                skill_description=args["skill_description"],
            )

        raise ValueError(
            f"Неизвестный tool: {tool_name}"
        )

    async def close(self):
        await self.client.close()