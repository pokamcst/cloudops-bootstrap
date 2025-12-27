# Python Bootstrap Application

FastAPI-based microservice template for rapid cloud application development and deployment to Azure. This application serves as a blueprint for new customers implementing cloud operations with the Kustomer platform.

## Overview

This Python application provides a production-ready FastAPI microservice with the following features:

- **Modern Python Framework**: Built with FastAPI for high performance and automatic API documentation
- **Health Check Endpoints**: Kubernetes-ready liveness and readiness probes
- **Service Layer Architecture**: Separation of concerns with services, models, and routes
- **Comprehensive Testing**: Full pytest test suite with unit and integration tests
- **Containerized**: Multi-stage Docker build optimized for production
- **Azure Integration**: Pre-configured for deployment to Azure App Service
- **Configuration Management**: Environment-based configuration with Pydantic Settings
- **API Documentation**: Auto-generated Swagger UI and ReDoc documentation

## Project Structure

```
python-app/
├── app/
│   ├── __init__.py              # Package initialization
│   ├── main.py                  # FastAPI application setup
│   ├── config.py                # Configuration management
│   ├── models/
│   │   ├── __init__.py
│   │   └── schemas.py           # Pydantic data models
│   ├── services/
│   │   ├── __init__.py
│   │   ├── item_service.py      # Item business logic
│   │   └── user_service.py      # User management service
│   ├── routes/
│   │   ├── __init__.py
│   │   ├── health.py            # Health check endpoints
│   │   └── api.py               # Item management endpoints
│   └── tests/
│       ├── conftest.py          # pytest fixtures and configuration
│       ├── test_health.py       # Health endpoint tests
│       ├── test_item_service.py # Item service tests
│       └── test_user_service.py # User service tests
├── Dockerfile                   # Multi-stage production build
├── .dockerignore                # Docker build exclusions
├── pyproject.toml              # Modern Python packaging configuration
├── requirements.txt            # Runtime dependencies
├── requirements-dev.txt        # Development and testing tools
├── .env.example                # Environment variables template
└── README.md                   # This file
```

## Prerequisites

- **Python 3.10+**: Core runtime environment
- **pip**: Python package manager
- **Docker**: For containerized deployment
- **Azure CLI**: For Azure deployment (optional, for manual deployment)
- **Git**: For version control

### Python Version Management

Use `python --version` to verify Python 3.10+:

```bash
python --version  # Should output: Python 3.10.x or higher
```

If you have multiple Python versions, use `python3.10` explicitly:

```bash
python3.10 -m venv venv
```

## Local Development

### 1. Environment Setup

Clone the repository and navigate to the python-app directory:

```bash
cd python-app
```

Create and activate a virtual environment:

```bash
# On Windows
python -m venv venv
venv\Scripts\activate

# On macOS/Linux
python -m venv venv
source venv/bin/activate
```

Install dependencies:

```bash
# Install runtime dependencies
pip install -r requirements.txt

# Install development dependencies (optional, for testing/linting)
pip install -r requirements-dev.txt
```

### 2. Environment Configuration

Create a `.env` file from the template:

```bash
cp .env.example .env
```

Edit `.env` to configure your environment:

```env
APP_NAME=Python Bootstrap App
DEBUG=True
HOST=0.0.0.0
PORT=8000
CORS_ORIGINS=["http://localhost:3000","http://localhost:8080"]
ENVIRONMENT=development
```

### 3. Running Locally

Start the development server:

```bash
# With auto-reload
uvicorn app.main:app --reload

# Or using Python module
python -m uvicorn app.main:app --reload
```

The application will be available at:

- **Main URL**: http://localhost:8000
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **Health Check**: http://localhost:8000/api/health

### 4. Running Tests

Execute the test suite:

```bash
# Run all tests
pytest

# Run with coverage report
pytest --cov=app --cov-report=html

# Run specific test file
pytest app/tests/test_health.py

# Run with verbose output
pytest -v

# Run tests in watch mode (requires watchfiles)
pytest-watch
```

