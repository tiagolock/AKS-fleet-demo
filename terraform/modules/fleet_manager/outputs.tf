# AKS Fleet Manager Module Outputs

output "id" {
  description = "The Fleet Manager resource ID"
  value       = azurerm_kubernetes_fleet_manager.main.id
}

output "name" {
  description = "The Fleet Manager name"
  value       = azurerm_kubernetes_fleet_manager.main.name
}

output "location" {
  description = "The location of the Fleet Manager"
  value       = azurerm_kubernetes_fleet_manager.main.location
}

output "resource_group_name" {
  description = "The resource group name of the Fleet Manager"
  value       = azurerm_kubernetes_fleet_manager.main.resource_group_name
}
