# CloudOps Bootstrap

A comprehensive infrastructure-as-code solution with application templates for deploying and managing cloud operations on Azure. This bootstrap package enables rapid customer onboarding by providing production-ready infrastructure modules and customizable application templates.

## Overview

This project provides a complete cloud operations platform with three integrated layers:

### Infrastructure Layer
- **Kubernetes Cluster (AKS)**: Managed Kubernetes cluster with node pools
- **Container Registry (ACR)**: Private container registry for application images
- **Key Vault**: Secure secrets management
- **Storage Account**: Blob storage for application data
- **Monitoring**: Application Insights and Log Analytics
- **Networking**: Virtual Network with subnets and network security
- **Identity**: Managed identities and role assignments

### Application Layer - Bootstrap Templates
- **Java Application**: Spring Boot 3.2 microservice with Maven and JUnit 5
- **Python Application**: FastAPI microservice with Pydantic validation and pytest

### CI/CD Pipeline
- Automated testing and containerization
- Multi-stage Docker builds
- Azure App Service deployment
- Health check validation and auto-rollback

## Infrastructure Components

### Core Infrastructure
- **Resource Group**: Environment-specific resource group
- **Virtual Network**: Network infrastructure with subnets
- **Network Security Groups**: Security rules for network access
- **Private Endpoints**: Secure access to Azure services

### Kubernetes Infrastructure
- **AKS Cluster**: Managed Kubernetes cluster
- **Node Pools**: System and user node pools
- **Container Registry**: Private container registry
- **Managed Identity**: AKS cluster identity

### Security Infrastructure
- **Key Vault**: Secrets management
- **Storage Account**: Blob storage
- **Network Security**: NSGs and private endpoints
- **RBAC**: Role-based access control

### Monitoring Infrastructure
- **Application Insights**: Application monitoring
- **Log Analytics**: Log management
- **Action Groups**: Alert notifications
- **Alert Rules**: Performance and availability monitoring

## Prerequisites

- Azure CLI
- Terraform 1.5.0 or later
- kubectl
- GitHub Actions (for CI/CD)

## Environment Variables

Required environment variables:
```bash
ARM_CLIENT_ID=your_client_id
ARM_CLIENT_SECRET=your_client_secret
ARM_SUBSCRIPTION_ID=your_subscription_id
ARM_TENANT_ID=your_tenant_id
TF_VAR_environment=test|staging|prod
```

## Project Structure

