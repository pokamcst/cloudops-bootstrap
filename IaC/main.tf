# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${local.resource_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

# Node resource group for AKS
resource "azurerm_resource_group" "aks_nodes" {
  name     = "${local.resource_prefix}-aks-nodes-rg"
  location = var.location
  tags     = local.common_tags
}

# Module Calls
module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  address_space       = var.address_space
  tags                = local.common_tags
}

module "security" {
  source              = "./modules/security"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  virtual_network_id  = module.networking.vnet_id
  subnet_ids          = module.networking.subnet_ids
  tags                = local.common_tags
}

module "acr" {
  source              = "./modules/acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  acr_sku             = var.acr_sku
  admin_enabled       = var.acr_admin_enabled
  public_network_access_enabled = var.acr_public_network_access_enabled
  subnet_ids          = [module.networking.aks_subnet_id]
  key_vault_id        = module.security.key_vault_id
  tags                = local.common_tags
}

module "aks" {
  source              = "./modules/aks"
  resource_group_name = azurerm_resource_group.main.name
  node_resource_group = azurerm_resource_group.aks_nodes.name
  location            = var.location
  environment         = var.environment
  kubernetes_version  = var.kubernetes_version
  vnet_subnet_id      = module.networking.aks_subnet_id
  key_vault_id        = module.security.key_vault_id
  log_analytics_workspace_id = module.security.log_analytics_workspace_id
  user_assigned_identity_id = module.security.aks_identity_id
  tags                = local.common_tags
}

module "storage" {
  source                     = "./modules/storage"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = var.location
  environment                = var.environment
  subnet_ids                 = module.networking.subnet_ids
  private_endpoint_subnet_id = module.networking.aks_subnet_id
  vnet_id                    = module.networking.vnet_id
  tags                       = local.common_tags
}

module "databases" {
  source                     = "./modules/databases"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = var.location
  environment                = var.environment
  subnet_ids                 = module.networking.subnet_ids
  private_endpoint_subnet_id = module.networking.aks_subnet_id
  vnet_id                    = module.networking.vnet_id
  tags                       = local.common_tags
}

module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  aks_cluster_id      = module.aks.cluster_id
  workspace_id        = module.security.log_analytics_workspace_id
  tags                = local.common_tags
}

# FinOps - Cost Management & Optimization
module "finops" {
  source              = "./modules/finops"
  resource_group_name = azurerm_resource_group.main.name
  resource_group_id   = azurerm_resource_group.main.id
  location            = var.location
  environment         = var.environment
  project_name        = var.project_name
  subscription_id     = data.azurerm_subscription.current.subscription_id
  tags                = local.common_tags

  # Budget Configuration
  monthly_budget_amount       = var.finops_monthly_budget
  budget_currency             = var.finops_budget_currency
  budget_alert_thresholds     = var.finops_alert_thresholds
  budget_alert_emails         = var.finops_alert_emails
  cost_anomaly_alert_emails   = var.finops_alert_emails

  # Feature Toggles
  enable_subscription_budget    = var.finops_enable_subscription_budget
  subscription_monthly_budget   = var.finops_subscription_budget
  enable_tagging_policy         = var.finops_enable_tagging_policy
  enable_cost_anomaly_alerts    = var.finops_enable_anomaly_alerts
  enable_advisor_recommendations = var.finops_enable_advisor_alerts
  required_tags                 = var.finops_required_tags
}

data "azurerm_subscription" "current" {}
