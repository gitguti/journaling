from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    neo4j_uri: str = "bolt://localhost:7687"
    neo4j_user: str = "neo4j"
    neo4j_password: str = "password"
    api_key: str = "journal-web-2026-secret"
    allowed_origins: list[str] = ["http://localhost:5173", "http://localhost:4173", "https://web-lemon-two-54.vercel.app"]

    model_config = {"env_file": ".env"}


settings = Settings()