```
cloudops-bootstrap/
├── IaC/                             # Infrastructure as Code (consolidated)
│   ├── main.tf                      # Primary Terraform configuration
│   ├── providers.tf                 # Provider configuration
│   ├── variables.tf                 # Input variables
│   ├── outputs.tf                   # Output values
│   ├── resource_group.tf            # Resource group setup
│   ├── terraform.tfvars             # Variable values
│   ├── terraform.tfvars.example     # Variable template
│   ├── locals.tf                    # Local values
│   ├── README.md                    # IaC documentation
│   ├── tests/                       # Terraform compliance tests
│   │   └── terraform-compliance/
│   │       └── security.feature
│   └── modules/                     # Reusable Terraform modules
│       ├── acr/                     # Azure Container Registry
│       ├── aks/                     # Azure Kubernetes Service
│       ├── databases/               # Cosmos DB & PostgreSQL
│       ├── front_door/              # Azure Front Door
│       ├── monitoring/              # App Insights & Monitoring
│       ├── networking/              # VNet & Subnets
│       ├── security/                # Key Vault & RBAC
│       └── storage/                 # Storage Account
│
├── java-app/                        # Java Bootstrap Application
│   ├── src/
│   │   ├── main/java/com/kustomer/
│   │   │   ├── KustomerApplication.java
│   │   │   └── controller/
│   │   │       └── HealthController.java
│   │   ├── test/java/com/kustomer/
│   │   │   ├── KustomerApplicationTests.java
│   │   │   └── controller/
│   │   │       └── HealthControllerTest.java
│   │   └── resources/
│   │       └── application.properties
│   ├── pom.xml                      # Maven build configuration
│   ├── Dockerfile                   # Multi-stage Docker build
│   ├── .dockerignore                # Docker build exclusions
│   ├── .gitignore                   # Git exclusions
│   ├── README.md                    # Java app documentation (280+ lines)
│   └── .env.example                 # Environment configuration template
│
├── python-app/                      # Python Bootstrap Application
│   ├── app/
│   │   ├── __init__.py              # Package initialization
│   │   ├── main.py                  # FastAPI application setup
│   │   ├── config.py                # Pydantic configuration
│   │   ├── models/
│   │   │   ├── __init__.py
│   │   │   └── schemas.py           # Pydantic data models
│   │   ├── services/
│   │   │   ├── __init__.py
│   │   │   ├── item_service.py      # Item business logic
│   │   │   └── user_service.py      # User management
│   │   ├── routes/
│   │   │   ├── __init__.py
│   │   │   ├── health.py            # Health check endpoints
│   │   │   └── api.py               # Item management endpoints
│   │   └── tests/
│   │       ├── conftest.py          # pytest fixtures
│   │       ├── test_health.py       # Health endpoint tests
│   │       ├── test_item_service.py # Item service tests
│   │       └── test_user_service.py # User service tests
│   ├── Dockerfile                   # Multi-stage Docker build
│   ├── .dockerignore                # Docker build exclusions
│   ├── .gitignore                   # Git exclusions
│   ├── pyproject.toml               # Modern Python packaging
│   ├── requirements.txt             # Runtime dependencies
│   ├── requirements-dev.txt         # Development dependencies
│   ├── README.md                    # Python app documentation (400+ lines)
│   └── .env.example                 # Environment configuration template
│
├── .github/
│   └── workflows/
│       ├── azure_infra_depl.yml     # Infrastructure validation & deployment
│       ├── terraform-deploy.yml     # Terraform deployment
│       ├── java-apps-deploy.yml     # Java app CI/CD pipeline
│       └── python-apps-deploy.yml   # Python app CI/CD pipeline
│
├── Dockerfile                       # Root Docker configuration
├── build_custom_image.sh            # Custom image build script
├── PoC.md                          # Proof of concept documentation
├── CONSOLIDATION_SUMMARY.md        # Infrastructure consolidation notes
└── README.md                       # This file
```

## Deployment Workflows

### Infrastructure Deployment

**azure_infra_depl.yml** - Infrastructure Validation & Deployment
- **Triggers**: Changes to `IaC/**/*.tf` files
- **Branches**: `main`, `develop`, `feature/*`
- **Actions**:
  - Terraform init, validate, plan
  - Plan artifacts uploaded for review
  - Auto-apply on main/develop branches
  - Security scanning with Checkov (optional)

**terraform-deploy.yml** - Advanced Terraform Deployment
- **Triggers**: Changes to `IaC/**/*.tf` files  
- **Branches**: `main`, `develop`
- **Actions**:
  - Format check
  - Validation and compliance scanning
  - Environment-specific plan and apply
  - Detailed deployment output and logging

### Java Application Deployment

**java-apps-deploy.yml** - Java App CI/CD Pipeline
- **Triggers**: Changes to `java-app/**` or `Dockerfile` modifications
- **Branches**: `main`, `develop`
- **Pipeline Stages**:
  
  1. **Build & Test**
     - Setup JDK 17 with Temurin
     - Build with Maven
     - Run JUnit 5 unit tests
     - Generate JaCoCo coverage reports
     - Upload test results and JAR artifacts
  
  2. **Build Docker Image**
     - Download compiled JAR from artifacts
     - Login to Azure Container Registry
     - Multi-stage Docker build (builder + runtime)
     - Push image with SHA and environment tags
     - Layer caching for improved performance
  
  3. **Deploy**
     - Deploy to Azure App Service for Containers
     - Health check validation (/api/health)
     - Auto-rollback on deployment failure
     - Verify application startup and readiness

