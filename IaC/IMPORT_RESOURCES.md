# Importing Existing Azure Resources into Terraform State

## Problem
You have resources in Azure Portal (`kustomer-dev-rg`) but Terraform says "no changes" because it has no state file tracking them.

## Solution
Import the existing resources into Terraform state so Terraform can manage them.

---

## Quick Fix: Import Existing Resources

### Step 1: Initialize Terraform
```bash
cd IaC
terraform init
```

### Step 2: Import Resource Group
```bash
terraform import azurerm_resource_group.main /subscriptions/{SUBSCRIPTION_ID}/resourceGroups/kustomer-dev-rg
```

Replace `{SUBSCRIPTION_ID}` with your Azure subscription ID:
```bash
# Example:
terraform import azurerm_resource_group.main /subscriptions/8557fe6a-e6ba-4ade-906e-d36316cbf71c/resourceGroups/kustomer-dev-rg
```

### Step 3: Import Node Resource Group
```bash
terraform import azurerm_resource_group.aks_nodes /subscriptions/{SUBSCRIPTION_ID}/resourceGroups/kustomer-dev-aks-nodes-rg
```

### Step 4: Verify State
```bash
terraform state list
terraform state show azurerm_resource_group.main
```

### Step 5: Try Plan Again
```bash
terraform plan -destroy -var="environment=dev"
```

Now it should show resources to destroy! ✅

---

## Detailed Import Guide

### Find Your Subscription ID
```bash
az account show --query id -o tsv
```

### Import All Resources (Manual)

If you want to import all resources, follow this pattern:

```bash
# Resource Groups
terraform import azurerm_resource_group.main /subscriptions/{SUB_ID}/resourceGroups/kustomer-dev-rg
terraform import azurerm_resource_group.aks_nodes /subscriptions/{SUB_ID}/resourceGroups/kustomer-dev-aks-nodes-rg

# Key Vault
terraform import azurerm_key_vault.main /subscriptions/{SUB_ID}/resourceGroups/kustomer-dev-rg/providers/Microsoft.KeyVault/vaults/kv-photo-dev

# Log Analytics Workspace
terraform import azurerm_log_analytics_workspace.main /subscriptions/{SUB_ID}/resourceGroups/kustomer-dev-rg/providers/Microsoft.OperationalInsights/workspaces/law-photo-dev

# Network Security Groups
terraform import azurerm_network_security_group.aks /subscriptions/{SUB_ID}/resourceGroups/kustomer-dev-rg/providers/Microsoft.Network/networkSecurityGroups/nsg-aks-dev
terraform import azurerm_network_security_group.app /subscriptions/{SUB_ID}/resourceGroups/kustomer-dev-rg/providers/Microsoft.Network/networkSecurityGroups/nsg-app-dev

# Virtual Network
terraform import azurerm_virtual_network.main /subscriptions/{SUB_ID}/resourceGroups/kustomer-dev-rg/providers/Microsoft.Network/virtualNetworks/vnet-photo-dev

# Managed Identity
terraform import azurerm_user_assigned_identity.aks /subscriptions/{SUB_ID}/resourceGroups/kustomer-dev-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-aks-dev
```

---

## Better Solution: Enable Remote Backend

To prevent this in the future, use Azure Storage for Terraform state:

### Create Storage Account
```bash
az group create --name terraform-state-rg --location eastus2
az storage account create \
  --name terraformstate \
  --resource-group terraform-state-rg \
  --location eastus2 \
  --sku Standard_LRS
az storage container create --name tfstate --account-name terraformstate
```

### Update providers.tf
```hcl
backend "azurerm" {
  resource_group_name  = "terraform-state-rg"
  storage_account_name = "terraformstate"
  container_name       = "tfstate"
  key                  = "kustomer.terraform.tfstate"
}
```

### Reinitialize
```bash
terraform init
```

---

## Why This Happened

1. **No state file**: Terraform needs `terraform.tfstate` to track resources
2. **Local init**: You ran `terraform init -backend=false` in workflows
3. **No backend**: Remote state not configured in providers.tf
4. **Manual creation**: Resources created but not tracked by Terraform

---

## How to Avoid This

1. **Enable remote backend** (recommended)
2. **Always use `terraform apply`** to create resources (not manual Portal creation)
3. **Keep state file safe** (in Azure Storage, not in git)
4. **One source of truth**: Use Terraform only, don't mix with manual Portal changes

---

## Next Steps

1. **Quick fix**: Import resources (above commands)
2. **Verify**: Run `terraform plan` and see resources
3. **Then destroy**: Run destroy workflow
4. **Setup remote backend** to prevent future issues

---

**Last Updated**: December 27, 2025
