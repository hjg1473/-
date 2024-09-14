import os
from dotenv import load_dotenv
from functools import lru_cache

load_dotenv()

class Settings():
  SECRET_KEY = os.environ.get("SECRET_KEY")
  ALGORITHM = os.environ.get("ALGORITHM")
#   DB_PORT = int(os.environ.get("DB_PORT"))

@lru_cache
def get_settings():
    return Settings()

settings = get_settings()