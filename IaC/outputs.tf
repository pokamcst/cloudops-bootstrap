# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

# Networking Outputs
output "vnet_id" {
  description = "Virtual Network ID"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Virtual Network name"
  value       = module.networking.vnet_name
}

output "subnet_ids" {
  description = "Subnet IDs"
  value       = module.networking.subnet_ids
}

# AKS Outputs
output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = module.aks.cluster_name
}

output "aks_cluster_id" {
  description = "AKS cluster ID"
  value       = module.aks.cluster_id
}

output "aks_kube_config" {
  description = "Kubeconfig for AKS cluster"
  value       = module.aks.kube_config
  sensitive   = true
}

output "aks_ingress_lb_ip" {
  description = "Ingress load balancer IP"
  value       = module.aks.ingress_lb_ip
}

# ACR Outputs
output "acr_name" {
  description = "Azure Container Registry name"
  value       = module.acr.acr_name
}

output "acr_id" {
  description = "Azure Container Registry ID"
  value       = module.acr.acr_id
}

output "acr_login_server" {
  description = "Azure Container Registry login server"
  value       = module.acr.login_server
}

output "acr_admin_username" {
  description = "Azure Container Registry admin username"
  value       = module.acr.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "Azure Container Registry admin password"
  value       = module.acr.admin_password
  sensitive   = true
}

# Storage Outputs
output "storage_account_name" {
  description = "Storage account name"
  value       = module.storage.storage_account_name
}

output "storage_account_id" {
  description = "Storage account ID"
  value       = module.storage.storage_account_id
}

output "blob_storage_primary_endpoint" {
  description = "Blob storage primary endpoint"
  value       = module.storage.blob_storage_primary_endpoint
}

# Database Outputs
output "cosmos_db_endpoint" {
  description = "Cosmos DB endpoint"
  value       = module.databases.cosmos_db_endpoint
}

output "cosmos_db_primary_key" {
  description = "Cosmos DB primary key"
  value       = module.databases.cosmos_db_primary_key
  sensitive   = true
}

output "postgres_fqdn" {
  description = "PostgreSQL server FQDN"
  value       = ""
}

output "postgres_id" {
  description = "PostgreSQL server ID"
  value       = ""
}

# Security Outputs
output "key_vault_id" {
  description = "Key Vault ID"
  value       = module.security.key_vault_id
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = ""
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = module.security.log_analytics_workspace_id
}

# FinOps Outputs
output "finops_budget_id" {
  description = "Resource Group budget ID"
  value       = module.finops.resource_group_budget_id
}

output "finops_effective_monthly_budget" {
  description = "Effective monthly budget after environment multiplier"
  value       = module.finops.effective_monthly_budget
}

output "finops_anomaly_alert_id" {
  description = "Cost anomaly alert ID"
  value       = module.finops.cost_anomaly_alert_id
}

output "finops_storage_account" {
  description = "FinOps cost export storage account"
  value       = module.finops.finops_storage_account_name
}

# Environment Summary
output "deployment_summary" {
  description = "Summary of the deployment"
  value = {
    environment         = var.environment
    region              = var.location
    resource_group      = azurerm_resource_group.main.name
    aks_cluster_name    = module.aks.cluster_name
    acr_name            = module.acr.acr_name
    storage_account     = module.storage.storage_account_name
  }
}
