from fastapi import APIRouter, Depends
from neo4j import AsyncSession

from app.database import get_db
from app.models.schemas import TagOut

router = APIRouter(prefix="/tags", tags=["tags"])


@router.get("", response_model=list[TagOut])
async def list_tags(db: AsyncSession = Depends(get_db)):
    query = """
    MATCH (t:Tag)
    RETURN t.id AS id, t.name AS name, t.color AS color
    ORDER BY t.name
    """
    result = await db.run(query)
    records = [record async for record in result]
    return [
        TagOut(id=r["id"], name=r["name"], color=r["color"]) for r in records
    ]