### Python Application Deployment

**python-apps-deploy.yml** - Python App CI/CD Pipeline
- **Triggers**: Changes to `python-app/**` or `Dockerfile` modifications
- **Branches**: `main`, `develop`
- **Pipeline Stages**:
  
  1. **Build & Test**
     - Setup Python 3.10 environment
     - Install dependencies from requirements.txt
     - Run pytest test suite
     - Generate coverage reports
     - Lint with flake8 and format checks
     - Upload test artifacts
  
  2. **Build Docker Image**
     - Download test artifacts
     - Login to Azure Container Registry
     - Multi-stage Docker build (builder + runtime)
     - Push image with SHA and environment tags
     - Optimize layer caching
  
  3. **Deploy**
     - Deploy to Azure App Service for Containers
     - Health check validation (/api/health)
     - Auto-rollback on deployment failure
     - Verify application startup and readiness

## Bootstrap Templates - Quick Start Guide

This project is designed as a **reusable bootstrap package** for new customers. When implementing cloud operations for a new customer, follow these steps:

### For New Customers

#### 1. Infrastructure Setup
- Use the `/IaC` folder as the authoritative infrastructure
- Customize `terraform.tfvars` with your environment values
- Run Terraform to deploy Azure resources
- See `IaC/README.md` for detailed infrastructure documentation

#### 2. Choose Your Application Template
Select either Java or Python based on your technology stack:

**Option A: Java Application**
- Copy `java-app/` to your project
- Customize package names, dependencies, and business logic
- Follow `java-app/README.md` for development and deployment
- Uses: Spring Boot 3.2, Maven, JUnit 5, Docker

**Option B: Python Application**
- Copy `python-app/` to your project  
- Customize models, services, and routes
- Follow `python-app/README.md` for development and deployment
- Uses: FastAPI, Uvicorn, Pydantic, pytest, Docker

#### 3. CI/CD Integration
- Configure GitHub Actions secrets with your Azure credentials
- Use provided workflows as templates for your infrastructure
- Workflows auto-trigger on code and Dockerfile changes
- See GitHub Actions section below for detailed configuration

#### 4. Customization Points

Each template provides clear customization paths:

**Java Application**
- Models: Add classes in `src/main/java/com/kustomer/`
- API Endpoints: Create controllers in `src/main/java/com/kustomer/controller/`
- Services: Add business logic in `src/main/java/com/kustomer/service/`
- Tests: Add test classes in `src/test/java/com/kustomer/`

**Python Application**
- Models: Extend `app/models/schemas.py` with Pydantic classes
- API Routes: Create route files in `app/routes/`
- Services: Add business logic in `app/services/`
- Tests: Add test files in `app/tests/`

### Template Features Included

Both application templates include:

✅ **Health Check Endpoints** - Kubernetes liveness/readiness probes  
✅ **Configuration Management** - Environment-based configuration  
✅ **Comprehensive Testing** - Unit and integration tests with coverage  
✅ **Docker Containerization** - Multi-stage optimized builds  
✅ **CI/CD Integration** - GitHub Actions workflows  
✅ **Full Documentation** - 280+ lines (Java), 400+ lines (Python)  
✅ **Service Architecture** - Separation of concerns  
✅ **CORS Support** - Cross-origin request handling  
✅ **API Documentation** - Auto-generated (Python only with Swagger)  
✅ **Code Quality** - Linting, formatting, type checking

## Detailed Application Documentation

### Java Application

The `java-app/` directory contains a production-ready Spring Boot microservice.

**Quick Start**:
```bash
cd java-app
mvn clean package
java -jar target/java-app-1.0.0.jar
```

**Key Features**:
- Spring Boot 3.2 with Java 17
- REST API with health checks
- Unit tests with JUnit 5  
- Code coverage with JaCoCo
- Kubernetes-ready with liveness/readiness probes
- Docker multi-stage build

