"""Tests for health check endpoints"""
import sys
from pathlib import Path
from fastapi.testclient import TestClient

# Add parent directory to path so app module can be imported
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from app.main import app

def test_root_endpoint():
    """Test root endpoint returns app info"""
    client = TestClient(app)
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert data["message"] == "Welcome to Python Bootstrap App"

def test_health_endpoint():
    """Test health check endpoint"""
    client = TestClient(app)
    response = client.get("/api/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "UP"
    assert "message" in data
    assert "version" in data

def test_health_live_endpoint():
    """Test liveness probe endpoint"""
    client = TestClient(app)
    response = client.get("/api/health/live")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "UP"

def test_health_ready_endpoint():
    """Test readiness probe endpoint"""
    client = TestClient(app)
    response = client.get("/api/health/ready")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "UP"

def test_invalid_endpoint():
    """Test invalid endpoint returns 404"""
    client = TestClient(app)
    response = client.get("/api/invalid")
    assert response.status_code == 404
