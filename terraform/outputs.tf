output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = module.aks.cluster_name
}

output "aks_kube_config" {
  description = "The kubeconfig for the AKS cluster"
  value       = module.aks.kube_config
  sensitive   = true
}

output "front_door_endpoint" {
  description = "The endpoint URL for Azure Front Door"
  value       = module.front_door.endpoint
}

output "cosmos_db_endpoint" {
  description = "The endpoint URL for Cosmos DB"
  value       = module.databases.cosmos_db_endpoint
}

output "blob_storage_primary_endpoint" {
  description = "The primary endpoint URL for Blob Storage"
  value       = module.storage.blob_storage_primary_endpoint
}

output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = module.security.key_vault_id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = module.security.log_analytics_workspace_id
}

output "application_insights_id" {
  description = "The ID of the Application Insights instance"
  value       = module.monitoring.application_insights_id
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key for Application Insights"
  value       = module.monitoring.application_insights_instrumentation_key
  sensitive   = true
} 