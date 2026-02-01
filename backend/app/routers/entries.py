import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException
from neo4j import AsyncSession

from app.database import get_db
from app.models.schemas import EntryCreate, EntryListItem, EntryOut, TagsUpdate
from app.services.tagging import auto_tag, generate_title

router = APIRouter(prefix="/entries", tags=["entries"])


@router.post("", response_model=EntryOut, status_code=201)
async def create_entry(body: EntryCreate, db: AsyncSession = Depends(get_db)):
    entry_id = str(uuid.uuid4())
    now = datetime.now(timezone.utc)
    title = generate_title(body.question_1)
    combined_text = f"{body.question_1} {body.question_2}"
    tags = auto_tag(combined_text)

    query = """
    CREATE (e:Entry {
        id: $id,
        title: $title,
        date: datetime($date),
        question_1: $q1,
        question_2: $q2,
        created_at: datetime($created_at),
        updated_at: datetime($updated_at)
    })
    WITH e
    UNWIND $tags AS tag_name
        MATCH (t:Tag {name: tag_name})
        CREATE (e)-[:TAGGED_AS]->(t)
    RETURN e.id AS id
    """

    # If no tags matched, use a simpler query without UNWIND
    if not tags:
        query = """
        CREATE (e:Entry {
            id: $id,
            title: $title,
            date: datetime($date),
            question_1: $q1,
            question_2: $q2,
            created_at: datetime($created_at),
            updated_at: datetime($updated_at)
        })
        RETURN e.id AS id
        """

    date_str = now.isoformat()
    await db.run(
        query,
        id=entry_id,
        title=title,
        date=date_str,
        q1=body.question_1,
        q2=body.question_2,
        created_at=date_str,
        updated_at=date_str,
        tags=tags,
    )

    return EntryOut(
        id=entry_id,
        title=title,
        date=now,
        question_1=body.question_1,
        question_2=body.question_2,
        tags=tags,
        created_at=now,
        updated_at=now,
    )


@router.get("", response_model=list[EntryListItem])
async def list_entries(db: AsyncSession = Depends(get_db)):
    query = """
    MATCH (e:Entry)
    OPTIONAL MATCH (e)-[:TAGGED_AS]->(t:Tag)
    RETURN e.id AS id, e.title AS title, e.date AS date,
           e.question_1 AS question_1, collect(t.name) AS tags
    ORDER BY e.date DESC
    """
    result = await db.run(query)
    records = [record async for record in result]

    entries = []
    for r in records:
        q1 = r["question_1"] or ""
        preview = q1[:100] + ("…" if len(q1) > 100 else "")
        entries.append(
            EntryListItem(
                id=r["id"],
                title=r["title"],
                date=r["date"].to_native(),
                tags=[t for t in r["tags"] if t is not None],
                preview=preview,
            )
        )
    return entries


@router.get("/{entry_id}", response_model=EntryOut)
async def get_entry(entry_id: str, db: AsyncSession = Depends(get_db)):
    query = """
    MATCH (e:Entry {id: $id})
    OPTIONAL MATCH (e)-[:TAGGED_AS]->(t:Tag)
    RETURN e.id AS id, e.title AS title, e.date AS date,
           e.question_1 AS question_1, e.question_2 AS question_2,
           e.created_at AS created_at, e.updated_at AS updated_at,
           collect(t.name) AS tags
    """
    result = await db.run(query, id=entry_id)
    record = await result.single()

    if not record:
        raise HTTPException(status_code=404, detail="Entry not found")

    return EntryOut(
        id=record["id"],
        title=record["title"],
        date=record["date"].to_native(),
        question_1=record["question_1"],
        question_2=record["question_2"],
        tags=[t for t in record["tags"] if t is not None],
        created_at=record["created_at"].to_native(),
        updated_at=record["updated_at"].to_native(),
    )


@router.patch("/{entry_id}/tags", response_model=EntryOut)
async def update_entry_tags(
    entry_id: str, body: TagsUpdate, db: AsyncSession = Depends(get_db)
):
    # Verify entry exists
    check = await db.run("MATCH (e:Entry {id: $id}) RETURN e.id AS id", id=entry_id)
    record = await check.single()
    if not record:
        raise HTTPException(status_code=404, detail="Entry not found")

    # Remove existing tag relationships and create new ones
    now = datetime.now(timezone.utc)
    date_str = now.isoformat()

    await db.run(
        """
        MATCH (e:Entry {id: $id})-[r:TAGGED_AS]->()
        DELETE r
        """,
        id=entry_id,
    )

    if body.tags:
        await db.run(
            """
            MATCH (e:Entry {id: $id})
            SET e.updated_at = datetime($updated_at)
            WITH e
            UNWIND $tags AS tag_name
                MATCH (t:Tag {name: tag_name})
                CREATE (e)-[:TAGGED_AS]->(t)
            """,
            id=entry_id,
            tags=body.tags,
            updated_at=date_str,
        )
    else:
        await db.run(
            """
            MATCH (e:Entry {id: $id})
            SET e.updated_at = datetime($updated_at)
            """,
            id=entry_id,
            updated_at=date_str,
        )

    # Return updated entry
    return await get_entry(entry_id, db)
