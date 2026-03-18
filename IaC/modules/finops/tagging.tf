# =============================================================================
# FinOps Tagging Standards Module
# =============================================================================
# Enforces consistent tagging across all Azure resources for:
# - Cost allocation and showback/chargeback
# - Resource ownership tracking
# - Lifecycle management
# - Compliance and governance
# =============================================================================

# NOTE: project_name and environment are declared in main.tf

variable "cost_center" {
  description = "Cost center code for chargeback"
  type        = string
  default     = "engineering"
}

variable "owner" {
  description = "Team or person responsible for the resources"
  type        = string
  default     = "platform-team"
}

variable "business_unit" {
  description = "Business unit that owns the resources"
  type        = string
  default     = "technology"
}

variable "classification" {
  description = "Data classification level (public, internal, confidential, restricted)"
  type        = string
  default     = "internal"

  validation {
    condition     = contains(["public", "internal", "confidential", "restricted"], var.classification)
    error_message = "Classification must be public, internal, confidential, or restricted."
  }
}

variable "additional_tags" {
  description = "Additional custom tags to merge"
  type        = map(string)
  default     = {}
}

variable "budget_code" {
  description = "Budget allocation code for financial tracking"
  type        = string
  default     = ""
}

variable "service_tier" {
  description = "Service tier for cost categorization (bronze, silver, gold, platinum)"
  type        = string
  default     = "silver"

  validation {
    condition     = contains(["bronze", "silver", "gold", "platinum"], var.service_tier)
    error_message = "Service tier must be bronze, silver, gold, or platinum."
  }
}

# =============================================================================
# Standard FinOps Tags
# =============================================================================
locals {
  # Core FinOps tags - always applied
  finops_tags = {
    # Cost Allocation
    CostCenter   = var.cost_center
    BudgetCode   = var.budget_code != "" ? var.budget_code : var.cost_center
    Project      = var.project_name
    BusinessUnit = var.business_unit

    # Ownership
    Owner       = var.owner
    Environment = var.environment

    # Operations
    ManagedBy      = "Terraform"
    ServiceTier    = var.service_tier
    Classification = var.classification

    # Lifecycle
    CreatedBy   = "cloudops-bootstrap"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())

    # FinOps Metadata
    FinOpsManaged = "true"
    TagVersion    = "2.0"
  }

  # Merged tags (FinOps + custom)
  all_tags = merge(local.finops_tags, var.additional_tags)
}

# =============================================================================
# Outputs
# =============================================================================
output "finops_tags" {
  description = "Complete FinOps-compliant tag set for resource tagging"
  value       = local.all_tags
}

output "cost_allocation_tags" {
  description = "Subset of tags for cost allocation only"
  value = {
    CostCenter   = var.cost_center
    BudgetCode   = var.budget_code != "" ? var.budget_code : var.cost_center
    Project      = var.project_name
    BusinessUnit = var.business_unit
    Environment  = var.environment
  }
}

output "ownership_tags" {
  description = "Subset of tags for ownership tracking"
  value = {
    Owner       = var.owner
    ManagedBy   = "Terraform"
    ServiceTier = var.service_tier
  }
}
