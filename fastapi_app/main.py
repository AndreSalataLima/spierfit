# main.py

from fastapi import FastAPI, Depends
from pydantic import BaseModel, Field
from datetime import datetime
from sqlalchemy.orm import Session
from database import get_db
from models import DataPoint

app = FastAPI()

class DataPointIn(BaseModel):
    value: int
    mac_address: str
    recorded_at: datetime

    class Config:
        from_attributes = True  # Updated for Pydantic v2
