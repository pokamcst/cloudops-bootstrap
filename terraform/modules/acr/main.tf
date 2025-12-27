locals {
  acr_name = replace("${var.environment}kustomeracr", "-", "")
}

resource "azurerm_container_registry" "main" {
  name                = local.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = var.admin_enabled
  
  public_network_access_enabled = var.public_network_access_enabled
  
  tags = var.tags
}

# Private endpoint for ACR if configured
resource "azurerm_private_endpoint" "acr" {
  count               = var.public_network_access_enabled ? 0 : 1
  name                = "pe-${azurerm_container_registry.main.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_ids[0]

  private_service_connection {
    name                           = "psc-${azurerm_container_registry.main.name}"
    private_connection_resource_id = azurerm_container_registry.main.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  tags = var.tags
}

# Store ACR credentials in Key Vault
resource "azurerm_key_vault_secret" "acr_username" {
  name         = "acr-admin-username"
  value        = var.admin_enabled ? azurerm_container_registry.main.admin_username : ""
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "acr_password" {
  name         = "acr-admin-password"
  value        = var.admin_enabled ? azurerm_container_registry.main.admin_password : ""
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "acr_password2" {
  name         = "acr-admin-password2"
  value        = var.admin_enabled ? azurerm_container_registry.main.admin_password : ""
  key_vault_id = var.key_vault_id
}
