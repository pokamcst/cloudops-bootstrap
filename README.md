# CloudOps Bootstrap

[![Infrastructure](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform)](IaC/)
[![Azure](https://img.shields.io/badge/Cloud-Azure-0078D4?logo=microsoftazure)](https://azure.microsoft.com)
[![Java](https://img.shields.io/badge/App-Spring%20Boot%203.2-6DB33F?logo=springboot)](java-app/)
[![Python](https://img.shields.io/badge/App-FastAPI-009688?logo=fastapi)](python-app/)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=githubactions)](.github/workflows/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Production-ready cloud operations bootstrap for Azure. Provides reusable IaC modules, application templates, CI/CD pipelines, and FinOps governance — designed for rapid customer onboarding.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                        CloudOps Bootstrap                            │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │  Infrastructure Layer (IaC/)               Terraform >= 1.5   │  │
│  │  ┌──────────┐ ┌─────┐ ┌──────────┐ ┌──────────┐ ┌────────┐  │  │
│  │  │Networking│ │ AKS │ │   ACR    │ │ Security │ │FinOps  │  │  │
│  │  │ VNet     │ │ K8s │ │ Registry │ │ KeyVault │ │Budgets │  │  │
│  │  │ NSGs     │ │Nodes│ │ Private  │ │ RBAC     │ │Alerts  │  │  │
│  │  │ Subnets  │ │ HPA │ │ Endpoint │ │ Identity │ │Policies│  │  │
│  │  └──────────┘ └─────┘ └──────────┘ └──────────┘ └────────┘  │  │
│  │  ┌──────────┐ ┌───────────┐ ┌──────────┐                     │  │
│  │  │ Storage  │ │ Databases │ │Monitoring│                     │  │
│  │  │ Blob/File│ │ CosmosDB  │ │AppInsight│                     │  │
│  │  │ Private  │ │ PostgreSQL│ │LogAnalyti│                     │  │
│  │  └──────────┘ └───────────┘ └──────────┘                     │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  ┌───────────────────────┐  ┌────────────────────────┐              │
│  │  Java App (java-app/) │  │ Python App (python-app/)│             │
│  │  Spring Boot 3.2      │  │ FastAPI + Pydantic v2   │             │
│  │  JUnit 5 + JaCoCo     │  │ pytest + Coverage       │             │
│  │  Docker Multi-Stage   │  │ Docker Multi-Stage      │             │
│  └───────────────────────┘  └────────────────────────┘              │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │  CI/CD (.github/workflows/)            GitHub Actions v4      │  │
│  │  Infrastructure Plan/Apply | Build/Test | Docker Push | Deploy │  │
│  └────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────┘
```

## Quick Start

### Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| [Terraform](https://www.terraform.io/) | >= 1.5.0 | Infrastructure provisioning |
| [Azure CLI](https://learn.microsoft.com/cli/azure/) | >= 2.50 | Azure authentication |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | >= 1.27 | Kubernetes management |
| [Docker](https://www.docker.com/) | >= 24.0 | Container builds |

### 1. Clone & Configure

```bash
git clone https://github.com/pokamcst/cloudops-bootstrap.git
cd cloudops-bootstrap/IaC

# Create your configuration from the example
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your Azure values
```

### 2. Deploy Infrastructure

```bash
# Authenticate with Azure
az login
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"

# Initialize and deploy
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 3. Deploy Applications

```bash
# Java (Spring Boot)
cd ../java-app
mvn clean package
docker build -t myapp-java .

# Python (FastAPI)
cd ../python-app
pip install -r requirements.txt
docker build -t myapp-python .
```

See [java-app/README.md](java-app/README.md) and [python-app/README.md](python-app/README.md) for full application guides.

## Project Structure

```
cloudops-bootstrap/
├── IaC/                              # Infrastructure as Code (authoritative)
│   ├── main.tf                       # Root module — resource groups + module calls
│   ├── providers.tf                  # Provider & backend configuration
│   ├── variables.tf                  # 50+ input variables with validation
│   ├── outputs.tf                    # All infrastructure outputs
│   ├── locals.tf                     # Local values & naming conventions
│   ├── terraform.tfvars.example      # Configuration template
│   ├── modules/
│   │   ├── networking/               # VNet, subnets, NSGs, private endpoints
│   │   ├── aks/                      # AKS cluster, node pools, autoscaling
│   │   ├── acr/                      # Container registry + Key Vault secrets
│   │   ├── security/                 # Key Vault, RBAC, managed identities
│   │   ├── storage/                  # Blob/File storage, private endpoints
│   │   ├── databases/                # Cosmos DB, PostgreSQL Flexible Server
│   │   ├── monitoring/               # App Insights, alerts, diagnostics
│   │   └── finops/                   # Budgets, cost alerts, tagging policies
│   └── tests/
│       └── terraform-compliance/     # Policy-as-code security tests
│
├── java-app/                         # Spring Boot 3.2 microservice template
│   ├── src/main/                     # Application source (controllers, services)
│   ├── src/test/                     # JUnit 5 tests + JaCoCo coverage
│   ├── Dockerfile                    # Multi-stage Docker build
│   └── pom.xml                       # Maven configuration
│
├── python-app/                       # FastAPI microservice template
│   ├── app/                          # Application (routes, services, models)
│   ├── app/tests/                    # pytest suite (15+ tests)
│   ├── Dockerfile                    # Multi-stage Docker build
│   └── pyproject.toml                # Modern Python packaging
│
├── .github/workflows/                # CI/CD pipelines
│   ├── azure_infra_depl.yml          # Terraform plan/apply
│   ├── java-apps-deploy.yml          # Java build → Docker → deploy
│   └── python-apps-deploy.yml        # Python build → Docker → deploy
│
├── FINOPS_CONCEPT.md                 # FinOps strategy & architecture
├── FINOPS_PRODUCTION_GUIDE.md        # FinOps production & enterprise guide
├── CUSTOMER_CUSTOMIZATION_GUIDE.md   # Customer onboarding guide
├── CONTRIBUTING.md                   # Contribution guidelines
├── LICENSE                           # MIT License
├── Makefile                          # Common development commands
└── INDEX.md                          # Complete project index
```

## Infrastructure Modules

| Module | Resources | Documentation |
|--------|-----------|---------------|
| **networking** | VNet, subnets, NSGs, private endpoints | [IaC/README.md](IaC/README.md) |
| **aks** | Managed Kubernetes, node pools, autoscaling | [IaC/README.md](IaC/README.md) |
| **acr** | Container registry, private endpoint, Key Vault secrets | [IaC/README.md](IaC/README.md) |
| **security** | Key Vault, managed identities, RBAC, Log Analytics | [IaC/README.md](IaC/README.md) |
| **storage** | Blob/File storage, private endpoints | [IaC/README.md](IaC/README.md) |
| **databases** | Cosmos DB (autoscale), PostgreSQL Flexible Server | [IaC/README.md](IaC/README.md) |
| **monitoring** | App Insights, metric alerts, diagnostic settings, web tests | [IaC/README.md](IaC/README.md) |
| **finops** | Budgets, cost anomaly alerts, tagging policies, cost exports | [FINOPS_CONCEPT.md](FINOPS_CONCEPT.md) |

## Environments

| Environment | AKS Nodes | Autoscaling | Budget Multiplier | Recommended SKUs |
|-------------|-----------|-------------|-------------------|------------------|
| **dev** | 1–2 | Min resources | 1.0x | Standard_B2s, Basic ACR |
| **staging** | 2–3 | Production-like | 1.5x | Standard_D2s_v3, Standard ACR |
| **prod** | 3–10 | Full HA | 3.0x | Standard_D4s_v3, Premium ACR |

## CI/CD Pipelines

All pipelines trigger automatically on push to `main`, `develop`, or `feature/*` branches.

| Workflow | Trigger | Stages |
|----------|---------|--------|
| **azure_infra_depl.yml** | `IaC/**/*.tf` changes | Init → Validate → Plan → Apply |
| **java-apps-deploy.yml** | `java-app/**` changes | Build → Test → Docker → Deploy |
| **python-apps-deploy.yml** | `python-app/**` changes | Build → Test → Lint → Docker → Deploy |

### Required GitHub Secrets

```
ARM_CLIENT_ID          # Azure Service Principal
ARM_CLIENT_SECRET      # Azure Service Principal Secret
ARM_SUBSCRIPTION_ID    # Azure Subscription
ARM_TENANT_ID          # Azure AD Tenant
ACR_LOGIN_SERVER       # e.g., myacr.azurecr.io
```

## FinOps (Cost Management)

Integrated FinOps governance for cloud cost optimization:

- **Budget Alerts** — 5 thresholds (50%, 75%, 90%, 100%, 110%) on RG and subscription level
- **Anomaly Detection** — AI-based Azure Cost Anomaly Alerts
- **Tag Governance** — Azure Policy enforcing mandatory cost-tracking tags
- **Daily Cost Exports** — Automated exports to Storage Account for Power BI analysis
- **Advisor Integration** — Alerts on new cost optimization recommendations

| Document | Content |
|----------|---------|
| [FINOPS_CONCEPT.md](FINOPS_CONCEPT.md) | Full FinOps concept, KPIs, RACI matrix, architecture |
| [FINOPS_PRODUCTION_GUIDE.md](FINOPS_PRODUCTION_GUIDE.md) | Deployment guide, checklists, enterprise scaling, chargeback |

## Customer Onboarding

This repo is designed as a **reusable bootstrap** for new customers:

1. **Fork/Clone** this repository
2. **Configure** `IaC/terraform.tfvars` with customer-specific values
3. **Choose** Java or Python application template
4. **Deploy** infrastructure with `terraform apply`
5. **Set up** GitHub Actions secrets for CI/CD

See [CUSTOMER_CUSTOMIZATION_GUIDE.md](CUSTOMER_CUSTOMIZATION_GUIDE.md) for detailed instructions.

## Documentation

| Document | Description |
|----------|-------------|
| [INDEX.md](INDEX.md) | Complete project navigation |
| [IaC/README.md](IaC/README.md) | Infrastructure setup & deployment |
| [java-app/README.md](java-app/README.md) | Java application guide |
| [python-app/README.md](python-app/README.md) | Python application guide |
| [FINOPS_CONCEPT.md](FINOPS_CONCEPT.md) | FinOps strategy & architecture |
| [FINOPS_PRODUCTION_GUIDE.md](FINOPS_PRODUCTION_GUIDE.md) | FinOps production & enterprise guide |
| [CUSTOMER_CUSTOMIZATION_GUIDE.md](CUSTOMER_CUSTOMIZATION_GUIDE.md) | Customer onboarding |
| [PoC.md](PoC.md) | Enterprise architecture proof of concept |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on branching, commits, code review, and quality standards.

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
