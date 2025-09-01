# Variables
variable "resource_group_name" {
  description = "Name of the resource group"
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

variable "aks_cluster_id" {
  description = "AKS cluster ID"
  type        = string
}

variable "workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "${var.resource_group_name}-${var.environment}-appinsights"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = var.workspace_id
  tags                = var.tags
}

# Action Group for Alerts
resource "azurerm_monitor_action_group" "main" {
  name                = "${var.resource_group_name}-${var.environment}-actiongroup"
  resource_group_name = var.resource_group_name
  short_name          = "error-alert"
  enabled             = true

  email_receiver {
    name          = "admin"
    email_address = "admin@example.com"
  }
}

# Alert Rules
resource "azurerm_monitor_metric_alert" "error_rate" {
  name                = "${var.resource_group_name}-${var.environment}-error-rate"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when error rate exceeds threshold"
  severity            = 1
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/Components"
    metric_name      = "exceptions/count"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "diag-aks-${var.environment}"
  target_resource_id         = var.aks_cluster_id
  log_analytics_workspace_id = var.workspace_id
  
  enabled_log {
    category = "kube-audit"
    retention_policy {
      enabled = true
      days    = 30
    }
  }
  
  enabled_log {
    category = "kube-audit-admin"
    retention_policy {
      enabled = true
      days    = 30
    }
  }
  
  enabled_log {
    category = "guard"
    retention_policy {
      enabled = true
      days    = 30
    }
  }
  
  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 30
    }
  }
}

# Web Test for Availability Monitoring
resource "azurerm_application_insights_web_test" "global_availability" {
  for_each = {
    "us"      = "US West Home Page"
    "europe"  = "Europe Home Page"
    "asia"    = "Asia Home Page"
    "upload"  = "Photo Upload Flow"
    "gallery" = "Gallery Browse Flow"
    "api"     = "API Health Check"
  }

  name                    = "webtest-photo-${each.key}-${var.environment}"
  location                = var.location
  resource_group_name     = var.resource_group_name
  application_insights_id = azurerm_application_insights.main.id
  kind                    = each.key == "api" ? "ping" : "standard"
  frequency               = 300
  timeout                 = 30
  enabled                 = true
  geo_locations           = ["us-tx-sn1-azr", "us-il-ch1-azr", "emea-gb-db3-azr", "apac-hk-hkn-azr", "emea-fr-pra-edge"]
  retry_enabled           = true
  tags                    = var.tags
  configuration          = each.key == "api" ? file("${path.module}/web_test_api.xml") : file("${path.module}/web_test_default.xml")
}

# Outputs
output "application_insights_id" {
  description = "The ID of the Application Insights instance"
  value       = azurerm_application_insights.main.id
}

output "application_insights_name" {
  description = "The name of the Application Insights instance"
  value       = azurerm_application_insights.main.name
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key for Application Insights"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "action_group_id" {
  value = azurerm_monitor_action_group.main.id
}

output "web_test_ids" {
  value = {
    for k, v in azurerm_application_insights_web_test.global_availability : k => v.id
  }
} 