from sqlalchemy import select
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Words, Blocks

from fastapi import Depends
from typing import Annotated
from sqlalchemy.orm import Session
from sqlalchemy.ext.asyncio import AsyncSession
from app.src.database import async_session

async def get_session() -> AsyncSession:
    async with async_session() as session:
        yield session

db_dependency = Annotated[Session, Depends(get_session)]

word_to_color_cache = {}

async def load_word_to_color(db: db_dependency):
    global word_to_color_cache
    result = await db.execute(
        select(Words, Blocks).join(Blocks, Words.block_id == Blocks.id)
    )
    word_to_color_cache = {word_model.words: block_model.color for word_model, block_model in result.fetchall()}

def get_word_color(word):
    return word_to_color_cache.get(word, None)
