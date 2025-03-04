# modules/aks/variables.tf
variable "name" {
  description = "The name of the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region to deploy the resources"
  type        = string
}

variable "default_node_count" {
  description = "The default number of nodes in the node pool"
  type        = number
  default     = 3
}

variable "vm_size" {
  description = "The size of the VMs in the node pool"
  type        = string
  default     = "Standard_DS2_v2"
}