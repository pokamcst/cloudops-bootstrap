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

# Front Door Profile
resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "afd-photo-${var.environment}"
  resource_group_name = var.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"
  tags                = var.tags
}

# Front Door Endpoint
resource "azurerm_cdn_frontdoor_endpoint" "main" {
  name                     = "endpoint-photo-${var.environment}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  enabled                  = true
}

# Front Door Origin Group
resource "azurerm_cdn_frontdoor_origin_group" "main" {
  name                     = "og-photo-${var.environment}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  session_affinity_enabled = true
}

# Front Door Origins
resource "azurerm_cdn_frontdoor_origin" "main" {
  count                          = length(var.backend_pool_hosts)
  name                          = "origin-${count.index + 1}-photo-${var.environment}"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id
  enabled                       = true
  host_name                     = var.backend_pool_hosts[count.index]
  http_port                     = 80
  https_port                    = 443
  priority                      = count.index + 1
  weight                        = 1000
}

# Front Door Route
resource "azurerm_cdn_frontdoor_route" "main" {
  name                          = "route-photo-${var.environment}"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id
  cdn_frontdoor_origin_ids      = azurerm_cdn_frontdoor_origin.main[*].id
  enabled                       = true
  forwarding_protocol           = "HttpsOnly"
  https_redirect_enabled        = true
  patterns_to_match            = ["/*"]
  supported_protocols          = ["Http", "Https"]
}

# Front Door Rule Set
resource "azurerm_cdn_frontdoor_rule_set" "main" {
  name                     = "ruleset-photo-${var.environment}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
}

# Front Door Rules
resource "azurerm_cdn_frontdoor_rule" "security_headers" {
  name                      = "security-headers"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.main.id
  order                     = 1
  behavior_on_match         = "Continue"

  actions {
    url_rewrite_action {
      source_pattern          = "/"
      destination            = "/"
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

# Front Door Firewall Policy
resource "azurerm_cdn_frontdoor_firewall_policy" "main" {
  name                              = "waf-photo-${var.environment}"
  cdn_frontdoor_profile_id         = azurerm_cdn_frontdoor_profile.main.id
  enabled                          = true
  mode                             = "Prevention"
  redirect_url                     = "https://www.contoso.com"
  custom_block_response_status_code = 403
  custom_block_response_body       = "PGh0bWw+PGJvZHk+PGgxPkFjY2VzcyBEZW5pZWQ8L2gxPjxwPllvdXIgcmVxdWVzdCBoYXMgYmVlbiBibG9ja2VkLjwvcD48L2JvZHk+PC9odG1sPg=="

  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "2.1"
    action  = "Block"
  }

  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
    action  = "Block"
  }
}

# Associate Firewall Policy with Route
resource "azurerm_cdn_frontdoor_route" "main_with_waf" {
  name                          = "route-photo-${var.environment}-waf"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id
  cdn_frontdoor_origin_ids      = azurerm_cdn_frontdoor_origin.main[*].id
  enabled                       = true
  forwarding_protocol           = "HttpsOnly"
  https_redirect_enabled        = true
  patterns_to_match            = ["/*"]
  supported_protocols          = ["Http", "Https"]
  cdn_frontdoor_firewall_policy_ids = [azurerm_cdn_frontdoor_firewall_policy.main.id]
}

# Outputs
output "endpoint" {
  value = azurerm_cdn_frontdoor_endpoint.main.host_name
}

output "profile_id" {
  value = azurerm_cdn_frontdoor_profile.main.id
}

output "firewall_policy_id" {
  value = azurerm_cdn_frontdoor_firewall_policy.main.id
} 