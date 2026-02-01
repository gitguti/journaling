from datetime import datetime

from pydantic import BaseModel


# --- Request schemas ---


class EntryCreate(BaseModel):
    question_1: str
    question_2: str


class TagsUpdate(BaseModel):
    tags: list[str]


# --- Response schemas ---


class TagOut(BaseModel):
    id: str
    name: str
    color: str


class EntryOut(BaseModel):
    id: str
    title: str
    date: datetime
    question_1: str
    question_2: str
    tags: list[str]
    created_at: datetime
    updated_at: datetime


class EntryListItem(BaseModel):
    id: str
    title: str
    date: datetime
    tags: list[str]
    preview: str
