from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.department import Department
from app.models.user import User
from app.core.dependencies import get_current_user

router = APIRouter(prefix="/departments", tags=["Departments"])


@router.get("/")
def list_departments(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    rows = (
        db.query(Department)
        .filter(Department.is_active.is_(True))
        .order_by(Department.name)
        .all()
    )
    return [
        {
            "id": d.id,
            "name": d.name,
            "sla_hours_low": d.sla_hours_low,
            "sla_hours_medium": d.sla_hours_medium,
            "sla_hours_high": d.sla_hours_high,
            "sla_hours_critical": d.sla_hours_critical,
        }
        for d in rows
    ]