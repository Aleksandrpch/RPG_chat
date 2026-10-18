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
        max_output_tokens: int | None = None,
    ):
        params = {
            "model": self.model,
            "input": input,
        }

        if tools:
            params["tools"] = tools

        if max_output_tokens is not None:
            params["max_output_tokens"] = max_output_tokens

        return await self.client.responses.create(**params)


    async def close(self):
        await self.client.close()