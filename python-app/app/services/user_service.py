"""User service for authentication and user management"""
from datetime import datetime
from typing import Optional, List
from hashlib import sha256
from app.models.schemas import UserCreate, UserResponse

class UserService:
    """Service for user management"""
    
    def __init__(self):
        """Initialize with empty user database"""
        self.db: dict[int, dict] = {}
        self.next_id = 1

    def _hash_password(self, password: str) -> str:
        """Hash password using SHA256 (in production, use bcrypt or Argon2)"""
        return sha256(password.encode()).hexdigest()

    def get_all_users(self) -> List[UserResponse]:
        """Get all users"""
        return [
            UserResponse(
                id=user["id"],
                email=user["email"],
                username=user["username"],
                created_at=user["created_at"],
            )
            for user in self.db.values()
        ]

    def get_user(self, user_id: int) -> Optional[UserResponse]:
        """Get user by ID"""
        if user_id not in self.db:
            return None
        user = self.db[user_id]
        return UserResponse(
            id=user["id"],
            email=user["email"],
            username=user["username"],
            created_at=user["created_at"],
        )

    def get_user_by_email(self, email: str) -> Optional[UserResponse]:
        """Get user by email"""
        for user in self.db.values():
            if user["email"] == email:
                return UserResponse(
                    id=user["id"],
                    email=user["email"],
                    username=user["username"],
                    created_at=user["created_at"],
                )
        return None

    def get_user_by_username(self, username: str) -> Optional[UserResponse]:
        """Get user by username"""
        for user in self.db.values():
            if user["username"] == username:
                return UserResponse(
                    id=user["id"],
                    email=user["email"],
                    username=user["username"],
                    created_at=user["created_at"],
                )
        return None

    def create_user(self, user: UserCreate) -> UserResponse:
        """Create a new user"""
        now = datetime.now()
        user_data = {
            "id": self.next_id,
            "email": user.email,
            "username": user.username,
            "password_hash": self._hash_password(user.password),
            "created_at": now,
        }
        self.db[self.next_id] = user_data
        self.next_id += 1
        
        return UserResponse(
            id=user_data["id"],
            email=user_data["email"],
            username=user_data["username"],
            created_at=user_data["created_at"],
        )

    def authenticate_user(self, username: str, password: str) -> Optional[UserResponse]:
        """Authenticate user with username and password"""
        user = None
        for u in self.db.values():
            if u["username"] == username:
                user = u
                break
        
        if not user:
            return None
        
        if user["password_hash"] == self._hash_password(password):
            return UserResponse(
                id=user["id"],
                email=user["email"],
                username=user["username"],
                created_at=user["created_at"],
            )
        
        return None

    def delete_user(self, user_id: int) -> bool:
        """Delete a user"""
        if user_id not in self.db:
            return False
        del self.db[user_id]
        return True

# Global service instance
user_service = UserService()
