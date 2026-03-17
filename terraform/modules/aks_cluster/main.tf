# AKS Cluster Module

# Random ID for cluster identity
resource "random_id" "cluster" {
  byte_length = 8
}

# Azure AD Application for cluster (if RBAC enabled)
resource "azuread_application" "aks_cluster" {
  count           = var.rbac_enabled ? 1 : 0
  display_name    = var.cluster_name
  identifier_uris = ["api://${var.cluster_name}"]
  optional_claims {
    access_token {
      name = "groups"
    }
  }
}

# Service Principal for AKS cluster
resource "azuread_service_principal" "aks_cluster" {
  count     = var.rbac_enabled ? 1 : 0
  client_id = azuread_application.aks_cluster[0].client_id
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  sku_tier            = "Free" # Use Paid for production

  # Default Node Pool (System)
  default_node_pool {
    name       = var.system_node_pool.name
    vm_size    = var.system_node_pool.vm_size
    node_count = var.system_node_pool.node_count
    type       = "VirtualMachineScaleSets"
    zones      = ["1", "2", "3"]

    # Network settings
    vnet_subnet_id = var.subnet_id != "" ? var.subnet_id : null

    # Node labels and taints
    node_labels = {
      "nodepool" = "system"
    }
  }

  # Identity Configuration
  identity {
    type = "SystemAssigned"
  }

  # Network Configuration
  network_profile {
    network_plugin    = "azure"
    network_policy    = var.network_policy
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  # RBAC Configuration
  role_based_access_control_enabled = var.rbac_enabled

  # Azure AD Integration (requires RBAC)
  azure_active_directory_role_based_access_control {
    tenant_id              = var.aad_tenant_id != "" ? var.aad_tenant_id : null
    admin_group_object_ids = var.aad_admin_group_ids
  }

  # Key Vault Secrets Provider
  key_vault_secrets_provider {
    secret_rotation_enabled = false
  }

  # Maintenance Window
  maintenance_window {
    allowed {
      day   = "Sunday"
      hours = [2, 3, 4]
    }
  }

  tags = var.tags
}

# User Node Pools
resource "azurerm_kubernetes_cluster_node_pool" "user_pools" {
  count                 = length(var.user_node_pools)
  name                  = var.user_node_pools[count.index].name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.user_node_pools[count.index].vm_size
  node_count            = var.user_node_pools[count.index].node_count
  min_count             = var.user_node_pools[count.index].min_count
  max_count             = var.user_node_pools[count.index].max_count
  zones                 = ["1", "2", "3"]
  vnet_subnet_id        = var.subnet_id != "" ? var.subnet_id : null

  node_labels = {
    "nodepool" = "user"
  }

  tags = var.tags
}

# Kubernetes Cluster User Role Assignment
resource "azurerm_role_assignment" "cluster_user" {
  count                = length(var.aad_admin_group_ids) > 0 ? length(var.aad_admin_group_ids) : 0
  scope                = azurerm_kubernetes_cluster.main.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = var.aad_admin_group_ids[count.index]
}
