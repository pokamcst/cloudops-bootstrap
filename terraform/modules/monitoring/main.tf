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
  name                = "appi-photo-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = var.workspace_id
  tags                = var.tags
  
  sampling_percentage = 100
  retention_in_days   = 90
}

# Action Group for Alerts
resource "azurerm_monitor_action_group" "critical" {
  name                = "ag-critical-${var.environment}"
  resource_group_name = var.resource_group_name
  short_name          = "critical"
  tags                = var.tags

  email_receiver {
    name                    = "ops-team"
    email_address           = "ops-team@example.com"
    use_common_alert_schema = true
  }

  sms_receiver {
    name         = "oncall"
    country_code = "1"  # US
    phone_number = "5551234567"
  }

  webhook_receiver {
    name                    = "ServiceNow"
    service_uri             = "https://servicenow.example.com/api/incidents"
    use_common_alert_schema = true
  }
}

# Alert Rules
resource "azurerm_monitor_metric_alert" "aks_node_cpu" {
  name                = "alert-aks-node-cpu-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [var.aks_cluster_id]
  description         = "Alert when AKS node CPU usage is high"
  severity            = 2
  enabled             = true
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_cpu_usage_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }
}

resource "azurerm_monitor_metric_alert" "aks_node_memory" {
  name                = "alert-aks-node-memory-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [var.aks_cluster_id]
  description         = "Alert when AKS node memory usage is high"
  severity            = 2
  enabled             = true
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_memory_working_set_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }
}

# Log Analytics Query Alerts - Note: azurerm_monitor_log_alert is not a valid resource type
# Use azurerm_monitor_scheduled_query_rules_alert instead for scheduled query rules
# Placeholder for future implementation
# resource "azurerm_monitor_log_alert" "error_rate" {
#   name                = "alert-error-rate-${var.environment}"
#   resource_group_name = var.resource_group_name
#   scopes              = [var.workspace_id]
#   description         = "Alert when error rate is high"
#   severity            = 2
#   enabled             = true
#   tags                = var.tags
# }

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
  value = azurerm_application_insights.main.id
}

output "application_insights_instrumentation_key" {
  value     = azurerm_application_insights.main.instrumentation_key
  sensitive = true
}

output "action_group_id" {
  value = azurerm_monitor_action_group.critical.id
}

output "web_test_ids" {
  value = {
    for k, v in azurerm_application_insights_web_test.global_availability : k => v.id
  }
} 