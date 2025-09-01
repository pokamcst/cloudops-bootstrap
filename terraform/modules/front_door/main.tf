# Variables
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "backend_pool_hosts" {
  description = "List of backend pool hosts"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

# Azure Front Door configuration

resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "${var.resource_group_name}-${var.environment}-frontdoor"
  resource_group_name = var.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_endpoint" "main" {
  name                     = "${var.resource_group_name}-${var.environment}-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  enabled                  = true
}

resource "azurerm_cdn_frontdoor_origin_group" "main" {
  name                     = "${var.resource_group_name}-${var.environment}-origingroup"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  session_affinity_enabled = true

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
    additional_latency_in_ms    = 0
  }
}

resource "azurerm_cdn_frontdoor_origin" "main" {
  name                          = "${var.resource_group_name}-${var.environment}-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id
  enabled                       = true
  host_name                     = var.backend_pool_hosts[0]
  http_port                     = 80
  https_port                    = 443
  origin_host_header            = var.backend_pool_hosts[0]
  priority                      = 1
  weight                        = 1000
}

resource "azurerm_cdn_frontdoor_route" "main" {
  name                          = "${var.resource_group_name}-${var.environment}-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.main.id]
  enabled                       = true
  forwarding_protocol           = "HttpsOnly"
  https_redirect_enabled        = true
  patterns_to_match            = ["/*"]
  supported_protocols          = ["Http", "Https"]
}

resource "azurerm_cdn_frontdoor_rule_set" "main" {
  name                     = "${var.resource_group_name}-${var.environment}-ruleset"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
}

resource "azurerm_cdn_frontdoor_rule" "security_headers" {
  name                      = "${var.resource_group_name}-${var.environment}-securityheaders"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.main.id
  order                     = 1
  behavior_on_match         = "Continue"

  actions {
    url_rewrite_action {
      source_pattern          = "/"
      destination            = "/index.html"
      preserve_unmatched_path = true
    }

    response_header_action {
      header_action = "Append"
      header_name   = "X-Frame-Options"
      value         = "DENY"
    }

    response_header_action {
      header_action = "Append"
      header_name   = "X-Content-Type-Options"
      value         = "nosniff"
    }

    response_header_action {
      header_action = "Append"
      header_name   = "X-XSS-Protection"
      value         = "1; mode=block"
    }

    response_header_action {
      header_action = "Append"
      header_name   = "Strict-Transport-Security"
      value         = "max-age=31536000; includeSubDomains"
    }
  }
}

resource "azurerm_cdn_frontdoor_firewall_policy" "main" {
  name                = "${var.resource_group_name}-${var.environment}-waf"
  resource_group_name = var.resource_group_name
  sku_name            = azurerm_cdn_frontdoor_profile.main.sku_name

  custom_rule {
    name                           = "BlockIPRange"
    enabled                        = true
    priority                       = 1
    rate_limit_duration_in_minutes = 1
    rate_limit_threshold          = 10
    type                          = "IPMatch"
    action                        = "Block"

    match_condition {
      match_variable     = "RemoteAddr"
      operator          = "IPMatch"
      negation_condition = false
      match_values      = ["192.168.1.0/24", "10.0.0.0/24"]
      transforms        = ["Lowercase", "Trim", "UrlDecode"]
    }
  }

  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "2.1"
    action  = "Block"
  }
}

# Outputs
output "front_door_id" {
  description = "The ID of the Front Door profile"
  value       = azurerm_cdn_frontdoor_profile.main.id
}

output "front_door_name" {
  description = "The name of the Front Door profile"
  value       = azurerm_cdn_frontdoor_profile.main.name
}

output "front_door_endpoint" {
  description = "The endpoint of the Front Door"
  value       = azurerm_cdn_frontdoor_endpoint.main.host_name
} 