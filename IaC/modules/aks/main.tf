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

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "vnet_subnet_id" {
  description = "Subnet ID for AKS nodes"
  type        = string
}

variable "node_resource_group" {
  description = "Resource group for AKS nodes"
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault ID for AKS secrets"
  type        = string
}

variable "user_assigned_identity_id" {
  description = "User Assigned Identity ID for AKS"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-photo-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks-photo-${var.environment}"
  kubernetes_version  = var.kubernetes_version
  tags                = var.tags

  identity {
    type = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  default_node_pool {
    name                = "system"
    node_count          = 3
    vm_size             = "Standard_D4s_v3"
    vnet_subnet_id      = var.vnet_subnet_id
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 5
    os_disk_size_gb     = 100
    type                = "VirtualMachineScaleSets"
    node_labels = {
      "nodepool-type" = "system"
    }
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    load_balancer_sku  = "standard"
    service_cidr       = "172.16.0.0/16"
    dns_service_ip     = "172.16.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  oms_agent {
    log_analytics_workspace_id = var.key_vault_id
  }

  azure_policy_enabled = true

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }
}

# Additional Node Pools
resource "azurerm_kubernetes_cluster_node_pool" "frontend" {
  name                  = "frontend"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size              = "Standard_D4s_v3"
  node_count           = 3
  vnet_subnet_id       = var.vnet_subnet_id
  enable_auto_scaling  = true
  min_count            = 3
  max_count            = 10
  os_disk_size_gb      = 100
  node_labels = {
    "nodepool-type" = "frontend"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "backend" {
  name                  = "backend"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size              = "Standard_D8s_v3"
  node_count           = 2
  vnet_subnet_id       = var.vnet_subnet_id
  enable_auto_scaling  = true
  min_count            = 2
  max_count            = 5
  os_disk_size_gb      = 100
  node_labels = {
    "nodepool-type" = "backend"
  }
}

# Kubernetes Provider
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.main.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
}

# Kubernetes Namespaces
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      "name" = "monitoring"
    }
  }
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "app"
    labels = {
      "name" = "app"
    }
  }
}

# Network Policies
resource "kubernetes_network_policy" "default_deny" {
  metadata {
    name      = "default-deny-all"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

# Outputs
output "cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "cluster_id" {
  value = azurerm_kubernetes_cluster.main.id
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive = true
}

output "ingress_lb_ip" {
  value = data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.ip
}

# Data source for Ingress Controller IP
data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
} 