# Dynamic Project Naming Guide

## Overview
The Terraform infrastructure now supports creating multiple projects with different names. Use the `project_name` variable to customize resource names and resource groups.

## Quick Start

### Default Project (kustomer)
```bash
# Deploy kustomer-dev environment
cd IaC
terraform apply -var="environment=dev"

# Deploy kustomer-prod environment
terraform apply -var="environment=prod"
```

Resources created:
- Resource Group: `kustomer-dev-rg` / `kustomer-prod-rg`
- AKS Node RG: `kustomer-dev-aks-nodes-rg` / `kustomer-prod-aks-nodes-rg`
- ACR: `devkustomeracr` / `prodkustomeracr`
- AKS Cluster: `aks-photo-dev` / `aks-photo-prod`
- Key Vault: `kv-photo-dev` / `kv-photo-prod`

---

## Custom Project Names

### Deploy Project "kustomerx"
```bash
terraform apply \
  -var="project_name=kustomerx" \
  -var="environment=dev"
```

Resources created:
- Resource Group: `kustomerx-dev-rg`
- AKS Node RG: `kustomerx-dev-aks-nodes-rg`
- ACR: `devkustomerxacr`
- AKS Cluster: `aks-photo-dev`
- Key Vault: `kv-photo-dev`

### Deploy Project "acme"
```bash
terraform apply \
  -var="project_name=acme" \
  -var="environment=prod"
```

Resources created:
- Resource Group: `acme-prod-rg`
- AKS Node RG: `acme-prod-aks-nodes-rg`
- ACR: `prodacmeacr`
- AKS Cluster: `aks-photo-prod`
- Key Vault: `kv-photo-prod`

---

## Using terraform.tfvars

Create project-specific `.tfvars` files:

### `kustomer-dev.tfvars`
```hcl
project_name = "kustomer"
environment  = "dev"
location     = "eastus2"
aks_node_count = 2
```

Deploy with:
```bash
terraform apply -var-file="kustomer-dev.tfvars"
```

### `kustomerx-prod.tfvars`
```hcl
project_name = "kustomerx"
environment  = "prod"
location     = "eastus2"
aks_node_count = 5
acr_sku      = "Premium"  # For public network access control
```

Deploy with:
```bash
terraform apply -var-file="kustomerx-prod.tfvars"
```

---

## Naming Convention

Resource names follow this pattern:
```
{project_name}-{environment}
```

### Examples

| Variable | RG Name | AKS Node RG | Purpose |
|----------|---------|-------------|---------|
| kustomer-dev | kustomer-dev-rg | kustomer-dev-aks-nodes-rg | Main dev environment |
| kustomer-prod | kustomer-prod-rg | kustomer-prod-aks-nodes-rg | Main prod environment |
| kustomerx-dev | kustomerx-dev-rg | kustomerx-dev-aks-nodes-rg | New project dev |
| acme-staging | acme-staging-rg | acme-staging-aks-nodes-rg | Staging environment |

---

## Project_name Constraints

✅ **Valid**:
- `kustomer` - alphanumeric, lowercase
- `kustomerx` - up to 20 characters
- `acme` - short names OK
- `my-project` - hyphens allowed

❌ **Invalid**:
- `kustomer_2024` - underscores not ideal (will work but terraform resources have them removed)
- `Kustomer` - uppercase not recommended
- `kustomer-project-name-extra-long-string` - exceeds 20 characters

---

## Workspace Management

Track different projects using Terraform workspaces:

```bash
# Create workspace for project
terraform workspace new kustomerx-prod

# Switch workspace
terraform workspace select kustomerx-prod

# Deploy to current workspace
terraform apply -var="project_name=kustomerx" -var="environment=prod"

# List all workspaces
terraform workspace list

# Delete workspace
terraform workspace delete kustomerx-prod
```

---

## Example: Multi-Project Deployment

```bash
# Deploy main kustomer project - dev
terraform workspace new kustomer-dev
terraform workspace select kustomer-dev
terraform apply -var="project_name=kustomer" -var="environment=dev"

# Deploy main kustomer project - prod
terraform workspace new kustomer-prod
terraform workspace select kustomer-prod
terraform apply -var="project_name=kustomer" -var="environment=prod"

# Deploy new customer project - dev
terraform workspace new kustomerx-dev
terraform workspace select kustomerx-dev
terraform apply -var="project_name=kustomerx" -var="environment=dev"

# Deploy new customer project - prod
terraform workspace new kustomerx-prod
terraform workspace select kustomerx-prod
terraform apply -var="project_name=kustomerx" -var="environment=prod"

# List all deployments
terraform workspace list
```

---

## Validation

Verify your project_name before deploying:

```bash
# Check what resources will be created
terraform plan -var="project_name=newproject" -var="environment=dev"

# Look for these in the output:
# - Resource Group: newproject-dev-rg
# - Node Resource Group: newproject-dev-aks-nodes-rg
# - All resources prefixed with newproject-dev
```

---

## Cleanup

Remove a project deployment:

```bash
# Switch to the project workspace
terraform workspace select kustomerx-prod

# Destroy resources
terraform destroy -var="project_name=kustomerx" -var="environment=prod"

# Delete workspace
terraform workspace select default
terraform workspace delete kustomerx-prod
```

---

## Next Steps

1. **Create terraform.tfvars** for your projects
2. **Plan deployments** to verify resource names
3. **Deploy** using appropriate environment
4. **Monitor** resource groups in Azure Portal
5. **Scale** with additional projects as needed

---

**Last Updated**: December 27, 2025
