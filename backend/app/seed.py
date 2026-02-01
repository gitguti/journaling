"""Seed initial tags into Neo4j.

Run with: python -m app.seed
"""

import asyncio
import uuid

from app.database import driver, close_db

TAGS = [
    {"name": "#adoption", "color": "#4CAF50"},
    {"name": "#ai-process", "color": "#9C27B0"},
    {"name": "#design-decisions", "color": "#2196F3"},
    {"name": "#0-to-1", "color": "#FF9800"},
    {"name": "#data-insights", "color": "#00BCD4"},
    {"name": "#tools", "color": "#795548"},
    {"name": "#automation", "color": "#607D8B"},
    {"name": "#full-stack", "color": "#E91E63"},
]


async def seed_tags():
    async with driver.session() as session:
        # Create uniqueness constraint on Tag.name
        await session.run(
            "CREATE CONSTRAINT tag_name_unique IF NOT EXISTS "
            "FOR (t:Tag) REQUIRE t.name IS UNIQUE"
        )
        # Create uniqueness constraint on Entry.id
        await session.run(
            "CREATE CONSTRAINT entry_id_unique IF NOT EXISTS "
            "FOR (e:Entry) REQUIRE e.id IS UNIQUE"
        )

        for tag in TAGS:
            await session.run(
                """
                MERGE (t:Tag {name: $name})
                ON CREATE SET t.id = $id, t.color = $color
                """,
                id=str(uuid.uuid4()),
                name=tag["name"],
                color=tag["color"],
            )
            print(f"  Seeded tag: {tag['name']}")

    await close_db()
    print("Done — all tags seeded.")


if __name__ == "__main__":
    asyncio.run(seed_tags())
