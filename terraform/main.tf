
# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.resource_group_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}

# Call modules
module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  address_space       = var.address_space
  tags                = var.tags
}

module "security" {
  source              = "./modules/security"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  virtual_network_id  = module.networking.vnet_id
  subnet_ids          = module.networking.subnet_ids
  tags                = var.tags
}

module "aks" {
  source                    = "./modules/aks"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = var.location
  environment               = var.environment
  kubernetes_version        = var.kubernetes_version
  vnet_subnet_id            = module.networking.aks_subnet_id
  node_resource_group       = "${var.resource_group_name}-${var.environment}-aks-nodes"
  key_vault_id              = module.security.key_vault_id
  user_assigned_identity_id = module.security.aks_identity_id
  tags                      = var.tags
}

module "front_door" {
  source              = "./modules/front_door"
  resource_group_name = azurerm_resource_group.main.name
  environment         = var.environment
  backend_pool_hosts  = [module.aks.ingress_lb_ip]
  tags                = var.tags
}

module "storage" {
  source                     = "./modules/storage"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = var.location
  environment                = var.environment
  subnet_ids                 = module.networking.subnet_ids
  private_endpoint_subnet_id = module.networking.pe_subnet_id
  tags                       = var.tags
}

module "databases" {
  source                     = "./modules/databases"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = var.location
  environment                = var.environment
  subnet_ids                 = module.networking.subnet_ids
  private_endpoint_subnet_id = module.networking.pe_subnet_id
  tags                       = var.tags
}

module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  aks_cluster_id      = module.aks.cluster_id
  workspace_id        = module.security.log_analytics_workspace_id
  tags                = var.tags
}