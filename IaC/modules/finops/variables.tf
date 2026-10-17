# =============================================================================
# FinOps Module - Variables
# =============================================================================

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "resource_group_id" {
  description = "ID of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

# Budget Configuration
variable "monthly_budget_amount" {
  description = "Monthly budget amount in the subscription currency (e.g., EUR or USD)"
  type        = number
  default     = 1000
}

variable "budget_currency" {
  description = "Currency for budget (ISO 4217 code)"
  type        = string
  default     = "EUR"
}

variable "budget_alert_thresholds" {
  description = "List of budget alert thresholds in percentage (0-100)"
  type        = list(number)
  default     = [50, 75, 90, 100, 110]
}

variable "budget_alert_emails" {
  description = "Email addresses for budget alerts"
  type        = list(string)
  default     = ["finops@example.com"]
}

variable "cost_anomaly_alert_emails" {
  description = "Email addresses for cost anomaly alerts"
  type        = list(string)
  default     = ["finops@example.com"]
}

variable "enable_subscription_budget" {
  description = "Enable subscription-level budget"
  type        = bool
  default     = true
}

variable "subscription_monthly_budget" {
  description = "Monthly budget for the entire subscription"
  type        = number
  default     = 5000
}

variable "enable_tagging_policy" {
  description = "Enable Azure Policy for mandatory tagging"
  type        = bool
  default     = true
}

variable "required_tags" {
  description = "List of tags that must be present on all resources"
  type        = list(string)
  default     = ["Environment", "CostCenter", "Owner", "Project", "ManagedBy"]
}

variable "enable_cost_anomaly_alerts" {
  description = "Enable cost anomaly detection alerts"
  type        = bool
  default     = true
}

variable "enable_advisor_recommendations" {
  description = "Enable Azure Advisor cost recommendations monitoring"
  type        = bool
  default     = true
}

variable "cost_report_schedule" {
  description = "Cron expression for scheduled cost reports (weekly default)"
  type        = string
  default     = "0 8 * * 1" # Every Monday at 8:00 AM
}

# Tagging Variables
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
