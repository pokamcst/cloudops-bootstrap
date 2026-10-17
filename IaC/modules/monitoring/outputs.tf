output "application_insights_id" {
  description = "Application Insights resource ID"
  value       = azurerm_application_insights.main.id
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "action_group_id" {
  description = "Critical action group ID"
  value       = azurerm_monitor_action_group.critical.id
}

output "web_test_ids" {
  description = "Web test IDs by name"
  value = {
    for k, v in azurerm_application_insights_web_test.global_availability : k => v.id
  }
}
