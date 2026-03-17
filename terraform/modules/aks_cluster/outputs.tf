# AKS Cluster Module Outputs

output "id" {
  description = "The AKS cluster resource ID"
  value       = azurerm_kubernetes_cluster.main.id
}

output "name" {
  description = "The AKS cluster name"
  value       = azurerm_kubernetes_cluster.main.name
}

output "kube_config" {
  description = "The cluster kubeconfig content"
  value       = azurerm_kubernetes_cluster.main.kube_config
  sensitive   = true
}

output "kube_config_raw" {
  description = "The raw cluster kubeconfig content"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "node_resource_group" {
  description = "The auto-generated node resource group name"
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}

output "client_certificate" {
  description = "Client certificate used to authenticate to the cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config[0].client_certificate
  sensitive   = true
}

output "host" {
  description = "The Kubernetes cluster server host"
  value       = azurerm_kubernetes_cluster.main.kube_config[0].host
}

output "username" {
  description = "The username to use for the cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config[0].username
}

output "password" {
  description = "The password to use for the cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config[0].password
  sensitive   = true
}

output "fqdn" {
  description = "The FQDN of the cluster"
  value       = azurerm_kubernetes_cluster.main.fqdn
}

output "portal_fqdn" {
  description = "The Portal FQDN of the cluster"
  value       = azurerm_kubernetes_cluster.main.portal_fqdn
}

output "identity" {
  description = "The identity block of the cluster"
  value       = azurerm_kubernetes_cluster.main.identity
}

output "location" {
  description = "The location of the cluster"
  value       = azurerm_kubernetes_cluster.main.location
}

output "kubernetes_version" {
  description = "The Kubernetes version of the cluster"
  value       = azurerm_kubernetes_cluster.main.kubernetes_version
}
