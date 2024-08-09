from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

SQLALCHEMY_DATABASE_URL = 'mysql+aiomysql://root:as15o7709PNlMSaka5qZ@database-1.crsukigqomda.ap-northeast-2.rds.amazonaws.com/testdatabase'

engine = create_async_engine(SQLALCHEMY_DATABASE_URL, echo=True)
async_session = sessionmaker(
    bind=engine, class_=AsyncSession, expire_on_commit=False
)

async def get_session() -> AsyncSession:
    async with async_session() as session:
        yield session
