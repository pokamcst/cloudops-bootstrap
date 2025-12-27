"""Tests for item service"""
import pytest
from app.services.item_service import ItemService
from app.models.schemas import ItemCreate, ItemUpdate

@pytest.fixture
def item_service():
    """Create a fresh item service for each test"""
    return ItemService()

def test_get_all_items(item_service):
    """Test getting all items"""
    items = item_service.get_all_items()
    assert len(items) == 2
    assert items[0].name == "Sample Item 1"
    assert items[1].name == "Sample Item 2"

def test_get_item(item_service):
    """Test getting a single item"""
    item = item_service.get_item(1)
    assert item is not None
    assert item.id == 1
    assert item.name == "Sample Item 1"

def test_get_nonexistent_item(item_service):
    """Test getting a nonexistent item"""
    item = item_service.get_item(999)
    assert item is None

def test_create_item(item_service):
    """Test creating a new item"""
    new_item = ItemCreate(
        name="New Item",
        description="New Description"
    )
    created = item_service.create_item(new_item)
    
    assert created.id == 3  # Should be next ID after samples
    assert created.name == "New Item"
    assert created.description == "New Description"
    
    # Verify it was actually added
    retrieved = item_service.get_item(3)
    assert retrieved is not None
    assert retrieved.name == "New Item"

def test_update_item(item_service):
    """Test updating an item"""
    update_data = ItemUpdate(
        name="Updated Item",
        description="Updated Description"
    )
    updated = item_service.update_item(1, update_data)
    
    assert updated is not None
    assert updated.name == "Updated Item"
    assert updated.description == "Updated Description"

def test_update_nonexistent_item(item_service):
    """Test updating a nonexistent item"""
    update_data = ItemUpdate(name="Updated")
    result = item_service.update_item(999, update_data)
    assert result is None

def test_partial_update_item(item_service):
    """Test partial update of item"""
    update_data = ItemUpdate(name="Only Name Changed")
    updated = item_service.update_item(1, update_data)
    
    assert updated.name == "Only Name Changed"
    # Description should remain unchanged
    assert updated.description == "This is a sample item"

def test_delete_item(item_service):
    """Test deleting an item"""
    result = item_service.delete_item(1)
    assert result is True
    
    # Verify it's deleted
    item = item_service.get_item(1)
    assert item is None

def test_delete_nonexistent_item(item_service):
    """Test deleting a nonexistent item"""
    result = item_service.delete_item(999)
    assert result is False
