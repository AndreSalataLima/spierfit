# fastapi_app/main.py
from fastapi import FastAPI, Depends
from pydantic import BaseModel
from datetime import datetime
from sqlalchemy.orm import Session
from database import get_db
from models import Machine, ExerciseSet, DataPoint

app = FastAPI()

class DataPointIn(BaseModel):
    value: int
    mac_address: str
    recorded_at: datetime

    class Config:
        from_attributes = True  # Atualizado para compatibilidade com Pydantic v2

@app.post("/ingest-data")
def ingest_data(data: DataPointIn, db: Session = Depends(get_db)):
    # Log para depuração
    print(f"Recebendo dados: {data}")

    # Passo 1: Encontrar a Machine com o mac_address fornecido
    machine = db.query(Machine).filter(Machine.mac_address == data.mac_address).first()
    if not machine:
        return {"error": "Machine com o MAC address fornecido não foi encontrada."}

    # Passo 2: Encontrar o ExerciseSet ativo para esta Machine onde series_completed é False
    exercise_set = (
        db.query(ExerciseSet)
        .filter(
            ExerciseSet.machine_id == machine.id,
            ExerciseSet.completed == False  # Changed from 'series_completed'
        )
        .order_by(ExerciseSet.created_at.desc())
        .first()
    )
    if not exercise_set:
        return {"error": "Nenhum ExerciseSet ativo encontrado para esta Machine."}

    # Passo 3: Criar um novo DataPoint associado ao ExerciseSet encontrado
    data_point = DataPoint(
        value=data.value,
        mac_address=data.mac_address,
        recorded_at=data.recorded_at,
        exercise_set_id=exercise_set.id,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )
    db.add(data_point)
    db.commit()
    db.refresh(data_point)

    # Opcional: Log para confirmação
    print(f"DataPoint criado com ID: {data_point.id} e associado ao ExerciseSet ID: {exercise_set.id}")

    return {"message": "DataPoint salvo com sucesso.", "data_point_id": data_point.id}
