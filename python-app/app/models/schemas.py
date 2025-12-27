"""Database models"""
from datetime import datetime
from pydantic import BaseModel, Field
from typing import Optional

class ItemBase(BaseModel):
    """Base item model"""
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = Field(None, max_length=1000)

class ItemCreate(ItemBase):
    """Item creation model"""
    pass

class ItemUpdate(BaseModel):
    """Item update model"""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = Field(None, max_length=1000)

class ItemDB(ItemBase):
    """Item database model"""
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class ItemResponse(ItemDB):
    """Item response model"""
    status: str = "active"

class UserBase(BaseModel):
    """Base user model"""
    email: str = Field(..., regex=r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
    username: str = Field(..., min_length=3, max_length=50)

class UserCreate(UserBase):
    """User creation model"""
    password: str = Field(..., min_length=8)

class UserResponse(UserBase):
    """User response model"""
    id: int
    created_at: datetime

    class Config:
        from_attributes = True
