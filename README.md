# CloudOps Bootstrap

A comprehensive infrastructure-as-code solution for deploying and managing cloud operations infrastructure on Azure.

## Overview

This project provides a complete infrastructure setup for cloud operations, including:

- **Kubernetes Cluster (AKS)**: Managed Kubernetes cluster with node pools
- **Container Registry (ACR)**: Private container registry for application images
- **Key Vault**: Secure secrets management
- **Storage Account**: Blob storage for application data
- **Monitoring**: Application Insights and Log Analytics
- **Networking**: Virtual Network with subnets and network security
- **Identity**: Managed identities and role assignments

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
.
├── IaC/                     # Infrastructure as Code (primary)
│   ├── main.tf              # Main configuration
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Outputs
│   ├── providers.tf         # Provider setup
│   ├── locals.tf            # Local values
│   ├── terraform.tfvars.example
│   ├── .gitignore
│   ├── README.md            # IaC documentation
│   └── modules/
│       ├── acr/             # Azure Container Registry
│       ├── aks/             # Azure Kubernetes Service
│       ├── databases/       # Cosmos DB & PostgreSQL
│       ├── monitoring/      # App Insights & Monitoring
│       ├── networking/      # VNet & Subnets
│       ├── security/        # Key Vault & Identities
│       └── storage/         # Storage Account
│
├── java-app/                # Kustomer Java Application
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
│   ├── pom.xml              # Maven configuration
│   ├── Dockerfile           # Multi-stage Docker build
│   ├── .gitignore
│   └── README.md            # Java app documentation
│
├── .github/
│   └── workflows/
│       ├── azure_infra_depl.yml      # Infrastructure validation & deployment
│       ├── terraform-deploy.yml      # Terraform deployment
│       └── java-apps-deploy.yml      # Java app CI/CD
│
├── CONSOLIDATION_SUMMARY.md # Infrastructure consolidation summary
└── README.md                # This file
```

## Deployment Workflows

### Infrastructure Deployment

**azure_infra_depl.yml** - Infrastructure Validation & Deployment
- Triggers on: Changes to `IaC/**/*.tf` files
- Runs on: `main`, `develop`, and `feature/*` branches
- Actions:
  - Terraform init, validate, plan
  - Plan artifacts uploaded for review
  - Auto-apply on main/develop branches

**terraform-deploy.yml** - Advanced Terraform Deployment
- Triggers on: Changes to `IaC/**/*.tf` files
- Runs on: `main` and `develop` branches
- Actions:
  - Format check
  - Validation and security scanning
  - Plan and apply with detailed output
  - Environment-specific deployment

### Java Application Deployment

**java-apps-deploy.yml** - Java App CI/CD Pipeline
- Triggers on: Changes to `java-app/**` or `Dockerfile`
- Runs on: `main` and `develop` branches
- Stages:
  1. **Build & Test**
     - Setup JDK 17
     - Build with Maven
     - Run unit tests
     - Generate JaCoCo coverage reports
     - Upload test results and JAR artifacts
  
  2. **Build Docker Image**
     - Download compiled JAR
     - Login to Azure Container Registry
     - Multi-stage Docker build and push
     - Tag with git SHA and environment
     - Layer caching for performance
  
  3. **Deploy**
     - Deploy to Azure Web App for Containers
     - Health check validation
     - Auto-rollback on failure

## Java Application

The `java-app/` directory contains a production-ready Spring Boot application:

### Quick Start

```bash
cd java-app

# Build locally
mvn clean package

# Run locally
java -jar target/java-app-1.0.0.jar

# Build Docker image
docker build -t kustomer-java-app:latest .

# Run in Docker
docker run -p 8080:8080 kustomer-java-app:latest
```

### Available Endpoints

- `GET /api/health` - Custom health check
- `GET /actuator/health` - Spring Boot actuator health
- `GET /actuator/info` - Application information
- `GET /actuator/metrics` - Application metrics

### Features

- Spring Boot 3.2 with Java 17
- REST API with health checks
- Unit tests with JUnit 5
- Code coverage with JaCoCo
- Docker multi-stage build
- Container health checks
- Kubernetes-ready with liveness/readiness probes

For detailed documentation, see `java-app/README.md`

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

4. Build and Deploy Java App:
```bash
cd java-app
mvn clean package
docker build -t kustomer-java-app:latest .
# Push to ACR or deploy locally
```

### GitHub Actions Deployment

1. Configure GitHub Secrets:
   - `AZURE_CREDENTIALS` - Service principal (JSON)
   - `AZURE_CLIENT_ID`
   - `AZURE_CLIENT_SECRET`
   - `AZURE_SUBSCRIPTION_ID`
   - `AZURE_TENANT_ID`
   - `JAVA_WEBAPP_NAME` - Azure Web App name
   - `AZURE_ACR_NAME` - Container registry name

2. Trigger deployment:
   - Push to `main` branch for automatic infrastructure & app deployment
   - Push to `develop` branch for staging deployment
   - Use `workflow_dispatch` for manual trigger to specific environment

3. Monitor deployments:
   - GitHub Actions tab shows workflow status
   - Artifacts available for download (test results, JARs)
   - Deployment logs provide detailed output

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
