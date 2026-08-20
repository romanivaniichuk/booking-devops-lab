from datetime import datetime

from pydantic import field_validator
from sqlalchemy import Column, DateTime
from sqlmodel import Field, SQLModel


class BookingBase(SQLModel):
    name: str = Field(min_length=1, max_length=100)
    phone: str = Field(min_length=5, max_length=30)
    booking_time: datetime = Field(
        sa_column=Column(DateTime(timezone=True), nullable=False)
    )
    status: str = Field(default="new", max_length=20)

    @field_validator("booking_time")
    @classmethod
    def booking_time_must_have_timezone(cls, value: datetime) -> datetime:
        if value.tzinfo is None or value.utcoffset() is None:
            raise ValueError("booking_time must include a timezone offset")
        return value


class Booking(BookingBase, table=True):
    id: int | None = Field(default=None, primary_key=True)


class BookingCreate(BookingBase):
    pass


class BookingPublic(BookingBase):
    id: int
