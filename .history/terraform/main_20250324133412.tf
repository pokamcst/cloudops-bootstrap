provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terraformstateentphoto"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

# Variables
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  default     = "prod"
}

variable "location" {
  description = "Azure region for resources"
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "photo-sharing-platform-rg"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Project     = "Enterprise Photo Sharing Platform"
    Owner       = "IT Operations"
    CostCenter  = "IT-100"
  }
}

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
  address_space       = ["10.0.0.0/16"]
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
  source                = "./modules/aks"
  resource_group_name   = azurerm_resource_group.main.name
  location              = var.location
  environment           = var.environment
  kubernetes_version    = "1.27.3"
  vnet_subnet_id        = module.networking.aks_subnet_id
  node_resource_group   = "${var.resource_group_name}-${var.environment}-aks-nodes"
  key_vault_id          = module.security.key_vault_id
  user_assigned_identity_id = module.security.aks_identity_id
  tags                  = var.tags
  depends_on            = [module.networking, module.security]
}

module "front_door" {
  source              = "./modules/front_door"
  resource_group_name = azurerm_resource_group.main.name
  environment         = var.environment
  backend_pool_hosts  = [module.aks.ingress_lb_ip]
  tags                = var.tags
  depends_on          = [module.aks]
}

module "storage" {
  source              = "./modules/storage"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  subnet_ids          = module.networking.subnet_ids
  private_endpoint_subnet_id = module.networking.pe_subnet_id
  tags                = var.tags
}

module "databases" {
  source              = "./modules/databases"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  subnet_ids          = module.networking.subnet_ids
  private_endpoint_subnet_id = module.networking.pe_subnet_id
  tags                = var.tags
}

module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  aks_cluster_id      = module.aks.cluster_id
  workspace_id        = module.security.log_analytics_workspace_id
  tags                = var.tags
  depends_on          = [module.aks]
}

# Outputs
output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "aks_kube_config" {
  value     = module.aks.kube_config
  sensitive = true
}

output "front_door_endpoint" {
  value = module.front_door.endpoint
}

output "cosmos_db_endpoint" {
  value = module.databases.cosmos_db_endpoint
}

output "blob_storage_primary_endpoint" {
  value = module.storage.blob_storage_primary_endpoint
} 