# Variables
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "virtual_network_id" {
  description = "ID of the virtual network"
  type        = string
}

variable "subnet_ids" {
  description = "Map of subnet IDs"
  type        = map(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-photo-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                = "kv-photo-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id          = data.azurerm_client_config.current.tenant_id
  sku_name           = "standard"
  tags                = var.tags

  purge_protection_enabled = true
  soft_delete_retention_days = 7

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover", "Backup", "Restore"
    ]

    certificate_permissions = [
      "Get", "List", "Update", "Create", "Import", "Delete", "Purge", "Recover", "Backup", "Restore"
    ]

    key_permissions = [
      "Get", "List", "Update", "Create", "Import", "Delete", "Purge", "Recover", "Backup", "Restore"
    ]
  }
}

# Private Endpoint for Key Vault
resource "azurerm_private_endpoint" "key_vault" {
  name                = "pe-kv-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_ids.pe

  private_service_connection {
    name                           = "psc-kv-${var.environment}"
    private_connection_resource_id = azurerm_key_vault.main.id
    is_manual_connection           = false
    subresource_names             = ["vault"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.key_vault.id]
  }
}

# Private DNS Zone for Key Vault
resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

# Link Private DNS Zone to Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "link-kv-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = var.virtual_network_id
}

# Managed Identity for AKS
resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-aks-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Key Vault Access Policy for AKS Identity
resource "azurerm_key_vault_access_policy" "aks" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.aks.principal_id

  secret_permissions = [
    "Get", "List"
  ]

  certificate_permissions = [
    "Get", "List"
  ]

  key_permissions = [
    "Get", "List"
  ]
}

# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Outputs
output "key_vault_id" {
  value = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  value = azurerm_key_vault.main.vault_uri
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.id
}

output "aks_identity_id" {
  value = azurerm_user_assigned_identity.aks.id
}

output "aks_identity_principal_id" {
  value = azurerm_user_assigned_identity.aks.principal_id
} 