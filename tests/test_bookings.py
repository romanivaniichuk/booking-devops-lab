from datetime import datetime

import pytest
from fastapi.testclient import TestClient

from app.db import get_session
from app.main import app


class FakeSession:
    def add(self, booking):
        self.booking = booking

    def commit(self):
        pass

    def refresh(self, booking):
        booking.id = 1


def override_get_session():
    yield FakeSession()


@pytest.fixture
def client():
    app.dependency_overrides[get_session] = override_get_session

    with TestClient(app) as test_client:
        yield test_client

    app.dependency_overrides.clear()


def test_create_booking(client):
    payload = {
        "name": "Test User",
        "phone": "+48111111111",
        "booking_time": "2026-08-20T19:00:00+02:00",
        "status": "new",
    }

    response = client.post("/bookings", json=payload)

    assert response.status_code == 201

    body = response.json()

    assert body["name"] == payload["name"]
    assert body["phone"] == payload["phone"]
    assert body["status"] == payload["status"]
    assert body["id"] == 1

    returned_time = datetime.fromisoformat(
        body["booking_time"].replace("Z", "+00:00")
    )
    sent_time = datetime.fromisoformat(payload["booking_time"])

    assert returned_time == sent_time


def test_reject_booking_without_timezone(client):
    payload = {
        "name": "Test User",
        "phone": "+48111111111",
        "booking_time": "2026-08-20T19:00:00",
        "status": "new",
    }

    response = client.post("/bookings", json=payload)

    assert response.status_code == 422
