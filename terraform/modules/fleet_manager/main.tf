# AKS Fleet Manager Module

# AKS Fleet Manager
resource "azurerm_fleet" "main" {
  name                = var.fleet_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Azure AD Integration
  azure_active_directory_configuration {
    tenant_id = var.aad_tenant_id != "" ? var.aad_tenant_id : null
  }

  # Hub API Server Access Profile
  api_server_access_profile {
    enable_hub_api_server_access = var.enable_hub_api_server_access
    
    subnet_ids = length(var.api_server_access_profile_subnet_ids) > 0 ? var.api_server_access_profile_subnet_ids : null
  }

  tags = var.tags
}

# Fleet Member - Cluster 1 (placeholder - cluster must be registered separately)
# Note: Fleet members are registered after cluster creation using azurerm_fleet_cluster resource
# This is done in the main.tf after both AKS clusters are created
