provider "azurerm" {
  features {}
}

module "aks" {
  source = "./modules/aks" # Adjust this path to match your module location

  # Use the correct variable names as defined in the module
  # For example, instead of 'cluster_name', the module might expect 'name'
  name               = "cloudops-cluster"
  resource_group_name = "cloudops-rg"  # Not 'resource_group'
  location           = "East US"
  default_node_count = 3  # Not 'node_count'
  vm_size            = "Standard_DS2_v2"  # Not 'node_size'
  # ... other variables
}

module "monitoring" {
  source        = "./modules/monitoring"
  aks_cluster_id = module.aks.id
}
