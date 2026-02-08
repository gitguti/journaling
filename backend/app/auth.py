from fastapi import HTTPException, Security
from fastapi.security import APIKeyHeader

from app.config import settings

api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False)


async def verify_api_key(api_key: str = Security(api_key_header)):
    if not settings.api_key:
        return  # No key configured = no auth required
    if api_key != settings.api_key:
        raise HTTPException(status_code=401, detail="Invalid API key")
