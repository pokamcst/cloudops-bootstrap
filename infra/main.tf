provider "azurerm" {
  features {}
}

module "aks" {
  source             = "./modules/aks"
  cluster_name       = "cloudops-cluster"
  location          = "East US"
  resource_group     = "cloudops-rg"
  node_count         = 3
  node_size          = "Standard_DS2_v2"
  enable_monitoring  = true
}

module "monitoring" {
  source        = "./modules/monitoring"
  aks_cluster_id = module.aks.id
}
