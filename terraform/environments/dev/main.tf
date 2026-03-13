# Main Terraform Configuration for AKS Fleet Demo
# Supports deploying clusters in different regions

# ============================================
# Resource Groups
# ============================================

# Resource Group for Cluster 1
resource "azurerm_resource_group" "cluster_1" {
  name     = var.aks_cluster_1.resource_group_name
  location = var.aks_cluster_1.location

  tags = var.tags
}

# Resource Group for Cluster 2
resource "azurerm_resource_group" "cluster_2" {
  name     = var.aks_cluster_2.resource_group_name
  location = var.aks_cluster_2.location

  tags = var.tags
}

# Resource Group for Fleet Manager
resource "azurerm_resource_group" "fleet" {
  name     = var.fleet_resource_group_name
  location = var.fleet_location

  tags = var.tags
}

# ============================================
# Virtual Networks (one per cluster region)
# ============================================

# Virtual Network for Cluster 1
resource "azurerm_virtual_network" "cluster_1" {
  name                = "vnet-${var.aks_cluster_1.name}"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.cluster_1.location
  resource_group_name = azurerm_resource_group.cluster_1.name

  tags = var.tags
}

# Subnet for Cluster 1
resource "azurerm_subnet" "cluster_1" {
  name                 = "snet-${var.aks_cluster_1.name}"
  address_prefixes     = [var.aks_subnet_address_prefix]
  virtual_network_name = azurerm_virtual_network.cluster_1.name
  resource_group_name  = azurerm_resource_group.cluster_1.name

  delegation {
    name = "aks-delegation"

    service_delegation {
      name = "Microsoft.ContainerService/managedClusters"
    }
  }
}

# Virtual Network for Cluster 2
resource "azurerm_virtual_network" "cluster_2" {
  name                = "vnet-${var.aks_cluster_2.name}"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.cluster_2.location
  resource_group_name = azurerm_resource_group.cluster_2.name

  tags = var.tags
}

# Subnet for Cluster 2
resource "azurerm_subnet" "cluster_2" {
  name                 = "snet-${var.aks_cluster_2.name}"
  address_prefixes     = [cidrsubnet(var.aks_subnet_address_prefix, 1, 1)]
  virtual_network_name = azurerm_virtual_network.cluster_2.name
  resource_group_name  = azurerm_resource_group.cluster_2.name

  delegation {
    name = "aks-delegation"

    service_delegation {
      name = "Microsoft.ContainerService/managedClusters"
    }
  }
}

# ============================================
# Additional User Node Pools
# ============================================

variable "cluster_1_additional_user_pools" {
  description = "Additional user node pools for cluster 1"
  type = list(object({
    name           = string
    vm_size        = string
    node_count     = number
    min_count      = number
    max_count      = number
  }))
  default = [
    {
      name       = "userpool-large"
      vm_size    = "Standard_D4s_v3"
      node_count = 0
      min_count  = 0
      max_count  = 2
    }
  ]
}

variable "cluster_2_additional_user_pools" {
  description = "Additional user node pools for cluster 2"
  type = list(object({
    name           = string
    vm_size        = string
    node_count     = number
    min_count      = number
    max_count      = number
  }))
  default = [
    {
      name       = "userpool-large"
      vm_size    = "Standard_D4s_v3"
      node_count = 0
      min_count  = 0
      max_count  = 2
    }
  ]
}

# ============================================
# AKS Cluster 1
# ============================================

module "aks_cluster_1" {
  source = "../../modules/aks_cluster"

  cluster_name         = var.aks_cluster_1.name
  location             = azurerm_resource_group.cluster_1.location
  resource_group_name  = azurerm_resource_group.cluster_1.name
  kubernetes_version   = var.aks_cluster_1.kubernetes_version
  system_node_pool     = var.system_node_pool
  user_node_pools      = concat(var.user_node_pools, var.cluster_1_additional_user_pools)

  # Network configuration
  vnet_id  = azurerm_virtual_network.cluster_1.id
  subnet_id = azurerm_subnet.cluster_1.id

  # RBAC configuration
  rbac_enabled  = true
  aad_tenant_id = var.tenant_id

  # Tags
  tags = var.tags
}

# ============================================
# AKS Cluster 2
# ============================================

module "aks_cluster_2" {
  source = "../../modules/aks_cluster"

  cluster_name         = var.aks_cluster_2.name
  location             = azurerm_resource_group.cluster_2.location
  resource_group_name  = azurerm_resource_group.cluster_2.name
  kubernetes_version   = var.aks_cluster_2.kubernetes_version
  system_node_pool     = var.system_node_pool
  user_node_pools      = concat(var.user_node_pools, var.cluster_2_additional_user_pools)

  # Network configuration
  vnet_id  = azurerm_virtual_network.cluster_2.id
  subnet_id = azurerm_subnet.cluster_2.id

  # RBAC configuration
  rbac_enabled  = true
  aad_tenant_id = var.tenant_id

  # Tags
  tags = var.tags
}

# ============================================
# AKS Fleet Manager
# ============================================

module "fleet_manager" {
  source = "../../modules/fleet_manager"

  fleet_name           = var.fleet_name
  location            = azurerm_resource_group.fleet.location
  resource_group_name = azurerm_resource_group.fleet.name

  # Azure AD Configuration
  aad_tenant_id = var.tenant_id

  # Tags
  tags = var.tags
}

# ============================================
# Fleet Members - Register clusters with Fleet
# ============================================

# Fleet Member for Cluster 1
resource "azurerm_fleet_cluster" "cluster_1" {
  provider = azurerm.fleet

  name           = var.aks_cluster_1.name
  fleet_id       = module.fleet_manager.id
  location       = azurerm_resource_group.cluster_1.location
  resource_group = azurerm_resource_group.cluster_1.name

  depends_on = [module.aks_cluster_1]
}

# Fleet Member for Cluster 2
resource "azurerm_fleet_cluster" "cluster_2" {
  provider = azurerm.fleet

  name           = var.aks_cluster_2.name
  fleet_id       = module.fleet_manager.id
  location       = azurerm_resource_group.cluster_2.location
  resource_group = azurerm_resource_group.cluster_2.name

  depends_on = [module.aks_cluster_2]
}

# ============================================
# Kubernetes Role Bindings for Fleet
# ============================================

# Get AKS credentials for cluster 1
resource "null_resource" "fleet_cluster1_credentials" {
  triggers = {
    cluster_name = module.aks_cluster_1.name
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "AKS Cluster 1 kubeconfig can be retrieved using:"
      echo "az aks get-credentials --name ${module.aks_cluster_1.name} --resource-group ${azurerm_resource_group.cluster_1.name}"
    EOT
  }
}

# Get AKS credentials for cluster 2
resource "null_resource" "fleet_cluster2_credentials" {
  triggers = {
    cluster_name = module.aks_cluster_2.name
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "AKS Cluster 2 kubeconfig can be retrieved using:"
      echo "az aks get-credentials --name ${module.aks_cluster_2.name} --resource-group ${azurerm_resource_group.cluster_2.name}"
    EOT
  }
}
