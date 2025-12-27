"""API endpoints"""
from fastapi import APIRouter
from pydantic import BaseModel
from typing import List

router = APIRouter()

class Item(BaseModel):
    """Item model"""
    id: int
    name: str
    description: str | None = None

class ItemResponse(BaseModel):
    """Item response model"""
    id: int
    name: str
    description: str | None = None
    status: str

# Mock data store
items_db: dict[int, Item] = {
    1: Item(id=1, name="Item 1", description="First item"),
    2: Item(id=2, name="Item 2", description="Second item"),
}

@router.get("/items", response_model=List[ItemResponse])
async def list_items():
    """List all items"""
    return [
        ItemResponse(**item.dict(), status="active") 
        for item in items_db.values()
    ]

@router.get("/items/{item_id}", response_model=ItemResponse)
async def get_item(item_id: int):
    """Get item by ID"""
    if item_id not in items_db:
        return {"error": "Item not found"}, 404
    
    item = items_db[item_id]
    return ItemResponse(**item.dict(), status="active")

@router.post("/items", response_model=ItemResponse)
async def create_item(item: Item):
    """Create a new item"""
    new_id = max(items_db.keys()) + 1 if items_db else 1
    new_item = Item(id=new_id, **item.dict(exclude={"id"}))
    items_db[new_id] = new_item
    return ItemResponse(**new_item.dict(), status="active")
