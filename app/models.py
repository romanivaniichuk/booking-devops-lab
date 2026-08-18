from datetime import datetime

from sqlalchemy import Column, DateTime
from sqlmodel import Field, SQLModel


class BookingBase(SQLModel):
    name: str = Field(min_length=1, max_length=100)
    phone: str = Field(min_length=5, max_length=30)
    booking_time: datetime = Field(
    sa_column=Column(DateTime(timezone=True), nullable=False))
    status: str = Field(default="new", max_length=20)


class Booking(BookingBase, table=True):
    id: int | None = Field(default=None, primary_key=True)


class BookingCreate(BookingBase):
    pass


class BookingPublic(BookingBase):
    id: int
