# modules/aks/main.tf
resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "${var.name}-dns"

  default_node_pool {
    name       = "default"
    node_count = var.default_node_count
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }
}