### 5. Code Quality

Format and lint your code:

```bash
# Format code with Black
black app/

# Check formatting without changes
black app/ --check

# Sort imports
isort app/

# Check code style
flake8 app/

# Type checking with mypy
mypy app/
```

## API Documentation

### Health Check Endpoints

The application exposes three health check endpoints for monitoring and orchestration:

#### 1. General Health Check
```http
GET /api/health
```

Returns comprehensive health status:

```json
{
  "status": "UP",
  "message": "Application is healthy",
  "version": "1.0.0"
}
```

#### 2. Liveness Probe (Kubernetes)
```http
GET /api/health/live
```

Used by Kubernetes to determine if the container is alive. Returns `200 OK` if the application process is running.

#### 3. Readiness Probe (Kubernetes)
```http
GET /api/health/ready
```

Used by Kubernetes to determine if the application is ready to accept traffic. Returns `200 OK` when all dependencies are initialized.

### Item Management Endpoints

#### List All Items
```http
GET /api/items
```

Response:
```json
[
  {
    "id": 1,
    "name": "Item 1",
    "description": "Description",
    "status": "active",
    "created_at": "2024-01-01T00:00:00",
    "updated_at": "2024-01-01T00:00:00"
  }
]
```

#### Get Item by ID
```http
GET /api/items/{item_id}
```

#### Create Item
```http
POST /api/items
Content-Type: application/json

{
  "name": "New Item",
  "description": "Item description"
}
```

#### Update Item
```http
PUT /api/items/{item_id}
Content-Type: application/json

{
  "name": "Updated Name",
  "description": "Updated description"
}
```

#### Delete Item
```http
DELETE /api/items/{item_id}
```

## Docker

### Building the Docker Image

Build the multi-stage Docker image:

```bash
# Build with default tag
docker build -t python-app:latest .

# Build with specific tag
docker build -t python-app:v1.0 .

# Build with registry prefix (for Azure Container Registry)
docker build -t myregistry.azurecr.io/python-app:latest .
```

### Running in Docker

Run the container locally:

```bash
# Run with default settings
docker run -p 8000:8000 python-app:latest

# Run with environment variables
docker run -p 8000:8000 \
  -e APP_NAME="My App" \
  -e DEBUG=False \
  -e ENVIRONMENT=production \
  python-app:latest

# Run in background
docker run -d -p 8000:8000 --name python-app python-app:latest

# View container logs
docker logs python-app

# Stop the container
docker stop python-app

# Remove the container
docker rm python-app
```

### Docker Compose (Optional)

Create a `docker-compose.yml` for local development:

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8000:8000"
    environment:
      APP_NAME: Python Bootstrap App
      DEBUG: "True"
      ENVIRONMENT: development
    volumes:
      - ./app:/app/app
```

Run with Docker Compose:

```bash
docker-compose up
docker-compose down
```

## CI/CD Pipeline

The application integrates with GitHub Actions for automated build, test, and deployment:

### Pipeline Triggers

The workflow triggers on:

1. **Manual dispatch**: Via GitHub UI or API
2. **Branch pushes**: To `main` or `develop`
3. **Code changes**: To files in `python-app/` directory
4. **Docker changes**: When `Dockerfile` is modified

### Pipeline Stages

#### 1. Build & Test Stage
- **Checkout code**: Clone repository
- **Setup Python**: Install Python 3.10
- **Install dependencies**: pip install from requirements.txt
- **Run tests**: pytest with coverage reporting
- **Upload artifacts**: Test results and coverage reports

#### 2. Docker Build Stage
- **Build image**: Multi-stage Docker build
- **Push to registry**: Push to Azure Container Registry
- **Generate artifact**: For deployment stage

#### 3. Deploy Stage
- **Download artifacts**: Get Docker image details
- **Deploy to Azure**: Azure App Service deployment
- **Health check**: Verify application is healthy
- **Rollback on failure**: Automatic rollback if health checks fail

### Accessing Pipeline Results

1. **GitHub Actions UI**: https://github.com/your-org/your-repo/actions
2. **Test Results**: Available in workflow run details
3. **Coverage Reports**: Can be integrated with services like Codecov
4. **Deployment Status**: Visible in workflow logs and environment tabs

## Kubernetes Deployment

The application is optimized for Kubernetes with proper health check endpoints and resource definitions:

### Health Probes Configuration

In your Kubernetes manifest, configure the health probes:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: python-app
spec:
  containers:
  - name: app
    image: python-app:latest
    ports:
    - containerPort: 8000
    
    # Liveness probe - kills unhealthy containers
    livenessProbe:
      httpGet:
        path: /api/health/live
        port: 8000
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 3
    
    # Readiness probe - removes from load balancer if not ready
    readinessProbe:
      httpGet:
        path: /api/health/ready
        port: 8000
      initialDelaySeconds: 5
      periodSeconds: 5
      timeoutSeconds: 5
      failureThreshold: 3
```

