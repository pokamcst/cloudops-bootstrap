variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "acr_sku" {
  description = "ACR SKU"
  type        = string
  default     = "Standard"
}

variable "admin_enabled" {
  description = "Enable admin access"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "Subnet IDs for private endpoints"
  type        = list(string)
}

variable "key_vault_id" {
  description = "Key Vault ID for storing credentials"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
