variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
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
  default     = "kustomer-rg"
}

variable "project_name" {
  description = "Project name for resource naming (e.g., 'kustomer', 'kustomerx'). Will create {project_name}-{environment}-rg"
  type        = string
  default     = "kustomer"
  
  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 20
    error_message = "Project name must be 1-20 characters."
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "Kustomer"
    Owner       = "Platform Team"
    CostCenter  = "Engineering"
    ManagedBy   = "Terraform"
  }
}

# Networking Variables
variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "enable_private_endpoints" {
  description = "Enable private endpoints for secure access"
  type        = bool
  default     = true
}

# AKS Variables
variable "kubernetes_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = "1.27.3"
}

variable "aks_node_count" {
  description = "Initial number of AKS nodes"
  type        = number
  default     = 3

  validation {
    condition     = var.aks_node_count >= 1 && var.aks_node_count <= 20
    error_message = "Node count must be between 1 and 20."
  }
}

variable "aks_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "aks_enable_auto_scaling" {
  description = "Enable autoscaling for AKS node pools"
  type        = bool
  default     = true
}

variable "aks_min_node_count" {
  description = "Minimum number of nodes for autoscaling"
  type        = number
  default     = 2
}

variable "aks_max_node_count" {
  description = "Maximum number of nodes for autoscaling"
  type        = number
  default     = 10
}

# ACR Variables
variable "acr_sku" {
  description = "SKU for Azure Container Registry"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "ACR SKU must be Basic, Standard, or Premium."
  }
}

variable "acr_admin_enabled" {
  description = "Enable admin access to ACR"
  type        = bool
  default     = false
}

variable "acr_public_network_access_enabled" {
  description = "Enable public network access to ACR (only supported with Premium SKU)"
  type        = bool
  default     = true
}

# Monitoring Variables
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for resources"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Log retention days"
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days >= 0 && var.log_retention_days <= 365
    error_message = "Log retention must be between 0 and 365 days."
  }
}

# Storage Variables
variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage tier must be Standard or Premium."
  }
}

variable "storage_replication_type" {
  description = "Storage replication type"
  type        = string
  default     = "GRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS"], var.storage_replication_type)
    error_message = "Replication type must be LRS, GRS, RAGRS, or ZRS."
  }
}

# Database Variables
variable "cosmos_db_throughput" {
  description = "Cosmos DB provisioned throughput"
  type        = number
  default     = 400

  validation {
    condition     = var.cosmos_db_throughput >= 400 && var.cosmos_db_throughput <= 1000000
    error_message = "Throughput must be between 400 and 1000000."
  }
}

variable "enable_cosmos_autoscale" {
  description = "Enable autoscale for Cosmos DB"
  type        = bool
  default     = true
}

variable "postgres_sku_name" {
  description = "PostgreSQL server SKU name"
  type        = string
  default     = "B_Standard_B2s"
}

variable "postgres_storage_mb" {
  description = "PostgreSQL storage in MB"
  type        = number
  default     = 32768
}

# =============================================================================
# FinOps Variables
# =============================================================================

variable "finops_monthly_budget" {
  description = "Monthly budget amount per resource group (in budget currency)"
  type        = number
  default     = 1000

  validation {
    condition     = var.finops_monthly_budget > 0
    error_message = "Monthly budget must be greater than 0."
  }
}

variable "finops_budget_currency" {
  description = "Budget currency (ISO 4217 code)"
  type        = string
  default     = "EUR"
}

variable "finops_alert_thresholds" {
  description = "Budget alert thresholds in percent. Thresholds >100 use forecasted cost."
  type        = list(number)
  default     = [50, 75, 90, 100, 110]
}

variable "finops_alert_emails" {
  description = "Email addresses for FinOps budget and anomaly alerts"
  type        = list(string)
  default     = ["finops@example.com"]
}

variable "finops_enable_subscription_budget" {
  description = "Enable subscription-level budget monitoring"
  type        = bool
  default     = true
}

variable "finops_subscription_budget" {
  description = "Monthly budget for the entire Azure subscription"
  type        = number
  default     = 5000
}

variable "finops_enable_tagging_policy" {
  description = "Enable Azure Policy to enforce mandatory cost tags"
  type        = bool
  default     = true
}

variable "finops_required_tags" {
  description = "Tags required on all resources for cost tracking"
  type        = list(string)
  default     = ["Environment", "CostCenter", "Owner", "Project", "ManagedBy"]
}

variable "finops_enable_anomaly_alerts" {
  description = "Enable Azure Cost Anomaly Detection"
  type        = bool
  default     = true
}

variable "finops_enable_advisor_alerts" {
  description = "Enable alerts for Azure Advisor cost recommendations"
  type        = bool
  default     = true
}