### Resource Limits

Recommended resource allocation:

```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

## Azure Deployment

### Prerequisites for Azure Deployment

- Azure subscription with App Service plan
- Azure Container Registry for storing Docker images
- GitHub secrets configured:
  - `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID
  - `AZURE_CREDENTIALS`: Service principal credentials (JSON format)
  - `REGISTRY_LOGIN_SERVER`: ACR login server
  - `REGISTRY_USERNAME`: ACR username
  - `REGISTRY_PASSWORD`: ACR password

### Deployment Steps

1. **Configure Azure Credentials** (in GitHub Repository Settings):
   - Go to Settings → Secrets and variables → Actions
   - Add `AZURE_CREDENTIALS` with service principal JSON
   - Add registry credentials

2. **Trigger Deployment**:
   - Push code to `main` or `develop`
   - Or manually trigger in GitHub Actions UI

3. **Verify Deployment**:
   - Check GitHub Actions workflow status
   - Visit deployed application URL in Azure portal
   - Check health endpoints for proper responses

### Troubleshooting Deployment

If deployment fails:

1. **Check workflow logs**: GitHub Actions → workflow run → view logs
2. **Verify credentials**: Ensure Azure credentials are correctly configured
3. **Check application logs**: Azure portal → App Service → Log stream
4. **Verify health endpoint**: `curl https://your-app.azurewebsites.net/api/health`

## Monitoring and Observability

### Application Insights Integration

The application can be integrated with Azure Application Insights for monitoring:

1. **Configure Application Insights**:
   ```bash
   pip install azure-monitor-opentelemetry-django
   ```

2. **Add to `app/main.py`**:
   ```python
   from azure.monitor.opentelemetry import configure_azure_monitor
   
   configure_azure_monitor(
       connection_string="InstrumentationKey=..."
   )
   ```

3. **View metrics** in Azure portal

### Logging Configuration

Logs are written to stdout/stderr for container environments:

```python
# app/config.py already includes logging configuration
import logging

logger = logging.getLogger(__name__)
logger.info("Application started")
```

View logs in:
- **Local**: Console output
- **Docker**: `docker logs <container-id>`
- **Kubernetes**: `kubectl logs <pod-name>`
- **Azure App Service**: Monitoring → App Service logs

## Environment Variables

All configuration is managed through environment variables defined in `.env`:

| Variable | Default | Description |
|----------|---------|-------------|
| `APP_NAME` | Python Bootstrap App | Application name |
| `DEBUG` | False | Enable debug mode |
| `HOST` | 0.0.0.0 | Server host |
| `PORT` | 8000 | Server port |
| `CORS_ORIGINS` | [] | CORS allowed origins (JSON array) |
| `ENVIRONMENT` | production | Deployment environment |

## Performance Tuning

### Uvicorn Configuration

Optimize Uvicorn for your workload:

```bash
# For production, use multiple workers
uvicorn app.main:app --workers 4 --host 0.0.0.0 --port 8000

# Enable access logs
uvicorn app.main:app --access-log

# Configure timeouts
uvicorn app.main:app --timeout-keep-alive 5
```

