from contextlib import asynccontextmanager

from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.auth import verify_api_key
from app.config import settings
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

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(entries.router, dependencies=[Depends(verify_api_key)])
app.include_router(tags.router, dependencies=[Depends(verify_api_key)])


@app.get("/health")
async def health():
    return {"status": "ok"}
