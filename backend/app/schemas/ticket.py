from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from app.models.ticket import TicketStatus, TicketPriority, TicketCategory


# Create ticket request
class TicketCreate(BaseModel):
    title: str
    description: str
    category: Optional[TicketCategory] = None
    priority: Optional[TicketPriority] = TicketPriority.MEDIUM
    location_id: Optional[int] = None
    asset_id: Optional[int] = None


# Update ticket request
class TicketUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    category: Optional[TicketCategory] = None
    priority: Optional[TicketPriority] = None
    status: Optional[TicketStatus] = None
    resolution_notes: Optional[str] = None


# Assign ticket request
class TicketAssign(BaseModel):
    department_id: int
    technician_id: Optional[int] = None


# Resolve ticket request
class TicketResolve(BaseModel):
    resolution_notes: str


# Ticket response
class TicketResponse(BaseModel):
    id: int
    ticket_number: str
    title: str
    description: str
    category: Optional[TicketCategory] = None
    priority: TicketPriority
    status: TicketStatus
    reported_by: int
    location_id: Optional[int] = None
    asset_id: Optional[int] = None
    assigned_department: Optional[int] = None
    assigned_to: Optional[int] = None
    is_duplicate: bool
    duplicate_of: Optional[int] = None
    image_path: Optional[str] = None
    due_at: Optional[datetime] = None
    escalation_level: int
    resolution_notes: Optional[str] = None
    resolved_at: Optional[datetime] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Ticket list response
class TicketListResponse(BaseModel):
    total: int
    tickets: list[TicketResponse]