from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.models.location import Location
from app.models.user import User
from app.core.dependencies import get_current_user

router = APIRouter(prefix="/locations", tags=["Locations"])


@router.get("/")
def list_locations(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    locations = db.query(Location).order_by(Location.building, Location.room).all()
    return [
        {
            "id": loc.id,
            "building": loc.building,
            "floor": loc.floor,
            "room": loc.room,
            "location_type": loc.location_type.value if loc.location_type else None,
        }
        for loc in locations
    ]