output "cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "get_credentials_command" {
  description = "Run this after apply to configure kubectl"
  value       = "az aks get-credentials --resource-group ${var.resource_group_name} --name ${var.cluster_name}"
}
