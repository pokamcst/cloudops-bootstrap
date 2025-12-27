# Customer Customization Guide

This guide helps new customers customize the CloudOps Bootstrap templates for their specific use cases.

## Overview

The CloudOps Bootstrap provides production-ready templates that you can easily customize. Both Java and Python applications follow a modular architecture that makes customization straightforward.

## Getting Started - Choose Your Path

### Path 1: Java Application (Spring Boot)
- **Use if**: You prefer Java, need mature ecosystem, or have Java expertise
- **Framework**: Spring Boot 3.2
- **Build Tool**: Maven
- **Testing**: JUnit 5
- **Documentation**: `java-app/README.md`

### Path 2: Python Application (FastAPI)
- **Use if**: You prefer Python, want modern async support, or need rapid development
- **Framework**: FastAPI
- **Build Tool**: pip/setuptools
- **Testing**: pytest
- **Documentation**: `python-app/README.md`

## Java Application Customization

### Step 1: Project Setup
```bash
cd java-app

# Change the package name
# Search and replace: com.kustomer → com.yourcompany.yourapp

# Update pom.xml
# - groupId: change to your organization
# - artifactId: change to your application name
# - version: update to your versioning scheme
# - project.name: update to your application name
```

### Step 2: Create Your Models
Add domain models to `src/main/java/com/kustomer/model/`:

```java
// Example: CustomerModel.java
package com.kustomer.model;

public class Customer {
    private Long id;
    private String name;
    private String email;
    
    // Getters, setters, constructors
}
```

### Step 3: Create Your Services
Add business logic to `src/main/java/com/kustomer/service/`:

```java
// Example: CustomerService.java
package com.kustomer.service;

import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class CustomerService {
    // Add your business logic
    
    public List<Customer> getAllCustomers() {
        // Implementation
    }
    
    public Customer createCustomer(Customer customer) {
        // Implementation
    }
}
```

### Step 4: Create Your Controllers
Add REST endpoints to `src/main/java/com/kustomer/controller/`:

```java
// Example: CustomerController.java
package com.kustomer.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/customers")
public class CustomerController {
    
    @Autowired
    private CustomerService customerService;
    
    @GetMapping
    public ResponseEntity<?> listCustomers() {
        return ResponseEntity.ok(customerService.getAllCustomers());
    }
    
    @PostMapping
    public ResponseEntity<?> createCustomer(@RequestBody Customer customer) {
        return ResponseEntity.ok(customerService.createCustomer(customer));
    }
}
```

### Step 5: Add Tests
Add test cases to `src/test/java/com/kustomer/`:

```java
// Example: CustomerControllerTest.java
package com.kustomer.controller;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
public class CustomerControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Test
    public void testGetCustomers() throws Exception {
        mockMvc.perform(get("/api/customers"))
            .andExpect(status().isOk());
    }
}
```

### Step 6: Update Configuration
Modify `src/main/resources/application.properties`:

```properties
# Application name
spring.application.name=your-app-name

# Server configuration
server.port=8080
server.servlet.context-path=/

# Database configuration (if using database)
spring.datasource.url=jdbc:postgresql://localhost:5432/yourdb
spring.datasource.username=user
spring.datasource.password=password
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQL10Dialect

# Logging
logging.level.root=INFO
logging.level.com.kustomer=DEBUG
```

### Step 7: Build and Test
```bash
# Build the application
mvn clean package

# Run tests
mvn test

# Run the application
java -jar target/your-app-name-1.0.0.jar

# Or run with Maven
mvn spring-boot:run
```

## Python Application Customization

