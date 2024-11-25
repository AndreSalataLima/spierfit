from sqlalchemy import Column, Integer, String, DateTime, BigInteger, ForeignKey
from sqlalchemy.orm import relationship
from database import Base

class DataPoint(Base):
    __tablename__ = "data_points"

    id = Column(BigInteger, primary_key=True)
    value = Column(Integer)
    mac_address = Column(String)
    recorded_at = Column(DateTime)
    created_at = Column(DateTime, nullable=False)
    updated_at = Column(DateTime, nullable=False)
    exercise_set_id = Column(BigInteger, ForeignKey("exercise_sets.id"))

    # Comment out or remove the relationship
    # exercise_set = relationship("ExerciseSet", back_populates="data_points")
