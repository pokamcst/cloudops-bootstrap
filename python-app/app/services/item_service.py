"""Item service for business logic"""
from datetime import datetime
from typing import Optional, List
from app.models.schemas import ItemCreate, ItemUpdate, ItemDB

class ItemService:
    """Service for item management"""
    
    def __init__(self):
        """Initialize with empty database"""
        self.db: dict[int, dict] = {
            1: {
                "id": 1,
                "name": "Sample Item 1",
                "description": "This is a sample item",
                "created_at": datetime.now(),
                "updated_at": datetime.now(),
            },
            2: {
                "id": 2,
                "name": "Sample Item 2",
                "description": "Another sample item",
                "created_at": datetime.now(),
                "updated_at": datetime.now(),
            },
        }
        self.next_id = max(self.db.keys()) + 1 if self.db else 1

    def get_all_items(self) -> List[ItemDB]:
        """Get all items"""
        return [ItemDB(**item) for item in self.db.values()]

    def get_item(self, item_id: int) -> Optional[ItemDB]:
        """Get item by ID"""
        if item_id not in self.db:
            return None
        return ItemDB(**self.db[item_id])

    def create_item(self, item: ItemCreate) -> ItemDB:
        """Create a new item"""
        now = datetime.now()
        item_data = {
            "id": self.next_id,
            "name": item.name,
            "description": item.description,
            "created_at": now,
            "updated_at": now,
        }
        self.db[self.next_id] = item_data
        self.next_id += 1
        return ItemDB(**item_data)

    def update_item(self, item_id: int, item: ItemUpdate) -> Optional[ItemDB]:
        """Update an existing item"""
        if item_id not in self.db:
            return None
        
        now = datetime.now()
        existing = self.db[item_id]
        
        if item.name is not None:
            existing["name"] = item.name
        if item.description is not None:
            existing["description"] = item.description
        
        existing["updated_at"] = now
        return ItemDB(**existing)

    def delete_item(self, item_id: int) -> bool:
        """Delete an item"""
        if item_id not in self.db:
            return False
        del self.db[item_id]
        return True

# Global service instance
item_service = ItemService()
