resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}

# Create a separate resource group for AKS nodes
resource "azurerm_resource_group" "aks_nodes" {
  name     = local.aks_rg_name
  location = var.location
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
} 