### Database Connection Pooling

For database integration, configure connection pools:

```python
# In app/config.py or services
from sqlalchemy.pool import QueuePool

engine = create_engine(
    DATABASE_URL,
    poolclass=QueuePool,
    pool_size=10,
    max_overflow=20,
    pool_pre_ping=True,  # Verify connections before using
)
```

## Security Considerations

### CORS Configuration

The application includes CORS middleware. Configure allowed origins:

```bash
# Development
CORS_ORIGINS=["http://localhost:3000","http://localhost:8080"]

# Production - restrict to your domain
CORS_ORIGINS=["https://yourdomain.com"]
```

### Secrets Management

Never commit secrets. Use Azure Key Vault:

```python
# Use app/config.py to load secrets from environment
from pydantic import SecretStr

class Settings(BaseSettings):
    api_key: SecretStr = Field(..., description="API Key")
```

### Password Hashing

Replace SHA256 with bcrypt or Argon2 for production:

```bash
pip install bcrypt
```

Update `app/services/user_service.py`:

```python
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)
```

## Troubleshooting

### Application won't start

**Issue**: `ModuleNotFoundError: No module named 'fastapi'`

**Solution**: Ensure virtual environment is activated and dependencies installed:
```bash
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
```

### Port already in use

**Issue**: `Address already in use`

**Solution**: Change port or kill the process:
```bash
# Use a different port
uvicorn app.main:app --port 8001

# Or find and kill the process using the port
# On macOS/Linux
lsof -i :8000 | grep LISTEN | awk '{print $2}' | xargs kill -9
```

### Docker image size too large

**Issue**: Docker image exceeds registry limits

**Solution**: The multi-stage build is already optimized. Ensure you're using the built image, not a layer:
```bash
docker images | grep python-app  # Check actual size
```

### Tests failing in CI/CD

**Issue**: Tests pass locally but fail in GitHub Actions

**Solution**:
1. Check Python version matches: `3.10`
2. Ensure all dependencies in `requirements.txt` and `requirements-dev.txt`
3. Check environment variables in GitHub Actions workflow
4. Review workflow logs for detailed error messages

### Health endpoint returns 502

**Issue**: Azure App Service returns 502 Bad Gateway

**Solution**:
1. Check application logs: Azure portal → Log stream
2. Verify application started: `docker logs <container>`
3. Check health endpoint locally: `curl http://localhost:8000/api/health`
4. Review application configuration matches Azure environment

## Next Steps

### Customization Guide

To customize this application for your use case:

1. **Modify Models** (`app/models/schemas.py`):
   - Define your data structures
   - Use Pydantic validation

2. **Create Services** (`app/services/`):
   - Add business logic
   - Implement database access
   - Handle third-party integrations

3. **Add Routes** (`app/routes/`):
   - Create new endpoint files
   - Import and include in `app/main.py`

4. **Update Tests**:
   - Add tests for new functionality
   - Maintain test coverage above 80%

5. **Configure CI/CD**:
   - Add build steps if needed
   - Configure deployment targets
   - Set up monitoring and alerts

### Integration Examples

**With Database (PostgreSQL)**:
```bash
pip install sqlalchemy psycopg2-binary
```

**With Azure CosmosDB**:
```bash
pip install azure-cosmos
```

**With Message Queue (RabbitMQ)**:
```bash
pip install aio-pika
```

## Support and Resources

- **FastAPI Documentation**: https://fastapi.tiangolo.com/
- **Uvicorn Documentation**: https://www.uvicorn.org/
- **Pydantic Documentation**: https://docs.pydantic.dev/
- **Azure App Service**: https://docs.microsoft.com/en-us/azure/app-service/
- **Kubernetes Documentation**: https://kubernetes.io/docs/

## License

This bootstrap application is provided as a template for rapid deployment. Modify and redistribute as needed for your organization.

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-01-01 | Initial release with FastAPI, health checks, services, and tests |

---

**Last Updated**: January 2024  
**Maintainer**: Cloud Operations Team
