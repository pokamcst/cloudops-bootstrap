# Backend infrastructure configuration

provider "azurerm" {
  features {}
}

# Resource group for Terraform state
resource "azurerm_resource_group" "terraform_state" {
  name     = "terraform-state-rg"
  location = "eastus2"
  tags = {
    Environment = "Management"
    Project     = "Terraform State"
    ManagedBy   = "Terraform"
  }
}

# Storage account for Terraform state
resource "azurerm_storage_account" "terraform_state" {
  name                     = "terraformstateentphoto"
  resource_group_name      = azurerm_resource_group.terraform_state.name
  location                 = azurerm_resource_group.terraform_state.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version         = "TLS1_2"
  tags = {
    Environment = "Management"
    Project     = "Terraform State"
    ManagedBy   = "Terraform"
  }
}

# Container for Terraform state
resource "azurerm_storage_container" "terraform_state" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.terraform_state.name
  container_access_type = "private"
}