**Available Endpoints**:
- `GET /api/health` - Custom health check
- `GET /actuator/health` - Spring Boot actuator health
- `GET /actuator/info` - Application information
- `GET /actuator/metrics` - Application metrics

**Documentation**: See `java-app/README.md` (280+ lines with structure, prerequisites, local dev, Docker, CI/CD, Kubernetes deployment, and troubleshooting)

### Python Application

The `python-app/` directory contains a production-ready FastAPI microservice.

**Quick Start**:
```bash
cd python-app
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
uvicorn app.main:app --reload
```

**Key Features**:
- FastAPI with automatic API documentation
- Pydantic validation and settings
- pytest test suite with fixtures
- Service layer architecture
- Kubernetes-ready with health probes
- Docker multi-stage build

**Available Endpoints**:
- `GET /api/health` - Comprehensive health check
- `GET /api/health/live` - Kubernetes liveness probe
- `GET /api/health/ready` - Kubernetes readiness probe
- `GET /docs` - Swagger UI documentation
- `GET /redoc` - ReDoc documentation
- `GET /api/items` - Item management endpoints
- `POST /api/items` - Create item
- `GET /api/items/{item_id}` - Get item by ID
- `PUT /api/items/{item_id}` - Update item
- `DELETE /api/items/{item_id}` - Delete item

**Documentation**: See `python-app/README.md` (400+ lines with structure, prerequisites, local dev, Docker, CI/CD, Kubernetes deployment, monitoring, and troubleshooting)

## Usage

### Local Development

1. Clone the repository:
```bash
git clone https://github.com/pokamcst/cloudops-bootstrap.git
cd cloudops-bootstrap
```

2. Set up environment variables:
```bash
export ARM_CLIENT_ID=your_client_id
export ARM_CLIENT_SECRET=your_client_secret
export ARM_SUBSCRIPTION_ID=your_subscription_id
export ARM_TENANT_ID=your_tenant_id
export TF_VAR_environment=test
```

3. Deploy Infrastructure:
```bash
cd IaC
terraform init -backend=false
terraform plan
terraform apply
```

4. Build and Deploy Applications:

**For Java**:
```bash
cd java-app
mvn clean package
docker build -t kustomer-java-app:latest .
# Push to ACR or deploy locally
```

**For Python**:
```bash
cd python-app
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### GitHub Actions Deployment

1. Configure GitHub Secrets:
   - `AZURE_CREDENTIALS` - Service principal (JSON)
   - `AZURE_CLIENT_ID`
   - `AZURE_CLIENT_SECRET`
   - `AZURE_SUBSCRIPTION_ID`
   - `AZURE_TENANT_ID`
   - `JAVA_WEBAPP_NAME` - Azure Web App name (for Java)
   - `PYTHON_WEBAPP_NAME` - Azure Web App name (for Python)
   - `AZURE_ACR_NAME` - Container registry name

2. Trigger deployment:
   - Push to `main` branch for automatic infrastructure & app deployment
   - Push to `develop` branch for staging deployment
   - Use `workflow_dispatch` for manual trigger to specific environment

3. Monitor deployments:
   - GitHub Actions tab shows workflow status
   - Artifacts available for download (test results, build artifacts)
   - Deployment logs provide detailed output
   - Check Azure portal for deployed resources

## Security Considerations

- All sensitive data stored in Azure Key Vault
- Network security groups restrict access
- Private endpoints for database and storage access
- Managed identities for Azure authentication
- Container images scanned for vulnerabilities
- RBAC controls resource access
- Private endpoints for Azure services
- Managed identities for service authentication
- Regular security scanning and compliance checks

## Monitoring and Maintenance

- Application Insights for application monitoring
- Log Analytics for centralized logging
- Automated alerts for critical issues
- Regular compliance and security checks
- Automated backup and recovery procedures

## Contributing

1. Create a feature branch
2. Make your changes
3. Run tests locally
4. Submit a pull request
5. Wait for review and approval

## License

This project is licensed under the MIT License - see the LICENSE file for details.
