"""Test configuration and fixtures"""
import pytest
from fastapi.testclient import TestClient
from app.main import app

@pytest.fixture
def client():
    """Create a test client"""
    return TestClient(app)

@pytest.fixture
def sample_item():
    """Create a sample item for testing"""
    return {
        "name": "Test Item",
        "description": "Test Description"
    }

@pytest.fixture
def sample_user():
    """Create a sample user for testing"""
    return {
        "email": "test@example.com",
        "username": "testuser",
        "password": "testpassword123"
    }
