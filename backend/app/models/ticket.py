from sqlalchemy import (
    Column, Integer, String, Text, Boolean,
    Enum, ForeignKey, DateTime, Float
)
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.database import Base
import enum


class TicketStatus(str, enum.Enum):
    OPEN = "OPEN"
    AI_PROCESSED = "AI_PROCESSED"
    ASSIGNED = "ASSIGNED"
    ACCEPTED = "ACCEPTED"
    IN_PROGRESS = "IN_PROGRESS"
    RESOLVED = "RESOLVED"
    CLOSED = "CLOSED"
    CANCELLED = "CANCELLED"
    REJECTED = "REJECTED"
    ESCALATED = "ESCALATED"


class TicketPriority(str, enum.Enum):
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"


class TicketCategory(str, enum.Enum):
    IT = "IT"
    ELECTRICAL = "ELECTRICAL"
    PLUMBING = "PLUMBING"
    CIVIL = "CIVIL"
    HOUSEKEEPING = "HOUSEKEEPING"
    SECURITY = "SECURITY"
    CANTEEN = "CANTEEN"
    HORTICULTURE = "HORTICULTURE"
    OTHER = "OTHER"


class Ticket(Base):
    __tablename__ = "tickets"

    id = Column(Integer, primary_key=True, index=True)
    ticket_number = Column(String(20), unique=True, nullable=False)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    category = Column(Enum(TicketCategory), nullable=True)
    priority = Column(Enum(TicketPriority), default=TicketPriority.MEDIUM)
    status = Column(Enum(TicketStatus), default=TicketStatus.OPEN)

    # Reporter
    reported_by = Column(Integer, ForeignKey("users.id"), nullable=False)

    # Location & Asset
    location_id = Column(Integer, ForeignKey("locations.id"), nullable=True)
    asset_id = Column(Integer, ForeignKey("assets.id"), nullable=True)

    # Assignment
    assigned_department = Column(
        Integer, ForeignKey("departments.id"), nullable=True
    )
    assigned_to = Column(Integer, ForeignKey("users.id"), nullable=True)

    # AI fields
    ai_category = Column(Enum(TicketCategory), nullable=True)
    ai_category_confidence = Column(Float, nullable=True)
    ai_priority = Column(Enum(TicketPriority), nullable=True)
    ai_priority_confidence = Column(Float, nullable=True)
    ai_processed_at = Column(DateTime, nullable=True)

    # Duplicate detection
    is_duplicate = Column(Boolean, default=False)
    duplicate_of = Column(Integer, ForeignKey("tickets.id"), nullable=True)
    duplicate_similarity = Column(Float, nullable=True)

    # Image
    image_path = Column(String(500), nullable=True)

    # SLA
    due_at = Column(DateTime, nullable=True)
    escalation_level = Column(Integer, default=0)

    # Resolution
    resolution_notes = Column(Text, nullable=True)
    resolved_at = Column(DateTime, nullable=True)
    closed_at = Column(DateTime, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now()
    )

    # Relationships
    reporter = relationship("User", foreign_keys=[reported_by])
    assignee = relationship("User", foreign_keys=[assigned_to])
    department = relationship("Department")
    history = relationship("TicketHistory", back_populates="ticket")


class TicketHistory(Base):
    __tablename__ = "ticket_history"

    id = Column(Integer, primary_key=True, index=True)
    ticket_id = Column(
        Integer, ForeignKey("tickets.id", ondelete="CASCADE"), nullable=False
    )
    old_status = Column(Enum(TicketStatus), nullable=True)
    new_status = Column(Enum(TicketStatus), nullable=False)
    changed_by = Column(Integer, ForeignKey("users.id"), nullable=True)
    comment = Column(Text, nullable=True)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    ticket = relationship("Ticket", back_populates="history")
    user = relationship("User", foreign_keys=[changed_by])