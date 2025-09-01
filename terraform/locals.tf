locals {
  # Resource naming
  name_prefix = "photo-${var.environment}"
  rg_name     = "${var.resource_group_name}-${var.environment}"
  aks_rg_name = "${var.resource_group_name}-${var.environment}-aks-nodes"

  # Common tags
  common_tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "Enterprise Photo Sharing Platform"
  })

  # Network configuration
  vnet_name       = "${local.name_prefix}-vnet"
  aks_subnet_name = "${local.name_prefix}-aks-subnet"
  pe_subnet_name  = "${local.name_prefix}-pe-subnet"

  # AKS configuration
  aks_name = "${local.name_prefix}-aks"
  aks_node_pools = {
    system = {
      name       = "system"
      vm_size    = "Standard_D4s_v3"
      min_count  = 3
      max_count  = 5
      node_count = 3
    }
    frontend = {
      name       = "frontend"
      vm_size    = "Standard_D4s_v3"
      min_count  = 3
      max_count  = 10
      node_count = 3
    }
    backend = {
      name       = "backend"
      vm_size    = "Standard_D8s_v3"
      min_count  = 2
      max_count  = 8
      node_count = 2
    }
  }

  # Monitoring configuration
  log_analytics_name = "${local.name_prefix}-log"
  app_insights_name  = "${local.name_prefix}-appi"
  action_group_name  = "${local.name_prefix}-ag"
} 