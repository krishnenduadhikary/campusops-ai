from collections import Counter
from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.department import Department
from app.models.ticket import Ticket, TicketPriority, TicketStatus
from app.models.user import User, UserRole
from app.core.dependencies import get_supervisor_or_admin

router = APIRouter(prefix="/analytics", tags=["Analytics"])

FINISHED = {TicketStatus.RESOLVED, TicketStatus.CLOSED, TicketStatus.CANCELLED, TicketStatus.REJECTED}
DONE = {TicketStatus.RESOLVED, TicketStatus.CLOSED}
WAITING = {TicketStatus.OPEN, TicketStatus.AI_PROCESSED}


def naive_utc(dt):
    if dt is not None and dt.tzinfo is not None:
        return dt.astimezone(timezone.utc).replace(tzinfo=None)
    return dt


def is_breached(ticket, now):
    due = naive_utc(ticket.due_at)
    if due is None:
        return False
    if ticket.status in DONE:
        done_at = naive_utc(ticket.resolved_at)
        return bool(done_at and done_at > due)
    if ticket.status in FINISHED:
        return False
    return due < now


@router.get("/overview")
def overview(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_supervisor_or_admin)
):
    if current_user.role == UserRole.SUPERVISOR:
        tickets = (
            db.query(Ticket)
            .filter(Ticket.assigned_department == current_user.department_id)
            .all()
            if current_user.department_id
            else []
        )
    else:
        tickets = db.query(Ticket).all()

    now = datetime.utcnow()
    open_tickets = [t for t in tickets if t.status not in FINISHED]
    resolved = [t for t in tickets if t.status in DONE]

    # SLA compliance: share of resolved tickets finished before their due time
    measured = [t for t in resolved if t.due_at and t.resolved_at]
    on_time = sum(1 for t in measured if naive_utc(t.resolved_at) <= naive_utc(t.due_at))
    compliance = round(on_time * 100 / len(measured), 1) if measured else None

    # average time from creation to resolution
    hours = [
        (naive_utc(t.resolved_at) - naive_utc(t.created_at)).total_seconds() / 3600
        for t in resolved
        if t.resolved_at and t.created_at
    ]
    avg_hours = round(sum(hours) / len(hours), 1) if hours else None

    categories = Counter(t.category.value if t.category else "UNCATEGORIZED" for t in tickets)

    by_department = []
    if current_user.role == UserRole.ADMIN:
        names = {d.id: d.name for d in db.query(Department).all()}
        stats = {}
        for t in tickets:
            s = stats.setdefault(t.assigned_department, {"total": 0, "open": 0, "breaches": 0})
            s["total"] += 1
            if t.status not in FINISHED:
                s["open"] += 1
            if is_breached(t, now):
                s["breaches"] += 1
        by_department = sorted(
            [{"department": names.get(k, "Unassigned"), **v} for k, v in stats.items()],
            key=lambda row: row["total"],
            reverse=True,
        )

    return {
        "total": len(tickets),
        "open": len(open_tickets),
        "unassigned": sum(1 for t in tickets if t.status in WAITING),
        "resolved": len(resolved),
        "critical_active": sum(1 for t in open_tickets if t.priority == TicketPriority.CRITICAL),
        "sla_breaches": sum(1 for t in tickets if is_breached(t, now)),
        "sla_compliance": compliance,
        "avg_resolution_hours": avg_hours,
        "top_categories": [{"category": c, "count": n} for c, n in categories.most_common(5)],
        "by_department": by_department,
    }