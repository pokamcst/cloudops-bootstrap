variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
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
    ManagedBy   = "Terraform"
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS cluster"
  type        = string
  default     = "1.27.3"
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "enable_private_endpoints" {
  description = "Enable private endpoints for Azure services"
  type        = bool
  default     = true
}

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for resources"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

# AKS-specific variables not defined in main.tf

variable "node_pool_configs" {
  description = "Configuration for AKS node pools"
  type = map(object({
    name       = string
    vm_size    = string
    node_count = number
    min_count  = optional(number, null)
    max_count  = optional(number, null)
  }))
  default = {
    system = {
      name       = "system"
      vm_size    = "Standard_D2s_v3"
      node_count = 1
      min_count  = 1
      max_count  = 3
    }
    user = {
      name       = "user"
      vm_size    = "Standard_D4s_v3"
      node_count = 1
      min_count  = 1
      max_count  = 5
    }
  }
}

variable "enable_auto_scaling" {
  description = "Enable auto-scaling for AKS node pools"
  type        = bool
  default     = true
}

variable "enable_host_encryption" {
  description = "Enable host encryption for AKS node pools"
  type        = bool
  default     = true
}

variable "enable_node_public_ip" {
  description = "Enable public IP for AKS nodes"
  type        = bool
  default     = false
}

variable "network_policy" {
  description = "Network policy for AKS cluster"
  type        = string
  default     = "azure"
}

variable "outbound_type" {
  description = "Outbound type for AKS cluster"
  type        = string
  default     = "loadBalancer"
}

variable "private_cluster_enabled" {
  description = "Enable private cluster for AKS"
  type        = bool
  default     = true
}

variable "sku_tier" {
  description = "SKU tier for AKS cluster"
  type        = string
  default     = "Free"
} 