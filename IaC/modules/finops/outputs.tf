# =============================================================================
# FinOps Module - Outputs
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
