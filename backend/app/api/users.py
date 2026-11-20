from typing import Optional

from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.user import User, UserRole
from app.models.ticket import Ticket, TicketStatus
from app.core.dependencies import get_supervisor_or_admin

router = APIRouter(prefix="/users", tags=["Users"])

ACTIVE_STATUSES = [
    TicketStatus.ASSIGNED,
    TicketStatus.ACCEPTED,
    TicketStatus.IN_PROGRESS,
    TicketStatus.ESCALATED,
]


@router.get("/technicians")
def list_technicians(
    department_id: Optional[int] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_supervisor_or_admin)
):
    query = db.query(User).filter(
        User.role == UserRole.TECHNICIAN,
        User.is_active.is_(True),
    )
    if department_id is not None:
        query = query.filter(User.department_id == department_id)
    technicians = query.order_by(User.name).all()

    counts = {}
    ids = [t.id for t in technicians]
    if ids:
        rows = (
            db.query(Ticket.assigned_to, func.count(Ticket.id))
            .filter(Ticket.assigned_to.in_(ids), Ticket.status.in_(ACTIVE_STATUSES))
            .group_by(Ticket.assigned_to)
            .all()
        )
        counts = {user_id: n for user_id, n in rows}

    return [
        {
            "id": t.id,
            "name": t.name,
            "department_id": t.department_id,
            "active_tickets": counts.get(t.id, 0),
        }
        for t in technicians
    ]