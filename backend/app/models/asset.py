from sqlalchemy import Column, Integer, String, Enum, DateTime, Date, Text, ForeignKey
from sqlalchemy.sql import func
from app.db.database import Base
import enum


class AssetStatus(str, enum.Enum):
    WORKING = "WORKING"
    UNDER_MAINTENANCE = "UNDER_MAINTENANCE"
    BROKEN = "BROKEN"
    REPLACED = "REPLACED"
    DISPOSED = "DISPOSED"


class Asset(Base):
    __tablename__ = "assets"

    id = Column(Integer, primary_key=True, index=True)
    asset_code = Column(String(50), unique=True, nullable=False)
    name = Column(String(150), nullable=False)
    category = Column(String(100), nullable=True)
    location_id = Column(Integer, ForeignKey("locations.id"), nullable=True)
    department_id = Column(Integer, ForeignKey("departments.id"), nullable=True)
    purchase_date = Column(Date, nullable=True)
    warranty_end = Column(Date, nullable=True)
    status = Column(Enum(AssetStatus), default=AssetStatus.WORKING)
    last_maintenance = Column(Date, nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())