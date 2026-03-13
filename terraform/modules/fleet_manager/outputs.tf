# AKS Fleet Manager Module Outputs

output "id" {
  description = "The Fleet Manager resource ID"
  value       = azurerm_fleet.main.id
}

output "name" {
  description = "The Fleet Manager name"
  value       = azurerm_fleet.main.name
}

output "location" {
  description = "The location of the Fleet Manager"
  value       = azurerm_fleet.main.location
}

output "resource_group_name" {
  description = "The resource group name of the Fleet Manager"
  value       = azurerm_fleet.main.resource_group_name
}

output "hub_fqdn" {
  description = "The FQDN of the Fleet Hub"
  value       = azurerm_fleet.main.hub_profile[0].fqdn
}

output "api_server_endpoint" {
  description = "The API server endpoint of the Fleet Hub"
  value       = azurerm_fleet.main.hub_profile[0].api_server_endpoint
}
