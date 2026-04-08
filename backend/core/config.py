import os
from dotenv import load_dotenv
import base64

load_dotenv()
# будет неаходить env так как пайтон запускается в backend/ 
class Config:
    YANDEX_API_KEY = os.getenv("YANDEX_API_KEY",'')
    YANDEX_ID_KEY = os.getenv("YANDEX_ID_KEY",'')
   # TELEGRAM_TOKEN = os.getenv("telegrambot_api")
    #DEBUG = os.getenv("DEBUG", "False") == "True" 
    #MAX_TOKENS = int(os.getenv("MAX_TOKENS", "2000"))
   # TEMPERATURE = float(os.getenv("TEMPERATURE", "0.3"))
   # PROMPT_B64 = os.getenv("prompt")
    #if not PROMPT_B64:
     #   raise ValueError("PROMPT_B64 не найден в .env!")
    
    # Декодируем
   # prompt= base64.b64decode(PROMPT_B64.encode()).decode('utf-8')
    model=os.getenv("model_api")
