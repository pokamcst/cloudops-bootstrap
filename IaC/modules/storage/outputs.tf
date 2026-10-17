output "storage_account_id" {
  description = "Storage account ID"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "Storage account name"
  value       = azurerm_storage_account.main.name
}

output "blob_storage_primary_endpoint" {
  description = "Primary blob storage endpoint"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "blob_storage_primary_connection_string" {
  description = "Primary blob storage connection string"
  value       = azurerm_storage_account.main.primary_blob_connection_string
  sensitive   = true
}

output "photos_container_name" {
  description = "Photos container name"
  value       = azurerm_storage_container.photos.name
}

output "thumbnails_container_name" {
  description = "Thumbnails container name"
  value       = azurerm_storage_container.thumbnails.name
}

output "temp_container_name" {
  description = "Temp container name"
  value       = azurerm_storage_container.temp.name
}
