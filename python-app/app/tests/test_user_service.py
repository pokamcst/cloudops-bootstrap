"""Tests for user service"""
import pytest
from app.services.user_service import UserService
from app.models.schemas import UserCreate

@pytest.fixture
def user_service():
    """Create a fresh user service for each test"""
    return UserService()

def test_create_user(user_service):
    """Test creating a new user"""
    new_user = UserCreate(
        email="newuser@example.com",
        username="newuser",
        password="securepassword123"
    )
    created = user_service.create_user(new_user)
    
    assert created.id == 1
    assert created.email == "newuser@example.com"
    assert created.username == "newuser"

def test_get_user(user_service):
    """Test getting a user"""
    new_user = UserCreate(
        email="test@example.com",
        username="testuser",
        password="password123"
    )
    created = user_service.create_user(new_user)
    
    retrieved = user_service.get_user(created.id)
    assert retrieved is not None
    assert retrieved.email == "test@example.com"
    assert retrieved.username == "testuser"

def test_get_nonexistent_user(user_service):
    """Test getting a nonexistent user"""
    user = user_service.get_user(999)
    assert user is None

def test_get_user_by_email(user_service):
    """Test getting user by email"""
    new_user = UserCreate(
        email="unique@example.com",
        username="uniqueuser",
        password="password123"
    )
    user_service.create_user(new_user)
    
    retrieved = user_service.get_user_by_email("unique@example.com")
    assert retrieved is not None
    assert retrieved.username == "uniqueuser"

def test_get_user_by_username(user_service):
    """Test getting user by username"""
    new_user = UserCreate(
        email="user@example.com",
        username="uniquename",
        password="password123"
    )
    user_service.create_user(new_user)
    
    retrieved = user_service.get_user_by_username("uniquename")
    assert retrieved is not None
    assert retrieved.email == "user@example.com"

def test_authenticate_user_success(user_service):
    """Test successful user authentication"""
    new_user = UserCreate(
        email="auth@example.com",
        username="authuser",
        password="correctpassword"
    )
    user_service.create_user(new_user)
    
    authenticated = user_service.authenticate_user("authuser", "correctpassword")
    assert authenticated is not None
    assert authenticated.username == "authuser"

def test_authenticate_user_wrong_password(user_service):
    """Test authentication with wrong password"""
    new_user = UserCreate(
        email="auth@example.com",
        username="authuser",
        password="correctpassword"
    )
    user_service.create_user(new_user)
    
    authenticated = user_service.authenticate_user("authuser", "wrongpassword")
    assert authenticated is None

def test_authenticate_nonexistent_user(user_service):
    """Test authentication of nonexistent user"""
    authenticated = user_service.authenticate_user("noexist", "password")
    assert authenticated is None

def test_delete_user(user_service):
    """Test deleting a user"""
    new_user = UserCreate(
        email="delete@example.com",
        username="deleteuser",
        password="password123"
    )
    created = user_service.create_user(new_user)
    
    result = user_service.delete_user(created.id)
    assert result is True
    
    # Verify deletion
    retrieved = user_service.get_user(created.id)
    assert retrieved is None

def test_delete_nonexistent_user(user_service):
    """Test deleting a nonexistent user"""
    result = user_service.delete_user(999)
    assert result is False

def test_get_all_users(user_service):
    """Test getting all users"""
    user1 = UserCreate(
        email="user1@example.com",
        username="user1",
        password="password123"
    )
    user2 = UserCreate(
        email="user2@example.com",
        username="user2",
        password="password123"
    )
    user_service.create_user(user1)
    user_service.create_user(user2)
    
    all_users = user_service.get_all_users()
    assert len(all_users) == 2
    assert all_users[0].username == "user1"
    assert all_users[1].username == "user2"
