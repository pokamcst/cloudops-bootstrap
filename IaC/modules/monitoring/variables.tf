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
