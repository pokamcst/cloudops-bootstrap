# =============================================================================
# FinOps Module - Resources
# =============================================================================
# Budget alerts, cost anomaly detection, tagging policies, cost exports
# =============================================================================

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
      name   = "Environment"
      values = [var.environment]
    }
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
    category      = "Recommendation"
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
    container_id     = azurerm_storage_container.cost_exports.resource_manager_id
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
