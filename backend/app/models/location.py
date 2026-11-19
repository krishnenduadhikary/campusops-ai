from sqlalchemy import Column, Integer, String, Enum, DateTime, Text
from sqlalchemy.sql import func
from app.db.database import Base
import enum


class LocationType(str, enum.Enum):
    CLASSROOM = "CLASSROOM"
    LABORATORY = "LABORATORY"
    HOSTEL = "HOSTEL"
    OFFICE = "OFFICE"
    CANTEEN = "CANTEEN"
    LIBRARY = "LIBRARY"
    GARDEN = "GARDEN"
    PARKING = "PARKING"
    CORRIDOR = "CORRIDOR"
    WASHROOM = "WASHROOM"
    OTHER = "OTHER"


class Location(Base):
    __tablename__ = "locations"

    id = Column(Integer, primary_key=True, index=True)
    building = Column(String(100), nullable=False)
    floor = Column(String(20), nullable=True)
    room = Column(String(50), nullable=True)
    location_type = Column(Enum(LocationType), default=LocationType.OTHER)
    description = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())