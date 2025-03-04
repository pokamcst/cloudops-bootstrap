# You can use outputs from the module
output "kube_config" {
  value     = module.aks.kube_config
  sensitive = true
}

