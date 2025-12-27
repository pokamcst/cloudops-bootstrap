output "acr_id" {
  description = "Azure Container Registry ID"
  value       = azurerm_container_registry.main.id
}

output "acr_name" {
  description = "Azure Container Registry name"
  value       = azurerm_container_registry.main.name
}

output "login_server" {
  description = "ACR login server"
  value       = azurerm_container_registry.main.login_server
}

output "admin_username" {
  description = "ACR admin username"
  value       = var.admin_enabled ? azurerm_container_registry.main.admin_username : ""
  sensitive   = true
}

output "admin_password" {
  description = "ACR admin password"
  value       = var.admin_enabled ? azurerm_container_registry.main.admin_password : ""
  sensitive   = true
}
