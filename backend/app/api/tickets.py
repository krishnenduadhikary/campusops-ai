from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional
from datetime import datetime, timedelta
from app.db.database import get_db
from app.models.ticket import Ticket, TicketHistory, TicketStatus, TicketPriority
from app.models.user import User, UserRole
from app.models.department import Department
from app.schemas.ticket import (
    TicketCreate, TicketUpdate, TicketAssign,
    TicketResolve, TicketResponse, TicketListResponse
)
from app.core.dependencies import get_current_user, get_technician_or_above

router = APIRouter(prefix="/tickets", tags=["Tickets"])


def generate_ticket_number(db: Session) -> str:
    count = db.query(Ticket).count()
    return f"TKT-{str(count + 1).zfill(4)}"


def calculate_due_date(priority: TicketPriority, department_id: int, db: Session) -> datetime:
    dept = db.query(Department).filter(Department.id == department_id).first()
    if not dept:
        hours = 24
    else:
        hours_map = {
            TicketPriority.LOW: dept.sla_hours_low,
            TicketPriority.MEDIUM: dept.sla_hours_medium,
            TicketPriority.HIGH: dept.sla_hours_high,
            TicketPriority.CRITICAL: dept.sla_hours_critical,
        }
        hours = hours_map.get(priority, 24)
    return datetime.utcnow() + timedelta(hours=hours)


def add_history(
    db: Session,
    ticket_id: int,
    old_status: TicketStatus,
    new_status: TicketStatus,
    changed_by: int,
    comment: str = None
):
    history = TicketHistory(
        ticket_id=ticket_id,
        old_status=old_status,
        new_status=new_status,
        changed_by=changed_by,
        comment=comment
    )
    db.add(history)


# ─── CREATE ───────────────────────────────────────
@router.post("/", response_model=TicketResponse,
             status_code=status.HTTP_201_CREATED)
