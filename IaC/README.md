# Infrastructure as Code (IaC)

Production-grade Terraform configuration for Azure cloud infrastructure deployment with built-in FinOps, security, and compliance.

## Directory Structure

```
IaC/
├── README.md                    # This file
├── providers.tf                 # Provider configuration & backend
├── variables.tf                 # Input variables with validation
├── locals.tf                    # Local values and naming conventions
├── main.tf                      # Root module orchestration
├── outputs.tf                   # Output values
├── terraform.tfvars.example     # Example variable values
├── modules/                     # Terraform modules
│   ├── acr/                     # Azure Container Registry
│   ├── aks/                     # Azure Kubernetes Service
│   ├── databases/               # Cosmos DB & PostgreSQL
│   ├── finops/                  # FinOps — Budgets, Alerts, Policies, Cost Exports
│   ├── monitoring/              # Application Insights & Alerting
│   ├── networking/              # Virtual Network & Subnets
│   ├── security/                # Key Vault & Security
│   └── storage/                 # Azure Storage Account
└── tests/                       # Compliance & Testing
    └── terraform-compliance/    # Security compliance tests
```

## Quick Start

### Prerequisites

- Terraform >= 1.5.0
- Azure CLI
- Azure subscription with appropriate permissions

### Authentication

```bash
# Login to Azure
az login

# Set subscription
az account set --subscription <SUBSCRIPTION_ID>
```

### Initialization

```bash
# Initialize Terraform (without backend initially)
terraform init -backend=false

# Select/create workspace (optional)
terraform workspace new dev
terraform workspace select dev
```

### Backend Configuration

The default configuration uses local state. To use a remote backend on Azure Storage:

#### Step 1: Create Storage Account for Terraform State

```bash
# Create resource group
az group create --name terraform-state-rg --location eastus

# Create storage account
az storage account create \
  --resource-group terraform-state-rg \
  --name terraformstate$(date +%s) \
  --sku Standard_LRS \
  --encryption-services blob

# Create container
az storage container create \
  --name tfstate \
  --account-name <STORAGE_ACCOUNT_NAME>

# Note: Save the storage account name and resource group
```

#### Step 2: Enable Backend in providers.tf

Uncomment the backend block in `providers.tf`:

```terraform
backend "azurerm" {
  resource_group_name  = "terraform-state-rg"
  storage_account_name = "terraformstate"
  container_name       = "tfstate"
  key                  = "kustomer.terraform.tfstate"
}
```

#### Step 3: Reinitialize Terraform

```bash
# Initialize with backend configuration
terraform init

# When prompted, confirm migration to remote backend
```

### Planning & Deployment

```bash
# Plan infrastructure changes
terraform plan -out=tfplan

# Apply infrastructure
terraform apply tfplan

# Destroy infrastructure (when done)
terraform destroy
```

## Configuration

### Environment Variables

Set in `terraform.tfvars` or environment:

```hcl
environment                    = "dev"
location                       = "eastus2"
project_name                   = "kustomer"
resource_group_name            = "kustomer-rg"

# AKS Configuration
aks_node_count                 = 3
aks_vm_size                    = "Standard_D2s_v3"
aks_enable_auto_scaling        = true
aks_min_node_count             = 2
aks_max_node_count             = 10
kubernetes_version             = "1.27.3"

# ACR Configuration
acr_sku                        = "Standard"
acr_admin_enabled              = false
acr_public_network_access_enabled = false

# Storage Configuration
storage_account_tier           = "Standard"
storage_replication_type       = "GRS"

# Database Configuration
cosmos_db_throughput           = 400
enable_cosmos_autoscale        = true
postgres_sku_name              = "B_Standard_B2s"
postgres_storage_mb            = 32768

# Features
enable_private_endpoints       = true
enable_diagnostic_settings     = true
log_retention_days             = 30

# FinOps Configuration
finops_monthly_budget          = 1000
finops_budget_currency         = "EUR"
finops_alert_emails            = ["finops@example.com"]
finops_alert_thresholds        = [50, 75, 90, 100, 110]
finops_enable_subscription_budget = true
finops_subscription_budget     = 5000
finops_enable_tagging_policy   = true
finops_enable_anomaly_alerts   = true
finops_enable_advisor_alerts   = true
```

## Modules

### ACR (Azure Container Registry)
- Container image storage and management
- Private endpoint support
- Admin access control
- Credentials management

### AKS (Azure Kubernetes Service)
- Kubernetes cluster deployment
- Multiple node pools (system, workload)
- Network integration
- Monitoring & logging

### Databases
- **Cosmos DB**: NoSQL document database
- **PostgreSQL**: Relational database
- Private endpoint support
- Automated backups

### Monitoring
- Application Insights
- Log Analytics Workspace
- Metric Alerts
- Diagnostic Settings

### Networking
- Virtual Network with subnets
- Network Security Groups
- Service endpoints
- Private endpoints

### Security
- Azure Key Vault
- Managed identities
- Log Analytics Workspace
- RBAC configuration

### Storage
- Azure Storage Account
- Blob storage
- File shares
- Private endpoint support

### FinOps (Cloud Financial Operations)
- **Budget Management** — Resource Group and Subscription budgets with auto-alerts at 50/75/90/100/110%
- **Cost Anomaly Detection** — AI-based anomaly alerts via Azure Cost Management
- **Tag Governance** — Azure Policy enforcement for mandatory cost-tracking tags
- **Tag Inheritance** — Auto-inherit CostCenter, Environment, Project from Resource Group
- **Daily Cost Exports** — Automated ActualCost exports to Storage Account
- **Advisor Alerts** — Notifications for new cost optimization recommendations
- **Environment Multipliers** — dev=1×, staging=1.5×, prod=3× budget scaling

See [FINOPS_CONCEPT.md](../FINOPS_CONCEPT.md) and [FINOPS_PRODUCTION_GUIDE.md](../FINOPS_PRODUCTION_GUIDE.md) for details.

## Outputs

After deployment, retrieve outputs:

```bash
terraform output
terraform output -json > outputs.json
```

Key outputs include:
- AKS cluster name and kubeconfig
- ACR login server and credentials
- Storage account details
- Cosmos DB endpoint
- PostgreSQL FQDN
- FinOps budget ID and effective monthly budget
- FinOps anomaly alert ID
- FinOps cost export storage account

## Best Practices

### State Management
- Use Azure Storage Account for remote state
- Enable state locking
- Keep `.terraform.lock.hcl` in version control

### Security
- Store sensitive values in Key Vault
- Use managed identities instead of service principals
- Enable private endpoints for sensitive services
- Implement RBAC for access control

### Code Quality
- Run `terraform fmt` for formatting
- Use `terraform validate` before committing
- Run compliance tests: `terraform-compliance -f tests/terraform-compliance -p tfplan`
- Use workspaces for multiple environments

## Troubleshooting

### Module Not Found
```bash
terraform get -update
terraform init -upgrade
```

### State Lock Issues
```bash
terraform force-unlock <LOCK_ID>
```

### Provider Issues
```bash
terraform init -upgrade
rm -rf .terraform .terraform.lock.hcl
terraform init
```

## Contributing

1. Create feature branch: `git checkout -b feature/name`
2. Make changes and format: `terraform fmt -recursive`
3. Validate: `terraform validate`
4. Test compliance: `terraform-compliance -f tests/terraform-compliance -p tfplan`
5. Create pull request with detailed description

## Support & Documentation

- [Terraform Docs](https://www.terraform.io/docs)
- [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/cloud-docs/state)

## License

This Infrastructure as Code is part of the Kustomer project.
