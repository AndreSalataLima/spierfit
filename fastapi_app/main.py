from fastapi import FastAPI, Depends
from pydantic import BaseModel
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
        orm_mode = True

@app.post("/ingest-data")
def ingest_data(data: DataPointIn, db: Session = Depends(get_db)):
    data_point = DataPoint(
        value=data.value,
        mac_address=data.mac_address,
        recorded_at=data.recorded_at,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )
    db.add(data_point)
    db.commit()
    db.refresh(data_point)
    return {"message": "Data ingested successfully", "data_point_id": data_point.id}
