from app.src.config import TokenSettings

SECRET_KEY = TokenSettings.SECRET_KEY
ALGORITHM = TokenSettings.ALGORITHM
ACCESS_TOKEN_EXPIRE_MINUTES = 30
REFRESH_TOKEN_EXPIRE_DAYS = 7