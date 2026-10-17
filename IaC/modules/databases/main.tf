# Cosmos DB Account
resource "azurerm_cosmosdb_account" "main" {
  name                = "cosmos-photo-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  tags                = var.tags

  enable_automatic_failover           = true
  enable_multiple_write_locations     = false

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  geo_location {
    location          = "westus2"
    failover_priority = 1
  }

  capabilities {
    name = "EnableServerless"
  }

  network_acl_bypass_for_azure_services = true
  network_acl_bypass_ids                = []
}

# Cosmos DB Database
resource "azurerm_cosmosdb_sql_database" "main" {
  name                = "photo-db"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  throughput          = 400
}

# Cosmos DB Containers
resource "azurerm_cosmosdb_sql_container" "users" {
  name                = "users"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  partition_key_path  = "/id"
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "albums" {
  name                = "albums"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  partition_key_path  = "/userId"
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "photos" {
  name                = "photos"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  partition_key_path  = "/albumId"
  throughput          = 400
}

# Private Endpoint for Cosmos DB
resource "azurerm_private_endpoint" "cosmos" {
  name                = "pe-cosmos-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-cosmos-${var.environment}"
    private_connection_resource_id = azurerm_cosmosdb_account.main.id
    is_manual_connection           = false
    subresource_names              = ["Sql"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.cosmos.id]
  }
}

# Private DNS Zone for Cosmos DB
resource "azurerm_private_dns_zone" "cosmos" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = var.resource_group_name
}

# Link Private DNS Zone to Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "cosmos" {
  name                  = "link-cosmos-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.cosmos.name
  virtual_network_id    = var.vnet_id
}
