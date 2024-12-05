# fastapi_app/models.py
from sqlalchemy import Column, Integer, String, DateTime, BigInteger, ForeignKey, Float, Boolean, JSON
from sqlalchemy.orm import relationship
from database import Base
from datetime import datetime

class Machine(Base):
    __tablename__ = 'machines'

    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(String)
    compatible_exercises = Column(JSON, default=[])
    status = Column(String, default='ativo')
    mac_address = Column(String, unique=True, index=True)
    current_user_id = Column(Integer)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relações
    exercise_sets = relationship("ExerciseSet", back_populates="machine")


class ExerciseSet(Base):
    __tablename__ = 'exercise_sets'

    id = Column(BigInteger, primary_key=True, index=True)
    workout_id = Column(BigInteger)
    exercise_id = Column(BigInteger)  # Supondo que há uma tabela 'exercises'
    average_force = Column(Integer)
    energy_consumed = Column(Integer)
    completed = Column(Boolean, default=False)
    machine_id = Column(BigInteger, ForeignKey('machines.id'))
    reps_per_series = Column(JSON, default={})
    power_in_watts = Column(Float)
    reps = Column(Integer)
    sets = Column(Integer)
    weight = Column(Integer)
    duration = Column(Integer)
    rest_time = Column(Integer)
    intensity = Column(String)
    feedback = Column(String)
    max_reps = Column(Integer)
    effort_level = Column(String)
    current_series = Column(Integer, default=1)
    series_completed = Column(Boolean, default=False)
    last_processed_data_id = Column(Integer)
    weight_changes = Column(JSON)
    in_series = Column(Boolean)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relações
    machine = relationship("Machine", back_populates="exercise_sets")
    data_points = relationship("DataPoint", back_populates="exercise_set")


class DataPoint(Base):
    __tablename__ = "data_points"

    id = Column(BigInteger, primary_key=True)
    value = Column(Integer)
    mac_address = Column(String)
    exercise_set_id = Column(BigInteger, ForeignKey('exercise_sets.id'))
    recorded_at = Column(DateTime)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relações
    exercise_set = relationship("ExerciseSet", back_populates="data_points")
