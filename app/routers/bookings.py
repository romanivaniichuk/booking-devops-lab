from datetime import timezone

from fastapi import APIRouter, Depends, status
from sqlmodel import Session, select

from app.db import get_session
from app.models import Booking, BookingCreate, BookingPublic


router = APIRouter(prefix="/bookings", tags=["bookings"])


@router.post("", response_model=BookingPublic, status_code=status.HTTP_201_CREATED)
def create_booking(
    booking_data: BookingCreate,
    session: Session = Depends(get_session),
):
    data = booking_data.model_dump()
    data["booking_time"] = booking_data.booking_time.astimezone(timezone.utc)

    booking = Booking(**data)

    session.add(booking)
    session.commit()
    session.refresh(booking)

    return booking


@router.get("", response_model=list[BookingPublic])
def get_bookings(session: Session = Depends(get_session)):
    return session.exec(select(Booking)).all()








