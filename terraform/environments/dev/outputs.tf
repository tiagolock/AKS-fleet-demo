# Terraform Outputs for AKS Fleet Demo

# ============================================
# Resource Group Outputs
# ============================================

output "cluster_1_resource_group_name" {
  description = "Name of the resource group for cluster 1"
  value       = azurerm_resource_group.cluster_1.name
}

output "cluster_1_resource_group_id" {
  description = "ID of the resource group for cluster 1"
  value       = azurerm_resource_group.cluster_1.id
}

output "cluster_1_resource_group_location" {
  description = "Location of the resource group for cluster 1"
  value       = azurerm_resource_group.cluster_1.location
}

output "cluster_2_resource_group_name" {
  description = "Name of the resource group for cluster 2"
  value       = azurerm_resource_group.cluster_2.name
}

output "cluster_2_resource_group_id" {
  description = "ID of the resource group for cluster 2"
  value       = azurerm_resource_group.cluster_2.id
}

output "cluster_2_resource_group_location" {
  description = "Location of the resource group for cluster 2"
  value       = azurerm_resource_group.cluster_2.location
}

output "fleet_resource_group_name" {
  description = "Name of the resource group for Fleet Manager"
  value       = azurerm_resource_group.fleet.name
}

output "fleet_resource_group_id" {
  description = "ID of the resource group for Fleet Manager"
  value       = azurerm_resource_group.fleet.id
}

output "fleet_resource_group_location" {
  description = "Location of the resource group for Fleet Manager"
  value       = azurerm_resource_group.fleet.location
}

# ============================================
# Virtual Network Outputs
# ============================================

output "cluster_1_virtual_network_name" {
  description = "Name of the virtual network for cluster 1"
  value       = azurerm_virtual_network.cluster_1.name
}

output "cluster_1_virtual_network_id" {
  description = "ID of the virtual network for cluster 1"
  value       = azurerm_virtual_network.cluster_1.id
}

output "cluster_1_subnet_id" {
  description = "ID of the subnet for cluster 1"
  value       = azurerm_subnet.cluster_1.id
}

output "cluster_2_virtual_network_name" {
  description = "Name of the virtual network for cluster 2"
  value       = azurerm_virtual_network.cluster_2.name
}

output "cluster_2_virtual_network_id" {
  description = "ID of the virtual network for cluster 2"
  value       = azurerm_virtual_network.cluster_2.id
}

output "cluster_2_subnet_id" {
  description = "ID of the subnet for cluster 2"
  value       = azurerm_subnet.cluster_2.id
}

# ============================================
# AKS Cluster 1 Outputs
# ============================================

output "aks_cluster_1_id" {
  description = "ID of the AKS cluster 1"
  value       = module.aks_cluster_1.id
}

output "aks_cluster_1_name" {
  description = "Name of the AKS cluster 1"
  value       = module.aks_cluster_1.name
}

output "aks_cluster_1_location" {
  description = "Location of the AKS cluster 1"
  value       = module.aks_cluster_1.location
}

output "aks_cluster_1_fqdn" {
  description = "FQDN of the AKS cluster 1"
  value       = module.aks_cluster_1.fqdn
}

output "aks_cluster_1_kubeconfig" {
  description = "Kubeconfig for AKS cluster 1"
  value       = module.aks_cluster_1.kube_config_raw
  sensitive   = true
}

output "aks_cluster_1_node_resource_group" {
  description = "Node resource group of AKS cluster 1"
  value       = module.aks_cluster_1.node_resource_group
}

# ============================================
# AKS Cluster 2 Outputs
# ============================================

output "aks_cluster_2_id" {
  description = "ID of the AKS cluster 2"
  value       = module.aks_cluster_2.id
}

output "aks_cluster_2_name" {
  description = "Name of the AKS cluster 2"
  value       = module.aks_cluster_2.name
}

output "aks_cluster_2_location" {
  description = "Location of the AKS cluster 2"
  value       = module.aks_cluster_2.location
}

output "aks_cluster_2_fqdn" {
  description = "FQDN of the AKS cluster 2"
  value       = module.aks_cluster_2.fqdn
}

output "aks_cluster_2_kubeconfig" {
  description = "Kubeconfig for AKS cluster 2"
  value       = module.aks_cluster_2.kube_config_raw
  sensitive   = true
}

output "aks_cluster_2_node_resource_group" {
  description = "Node resource group of AKS cluster 2"
  value       = module.aks_cluster_2.node_resource_group
}

# ============================================
# AKS Fleet Manager Outputs
# ============================================

output "fleet_manager_id" {
  description = "ID of the AKS Fleet Manager"
  value       = module.fleet_manager.id
}

output "fleet_manager_name" {
  description = "Name of the AKS Fleet Manager"
  value       = module.fleet_manager.name
}

output "fleet_manager_location" {
  description = "Location of the AKS Fleet Manager"
  value       = module.fleet_manager.location
}

output "fleet_manager_hub_fqdn" {
  description = "FQDN of the Fleet Hub"
  value       = module.fleet_manager.hub_fqdn
}

output "fleet_manager_api_server_endpoint" {
  description = "API server endpoint of the Fleet Hub"
  value       = module.fleet_manager.api_server_endpoint
}

# ============================================
# Fleet Member Outputs
# ============================================

output "fleet_cluster_1_id" {
  description = "ID of Fleet member cluster 1"
  value       = azurerm_fleet_cluster.cluster_1.id
}

output "fleet_cluster_2_id" {
  description = "ID of Fleet member cluster 2"
  value       = azurerm_fleet_cluster.cluster_2.id
}

# ============================================
# Connection Information
# ============================================

output "connection_instructions" {
  description = "Instructions for connecting to the clusters"
  value       = <<-EOT
    # Get credentials for Cluster 1 (${module.aks_cluster_1.location}):
    az aks get-credentials --name ${module.aks_cluster_1.name} --resource-group ${azurerm_resource_group.cluster_1.name}

    # Get credentials for Cluster 2 (${module.aks_cluster_2.location}):
    az aks get-credentials --name ${module.aks_cluster_2.name} --resource-group ${azurerm_resource_group.cluster_2.name}

    # View cluster info:
    kubectl cluster-info

    # List nodes:
    kubectl get nodes -A
  EOT
}

# ============================================
# Deployment Summary
# ============================================

output "deployment_summary" {
  description = "Summary of the deployment"
  value       = <<-EOT
    AKS Fleet Deployment Summary:
    ------------------------------
    Cluster 1: ${module.aks_cluster_1.name}
      - Location: ${azurerm_resource_group.cluster_1.location}
      - Resource Group: ${azurerm_resource_group.cluster_1.name}
      - Version: ${var.aks_cluster_1.kubernetes_version}

    Cluster 2: ${module.aks_cluster_2.name}
      - Location: ${azurerm_resource_group.cluster_2.location}
      - Resource Group: ${azurerm_resource_group.cluster_2.name}
      - Version: ${var.aks_cluster_2.kubernetes_version}

    Fleet Manager: ${module.fleet_manager.name}
      - Location: ${azurerm_resource_group.fleet.location}
      - Hub FQDN: ${module.fleet_manager.hub_fqdn}
  EOT
}
