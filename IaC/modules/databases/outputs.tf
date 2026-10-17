output "cosmos_db_id" {
  description = "Cosmos DB account ID"
  value       = azurerm_cosmosdb_account.main.id
}

output "cosmos_db_endpoint" {
  description = "Cosmos DB account endpoint"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "cosmos_db_connection_strings" {
  description = "Cosmos DB connection strings"
  value       = azurerm_cosmosdb_account.main.connection_strings
  sensitive   = true
}

output "cosmos_db_primary_key" {
  description = "Cosmos DB primary key"
  value       = azurerm_cosmosdb_account.main.primary_key
  sensitive   = true
}

output "cosmos_db_secondary_key" {
  description = "Cosmos DB secondary key"
  value       = azurerm_cosmosdb_account.main.secondary_key
  sensitive   = true
}

output "cosmos_db_database_name" {
  description = "Cosmos DB database name"
  value       = azurerm_cosmosdb_sql_database.main.name
}

output "cosmos_db_containers" {
  description = "Map of Cosmos DB container names"
  value = {
    users  = azurerm_cosmosdb_sql_container.users.name
    albums = azurerm_cosmosdb_sql_container.albums.name
    photos = azurerm_cosmosdb_sql_container.photos.name
  }
}
