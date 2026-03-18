# =============================================================================
# FinOps Module - Azure Cost Management & Optimization
# =============================================================================
# This module implements FinOps practices including:
# - Budget alerts per resource group and subscription
# - Cost anomaly detection
# - Resource tagging enforcement via Azure Policy
# - Scheduled actions for cost reports
# - Advisor recommendations monitoring
# =============================================================================

# Variables
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

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

# =============================================================================
# Local values
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
}

# =============================================================================
# Resource Group Budget
# =============================================================================
resource "azurerm_consumption_budget_resource_group" "main" {
  name              = "${local.budget_name_prefix}-rg-budget"
  resource_group_id = var.resource_group_id

  amount     = local.effective_budget
  time_grain = "Monthly"

  time_period {
    start_date = local.budget_start_date
    end_date   = local.budget_end_date
  }

  filter {
    tag {
      name = "Environment"
      values = [var.environment]
    }
  }

  # Generate notification blocks for each threshold
  dynamic "notification" {
    for_each = toset(var.budget_alert_thresholds)
    content {
      enabled        = true
      threshold      = notification.value
      operator       = "GreaterThan"
      threshold_type = notification.value <= 100 ? "Actual" : "Forecasted"

      contact_emails = var.budget_alert_emails
    }
  }
}

# =============================================================================
# Subscription Budget (optional)
# =============================================================================
resource "azurerm_consumption_budget_subscription" "main" {
  count = var.enable_subscription_budget ? 1 : 0

  name            = "${local.budget_name_prefix}-subscription-budget"
  subscription_id = "/subscriptions/${var.subscription_id}"

  amount     = var.subscription_monthly_budget
  time_grain = "Monthly"

  time_period {
    start_date = local.budget_start_date
    end_date   = local.budget_end_date
  }

  dynamic "notification" {
    for_each = toset(var.budget_alert_thresholds)
    content {
      enabled        = true
      threshold      = notification.value
      operator       = "GreaterThan"
      threshold_type = notification.value <= 100 ? "Actual" : "Forecasted"

      contact_emails = var.budget_alert_emails
    }
  }
}

# =============================================================================
# Cost Anomaly Alert
# =============================================================================
resource "azurerm_cost_anomaly_alert" "main" {
  count = var.enable_cost_anomaly_alerts ? 1 : 0

  name            = "${local.budget_name_prefix}-anomaly-alert"
  display_name    = "${var.project_name} ${var.environment} Cost Anomaly Alert"
  subscription_id = "/subscriptions/${var.subscription_id}"
  email_subject   = "[FinOps] Cost Anomaly Detected - ${var.project_name} ${var.environment}"
  email_addresses = var.cost_anomaly_alert_emails
  message         = "A cost anomaly has been detected for project ${var.project_name} in ${var.environment} environment. Please review Azure Cost Management for details."
}

# =============================================================================
# Azure Monitor Action Group for FinOps
# =============================================================================
resource "azurerm_monitor_action_group" "finops" {
  name                = "ag-finops-${var.environment}"
  resource_group_name = var.resource_group_name
  short_name          = "finops"
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = var.budget_alert_emails
    content {
      name                    = "finops-${email_receiver.key}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }
}

# =============================================================================
# Azure Advisor Alert for Cost Recommendations
# =============================================================================
resource "azurerm_monitor_activity_log_alert" "advisor_cost" {
  count = var.enable_advisor_recommendations ? 1 : 0

  name                = "${local.budget_name_prefix}-advisor-cost-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.resource_group_id]
  description         = "Alert when Azure Advisor generates new cost optimization recommendations"
  tags                = var.tags

  criteria {
    category = "Recommendation"

    resource_type = "Microsoft.Advisor/recommendations"
  }

  action {
    action_group_id = azurerm_monitor_action_group.finops.id
  }
}

# =============================================================================
# Tagging Policy - Require mandatory tags on all resources
# =============================================================================
resource "azurerm_resource_group_policy_assignment" "require_tag" {
  for_each = var.enable_tagging_policy ? toset(var.required_tags) : toset([])

  name                 = "require-tag-${lower(replace(each.value, " ", "-"))}"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b466-ce391587003f"
  description          = "Requires the '${each.value}' tag on all resources for FinOps cost tracking"
  display_name         = "Require '${each.value}' tag"

  parameters = jsonencode({
    tagName = {
      value = each.value
    }
  })

  non_compliance_message {
    content = "Resource must have the '${each.value}' tag for cost tracking. See FinOps guide: FINOPS_CONCEPT.md"
  }
}

# =============================================================================
# Tagging Policy - Inherit tags from Resource Group
# =============================================================================
resource "azurerm_resource_group_policy_assignment" "inherit_tag" {
  for_each = var.enable_tagging_policy ? toset(["CostCenter", "Environment", "Project"]) : toset([])

  name                 = "inherit-tag-${lower(replace(each.value, " ", "-"))}"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/cd3aa116-8754-49c9-a813-ad46512ece54"
  description          = "Inherit '${each.value}' tag from resource group if not set"
  display_name         = "Inherit '${each.value}' tag from RG"

  parameters = jsonencode({
    tagName = {
      value = each.value
    }
  })

  identity {
    type = "SystemAssigned"
  }

  location = var.location
}

# =============================================================================
# Scheduled Cost Export (to Storage Account for analysis)
# =============================================================================
resource "azurerm_subscription_cost_management_export" "daily" {
  name                         = "${replace(local.budget_name_prefix, "-", "")}dailyexport"
  subscription_id              = "/subscriptions/${var.subscription_id}"
  recurrence_type              = "Daily"
  recurrence_period_start_date = local.budget_start_date
  recurrence_period_end_date   = local.budget_end_date

  export_data_storage_location {
    container_id = azurerm_storage_container.cost_exports.resource_manager_id
    root_folder_path = "cost-exports/${var.environment}"
  }

  export_data_options {
    type       = "ActualCost"
    time_frame = "MonthToDate"
  }
}

# Storage for cost exports
resource "azurerm_storage_account" "finops" {
  name                     = replace("${var.project_name}${var.environment}finops", "-", "")
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = merge(var.tags, {
    Purpose = "FinOps-CostExports"
  })
}

resource "azurerm_storage_container" "cost_exports" {
  name                  = "cost-exports"
  storage_account_name  = azurerm_storage_account.finops.name
  container_access_type = "private"
}

# =============================================================================
# Outputs
# =============================================================================
output "resource_group_budget_id" {
  description = "Resource Group budget ID"
  value       = azurerm_consumption_budget_resource_group.main.id
}

output "subscription_budget_id" {
  description = "Subscription budget ID"
  value       = var.enable_subscription_budget ? azurerm_consumption_budget_subscription.main[0].id : null
}

output "cost_anomaly_alert_id" {
  description = "Cost anomaly alert ID"
  value       = var.enable_cost_anomaly_alerts ? azurerm_cost_anomaly_alert.main[0].id : null
}

output "finops_action_group_id" {
  description = "FinOps action group ID"
  value       = azurerm_monitor_action_group.finops.id
}

output "finops_storage_account_name" {
  description = "Storage account for cost exports"
  value       = azurerm_storage_account.finops.name
}

output "effective_monthly_budget" {
  description = "Effective monthly budget after environment multiplier"
  value       = local.effective_budget
}

output "tagging_policy_assignments" {
  description = "Tag policy assignment IDs"
  value       = { for k, v in azurerm_resource_group_policy_assignment.require_tag : k => v.id }
}
