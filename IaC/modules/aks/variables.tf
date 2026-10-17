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

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for AKS monitoring"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
