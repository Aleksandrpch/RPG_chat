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

    async def close(self):
        await self.client.close()