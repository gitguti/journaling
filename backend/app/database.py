from neo4j import AsyncGraphDatabase

from app.config import settings

driver = AsyncGraphDatabase.driver(
    settings.neo4j_uri,
    auth=(settings.neo4j_user, settings.neo4j_password),
)


async def get_db():
    async with driver.session() as session:
        yield session


async def close_db():
    await driver.close()