### Step 1: Project Setup
```bash
cd python-app

# Create virtual environment
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows

# Install dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

### Step 2: Create Your Models
Extend `app/models/schemas.py`:

```python
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class CustomerBase(BaseModel):
    """Base customer model"""
    name: str = Field(..., min_length=1, max_length=255)
    email: str = Field(..., regex=r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
    phone: Optional[str] = None

class CustomerCreate(CustomerBase):
    """Create customer request"""
    pass

class CustomerDB(CustomerBase):
    """Customer database model"""
    id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class CustomerResponse(CustomerDB):
    """Customer API response"""
    status: str = "active"
```

### Step 3: Create Your Services
Add new service in `app/services/customer_service.py`:

```python
from datetime import datetime
from typing import Optional, List
from app.models.schemas import CustomerCreate, CustomerDB

class CustomerService:
    """Service for customer management"""
    
    def __init__(self):
        self.db: dict[int, dict] = {}
        self.next_id = 1
    
    def get_all_customers(self) -> List[CustomerDB]:
        """Get all customers"""
        return [CustomerDB(**customer) for customer in self.db.values()]
    
    def get_customer(self, customer_id: int) -> Optional[CustomerDB]:
        """Get customer by ID"""
        if customer_id not in self.db:
            return None
        return CustomerDB(**self.db[customer_id])
    
    def create_customer(self, customer: CustomerCreate) -> CustomerDB:
        """Create a new customer"""
        now = datetime.now()
        customer_data = {
            "id": self.next_id,
            "name": customer.name,
            "email": customer.email,
            "phone": customer.phone,
            "created_at": now,
            "updated_at": now,
        }
        self.db[self.next_id] = customer_data
        self.next_id += 1
        return CustomerDB(**customer_data)
    
    def delete_customer(self, customer_id: int) -> bool:
        """Delete a customer"""
        if customer_id not in self.db:
            return False
        del self.db[customer_id]
        return True

# Global service instance
customer_service = CustomerService()
```

### Step 4: Create Your Routes
Add new route in `app/routes/customers.py`:

```python
from fastapi import APIRouter, HTTPException
from app.models.schemas import CustomerCreate, CustomerResponse
from app.services.customer_service import customer_service

router = APIRouter()

@router.get("/customers", response_model=list[CustomerResponse])
async def list_customers():
    """List all customers"""
    return customer_service.get_all_customers()

@router.get("/customers/{customer_id}", response_model=CustomerResponse)
async def get_customer(customer_id: int):
    """Get customer by ID"""
    customer = customer_service.get_customer(customer_id)
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")
    return CustomerResponse(**customer.dict(), status="active")

@router.post("/customers", response_model=CustomerResponse)
async def create_customer(customer: CustomerCreate):
    """Create a new customer"""
    created = customer_service.create_customer(customer)
    return CustomerResponse(**created.dict(), status="active")

@router.delete("/customers/{customer_id}")
async def delete_customer(customer_id: int):
    """Delete a customer"""
    if not customer_service.delete_customer(customer_id):
        raise HTTPException(status_code=404, detail="Customer not found")
    return {"message": "Customer deleted"}
```

### Step 5: Register Your Routes
Update `app/main.py`:

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.routes import health, api, customers  # Add this import

# ... existing code ...

# Include routers
app.include_router(health.router, prefix="/api", tags=["health"])
app.include_router(api.router, prefix="/api", tags=["api"])
app.include_router(customers.router, prefix="/api", tags=["customers"])  # Add this line

# ... rest of code ...
```

### Step 6: Add Tests
Create `app/tests/test_customer_service.py`:

```python
import pytest
from app.services.customer_service import CustomerService
from app.models.schemas import CustomerCreate

@pytest.fixture
def customer_service():
    """Create a fresh service for each test"""
    return CustomerService()

def test_create_customer(customer_service):
    """Test creating a customer"""
    new_customer = CustomerCreate(
        name="John Doe",
        email="john@example.com",
        phone="555-1234"
    )
    created = customer_service.create_customer(new_customer)
    assert created.id == 1
    assert created.name == "John Doe"
    assert created.email == "john@example.com"

def test_get_customer(customer_service):
    """Test getting a customer"""
    new_customer = CustomerCreate(
        name="Jane Doe",
        email="jane@example.com"
    )
    created = customer_service.create_customer(new_customer)
    retrieved = customer_service.get_customer(created.id)
    assert retrieved is not None
    assert retrieved.name == "Jane Doe"

def test_delete_customer(customer_service):
    """Test deleting a customer"""
    new_customer = CustomerCreate(
        name="Delete Me",
        email="delete@example.com"
    )
    created = customer_service.create_customer(new_customer)
    result = customer_service.delete_customer(created.id)
    assert result is True
    assert customer_service.get_customer(created.id) is None
```

### Step 7: Update Configuration
Edit `.env`:

```env
APP_NAME=Your Custom App
DEBUG=False
ENVIRONMENT=development
HOST=0.0.0.0
PORT=8000
CORS_ORIGINS=["http://localhost:3000","http://localhost:8080"]
```

### Step 8: Run and Test
```bash
# Run the application
uvicorn app.main:app --reload

# Run tests
pytest

# Run tests with coverage
pytest --cov=app --cov-report=html

# Check code quality
black app/ --check
flake8 app/
mypy app/
```

## Common Customization Tasks

### Adding Database Support

**Python + SQLAlchemy**:
```bash
pip install sqlalchemy psycopg2-binary
```

**Java + JPA/Hibernate**:
```xml
<!-- In pom.xml -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
</dependency>
```

### Adding Authentication

**Python + JWT**:
```bash
pip install python-jose passlib bcrypt
```

**Java + Spring Security**:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
```

### Adding Logging

**Python**: Already configured in `app/config.py`

**Java**: Already configured in `application.properties`

### Adding Caching

**Python + Redis**:
```bash
pip install redis
```

**Java + Caffeine**:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-cache</artifactId>
</dependency>
```

## Updating Dependencies

### Python
```bash
# Update requirements
pip install --upgrade -r requirements.txt

# Freeze new versions
pip freeze > requirements.txt
```

### Java
```bash
# Update Maven dependencies
mvn clean install

# Check for dependency updates
mvn versions:display-dependency-updates
```

## Deployment to Azure

### Prerequisites
1. Azure subscription
2. Container Registry (Azure ACR)
3. App Service plan
4. GitHub repository with secrets configured

### Steps
1. Update `Dockerfile` if needed
2. Push to GitHub (triggers CI/CD)
3. Verify in GitHub Actions
4. Check deployment in Azure portal

## Testing Your Changes

### Java
```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=CustomerControllerTest

# Run with coverage
mvn test jacoco:report
```

### Python
```bash
# Run all tests
pytest

# Run specific test file
pytest app/tests/test_customer_service.py

# Run with coverage
pytest --cov=app --cov-report=html
```

## Troubleshooting

### Issue: Import errors after adding new modules

**Solution**: Ensure `__init__.py` exists in all package directories

### Issue: Tests failing locally but passing in CI/CD

**Solution**: Ensure Python/Java versions match, dependencies are installed, and environment variables are set

### Issue: Docker build failing

**Solution**: Check `.dockerignore`, verify dependencies are in `requirements.txt` or `pom.xml`

## Next Steps

1. ✅ Customize models and services for your domain
2. ✅ Add your business logic
3. ✅ Write tests for your code
4. ✅ Update API documentation
5. ✅ Configure Azure resources in `IaC/`
6. ✅ Deploy using GitHub Actions
7. ✅ Monitor with Application Insights

## Support

Refer to the comprehensive READMEs in each application directory:
- **Java**: `java-app/README.md`
- **Python**: `python-app/README.md`
- **Infrastructure**: `IaC/README.md`

---

**Remember**: These templates are designed to accelerate your development. Follow the patterns established, and your custom application will be production-ready quickly!
