output "key_vault_id" {
  description = "Key Vault resource ID"
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.main.vault_uri
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.main.id
}

output "aks_identity_id" {
  description = "AKS User Assigned Identity ID"
  value       = azurerm_user_assigned_identity.aks.id
}

output "aks_identity_principal_id" {
  description = "AKS User Assigned Identity Principal ID"
  value       = azurerm_user_assigned_identity.aks.principal_id
}
