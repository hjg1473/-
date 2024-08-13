import os
from dotenv import load_dotenv
from functools import lru_cache

load_dotenv()

class Settings():
  SECRET_KEY = os.environ.get("SECRET_KEY")
  ALGORITHM = os.environ.get("ALGORITHM")
  ACCESS_TOKEN_EXPIRE_MINUTES = int(os.environ.get("ACCESS_TOKEN_EXPIRE_MINUTES"))
  REFRESH_TOKEN_EXPIRE_DAYS = int(os.environ.get("REFRESH_TOKEN_EXPIRE_DAYS"))
#   DB_PORT = int(os.environ.get("DB_PORT"))

@lru_cache
def get_settings():
    return Settings()

settings = get_settings()