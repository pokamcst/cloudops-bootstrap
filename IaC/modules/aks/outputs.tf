output "cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.main.name
}

output "cluster_id" {
  description = "AKS cluster ID"
  value       = azurerm_kubernetes_cluster.main.id
}

output "kube_config" {
  description = "AKS kubeconfig"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "ingress_lb_ip" {
  description = "Load balancer IP of ingress-nginx controller (available after cluster is ready)"
  value       = null
  # Note: To get the ingress LB IP, run after cluster deployment:
  # kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
}
