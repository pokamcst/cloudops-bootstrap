output "vnet_id" {
  description = "Virtual network ID"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Virtual network name"
  value       = azurerm_virtual_network.vnet.name
}

output "aks_subnet_id" {
  description = "AKS subnet ID"
  value       = azurerm_subnet.aks.id
}

output "pe_subnet_id" {
  description = "Private endpoint subnet ID"
  value       = azurerm_subnet.pe.id
}

output "app_subnet_id" {
  description = "Application subnet ID"
  value       = azurerm_subnet.app.id
}

output "subnet_ids" {
  description = "Map of all subnet IDs"
  value = {
    aks = azurerm_subnet.aks.id
    pe  = azurerm_subnet.pe.id
    app = azurerm_subnet.app.id
  }
}
