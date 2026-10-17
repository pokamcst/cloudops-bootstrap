# =============================================================================
# FinOps Module - Local Values
# =============================================================================

locals {
  budget_name_prefix = "${var.project_name}-${var.environment}"

  # Budget start: first day of current month
  budget_start_date = formatdate("YYYY-MM-01'T'00:00:00Z", timestamp())

  # Budget end: 3 years from now
  budget_end_date = formatdate("YYYY-MM-01'T'00:00:00Z", timeadd(timestamp(), "26280h"))

  # Environment-specific budget multipliers
  budget_multiplier = {
    dev     = 1.0
    staging = 1.5
    prod    = 3.0
  }

  effective_budget = var.monthly_budget_amount * lookup(local.budget_multiplier, var.environment, 1.0)

  # Standard FinOps Tags
  finops_tags = {
    CostCenter     = var.cost_center
    BudgetCode     = var.budget_code != "" ? var.budget_code : var.cost_center
    Project        = var.project_name
    BusinessUnit   = var.business_unit
    Owner          = var.owner
    Environment    = var.environment
    ManagedBy      = "Terraform"
    ServiceTier    = var.service_tier
    Classification = var.classification
    CreatedBy      = "cloudops-bootstrap"
    CreatedDate    = formatdate("YYYY-MM-DD", timestamp())
    FinOpsManaged  = "true"
    TagVersion     = "2.0"
  }

  all_tags = merge(local.finops_tags, var.additional_tags)
}
