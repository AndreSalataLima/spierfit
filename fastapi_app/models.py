from sqlalchemy import Column, Integer, String, DateTime, BigInteger
from database import Base

class DataPoint(Base):
    __tablename__ = "data_points"

    id = Column(BigInteger, primary_key=True)
    value = Column(Integer)
    mac_address = Column(String)
    recorded_at = Column(DateTime)
    created_at = Column(DateTime, nullable=False)
    updated_at = Column(DateTime, nullable=False)
    exercise_set_id = Column(BigInteger)  # Removed ForeignKey constraint

    # Comment out or remove the relationship
    # exercise_set = relationship("ExerciseSet", back_populates="data_points")
