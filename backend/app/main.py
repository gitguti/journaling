from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.database import close_db
from app.routers import entries, tags


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield
    await close_db()


app = FastAPI(
    title="Learning Journal API",
    description="Backend for the Learning Journal app — capture daily learnings with auto-tagging.",
    version="1.0.0",
    lifespan=lifespan,
)

app.include_router(entries.router)
app.include_router(tags.router)


@app.get("/health")
async def health():
    return {"status": "ok"}