def create_ticket(
    ticket_data: TicketCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    ticket_number = generate_ticket_number(db)

    new_ticket = Ticket(
        ticket_number=ticket_number,
        title=ticket_data.title,
        description=ticket_data.description,
        category=ticket_data.category,
        priority=ticket_data.priority,
        status=TicketStatus.OPEN,
        reported_by=current_user.id,
        location_id=ticket_data.location_id,
        asset_id=ticket_data.asset_id,
    )
    db.add(new_ticket)
    db.commit()
    db.refresh(new_ticket)

    add_history(
        db, new_ticket.id, None,
        TicketStatus.OPEN, current_user.id,
        "Ticket created"
    )
    db.commit()
    return new_ticket


# ─── LIST ─────────────────────────────────────────
@router.get("/", response_model=TicketListResponse)
def list_tickets(
    status: Optional[TicketStatus] = None,
    priority: Optional[TicketPriority] = None,
    category: Optional[str] = None,
    skip: int = Query(default=0, ge=0),
    limit: int = Query(default=20, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    query = db.query(Ticket)

    # Role-based filtering
    if current_user.role == UserRole.STUDENT:
        query = query.filter(Ticket.reported_by == current_user.id)
    elif current_user.role == UserRole.TECHNICIAN:
        query = query.filter(Ticket.assigned_to == current_user.id)
    elif current_user.role == UserRole.SUPERVISOR:
        query = query.filter(
            Ticket.assigned_department == current_user.department_id
        )
    # ADMIN sees all

    if status:
        query = query.filter(Ticket.status == status)
    if priority:
        query = query.filter(Ticket.priority == priority)

    total = query.count()
    tickets = query.order_by(
        Ticket.created_at.desc()
    ).offset(skip).limit(limit).all()

    return {"total": total, "tickets": tickets}


# ─── GET ONE ──────────────────────────────────────
@router.get("/{ticket_id}", response_model=TicketResponse)
def get_ticket(
    ticket_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    ticket = db.query(Ticket).filter(Ticket.id == ticket_id).first()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")

    # Students can only see their own tickets
    if current_user.role == UserRole.STUDENT:
        if ticket.reported_by != current_user.id:
            raise HTTPException(status_code=403, detail="Access denied")

    return ticket


# ─── UPDATE ───────────────────────────────────────
@router.patch("/{ticket_id}", response_model=TicketResponse)
def update_ticket(
    ticket_id: int,
    update_data: TicketUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    ticket = db.query(Ticket).filter(Ticket.id == ticket_id).first()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")

    for field, value in update_data.model_dump(exclude_unset=True).items():
        setattr(ticket, field, value)

    db.commit()
    db.refresh(ticket)
    return ticket


# ─── ASSIGN ───────────────────────────────────────
@router.post("/{ticket_id}/assign", response_model=TicketResponse)
def assign_ticket(
    ticket_id: int,
    assign_data: TicketAssign,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_technician_or_above)
):
    ticket = db.query(Ticket).filter(Ticket.id == ticket_id).first()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")

    old_status = ticket.status
    ticket.assigned_department = assign_data.department_id
    ticket.assigned_to = assign_data.technician_id
    ticket.status = TicketStatus.ASSIGNED

    if assign_data.department_id:
        ticket.due_at = calculate_due_date(
            ticket.priority, assign_data.department_id, db
        )

    add_history(
        db, ticket.id, old_status,
        TicketStatus.ASSIGNED, current_user.id,
        f"Assigned to department {assign_data.department_id}"
    )
    db.commit()
    db.refresh(ticket)
    return ticket


# ─── ACCEPT ───────────────────────────────────────
@router.post("/{ticket_id}/accept", response_model=TicketResponse)
def accept_ticket(
    ticket_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_technician_or_above)
):
    ticket = db.query(Ticket).filter(Ticket.id == ticket_id).first()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")

    if ticket.status != TicketStatus.ASSIGNED:
        raise HTTPException(
            status_code=400,
            detail=f"Cannot accept ticket with status: {ticket.status}"
        )

    old_status = ticket.status
    ticket.status = TicketStatus.ACCEPTED
    ticket.assigned_to = current_user.id

    add_history(
        db, ticket.id, old_status,
        TicketStatus.ACCEPTED, current_user.id,
        "Ticket accepted by technician"
    )
    db.commit()
    db.refresh(ticket)
    return ticket


# ─── START ────────────────────────────────────────
@router.post("/{ticket_id}/start", response_model=TicketResponse)
def start_ticket(
    ticket_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_technician_or_above)
):
    ticket = db.query(Ticket).filter(Ticket.id == ticket_id).first()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")

    if ticket.status != TicketStatus.ACCEPTED:
        raise HTTPException(
            status_code=400,
            detail=f"Cannot start ticket with status: {ticket.status}"
        )

    old_status = ticket.status
    ticket.status = TicketStatus.IN_PROGRESS

    add_history(
        db, ticket.id, old_status,
        TicketStatus.IN_PROGRESS, current_user.id,
        "Work started"
    )
    db.commit()
    db.refresh(ticket)
    return ticket


# ─── RESOLVE ──────────────────────────────────────
@router.post("/{ticket_id}/resolve", response_model=TicketResponse)
def resolve_ticket(
    ticket_id: int,
    resolve_data: TicketResolve,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_technician_or_above)
):
    ticket = db.query(Ticket).filter(Ticket.id == ticket_id).first()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")

    if ticket.status not in [TicketStatus.IN_PROGRESS, TicketStatus.ACCEPTED]:
        raise HTTPException(
            status_code=400,
            detail=f"Cannot resolve ticket with status: {ticket.status}"
        )

    old_status = ticket.status
    ticket.status = TicketStatus.RESOLVED
    ticket.resolution_notes = resolve_data.resolution_notes
    ticket.resolved_at = datetime.utcnow()

    add_history(
        db, ticket.id, old_status,
        TicketStatus.RESOLVED, current_user.id,
        f"Resolved: {resolve_data.resolution_notes}"
    )
    db.commit()
    db.refresh(ticket)
    return ticket


# ─── DELETE ───────────────────────────────────────
@router.delete("/{ticket_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_ticket(
    ticket_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    ticket = db.query(Ticket).filter(Ticket.id == ticket_id).first()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")

    if current_user.role not in [UserRole.ADMIN, UserRole.SUPERVISOR]:
        raise HTTPException(status_code=403, detail="Access denied")

    db.delete(ticket)
    db.commit()