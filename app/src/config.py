# app/config.py
import os
from dotenv import load_dotenv
from functools import lru_cache

load_dotenv()

class Settings():
  DB_USERNAME = os.environ.get("DB_USERNAME")
  DB_HOST = os.environ.get("DB_HOST")
  DB_PASSWORD = os.environ.get("DB_PASSWORD")
  DB_NAME = os.environ.get("DB_NAME")

@lru_cache
def get_settings():
    return Settings()

settings = get_settings()

class TokenSettings():
  SECRET_KEY = os.environ.get("SECRET_KEY")
  ALGORITHM = os.environ.get("ALGORITHM")
  
@lru_cache
def get_TokenSettings():
    return TokenSettings()

TokenSettings = get_TokenSettings()