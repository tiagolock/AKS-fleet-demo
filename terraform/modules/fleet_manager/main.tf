# AKS Fleet Manager Module

# AKS Fleet Manager
resource "azurerm_kubernetes_fleet_manager" "main" {
  name                = var.fleet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Fleet Member - Cluster 1 (placeholder - cluster must be registered separately)
# Note: Fleet members are registered after cluster creation using azurerm_fleet_cluster resource
# This is done in the main.tf after both AKS clusters are created
