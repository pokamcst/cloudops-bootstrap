# main.tf in the root directory
provider "azurerm" {
  features {}
}

module "aks" {
  source              = "./modules/aks"
  name                = "cloudops-cluster"
  resource_group_name = "cloudops-rg"
  location            = "East US"
  default_node_count  = 3
  vm_size             = "Standard_DS2_v2"
}

module "monitoring" {
  source        = "./modules/monitoring"
  aks_cluster_id = module.aks.cluster_id
}
