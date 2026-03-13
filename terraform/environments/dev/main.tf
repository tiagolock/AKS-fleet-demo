# # Main Terraform Configuration for AKS Fleet Demo
# # Supports deploying clusters in different regions with private networking and jump host

# ============================================
# AKS Cluster 1 (Private)
# ============================================

module "aks_cluster_1" {
  source = "../../modules/aks_cluster"

  cluster_name        = var.aks_cluster_1.name
  location            = var.aks_cluster_1.location
  resource_group_name = data.azurerm_resource_group.rg.name
  system_node_pool    = var.system_node_pool
  user_node_pools     = var.user_node_pools
  kubernetes_version  = "1.27"
  vnet_id             = azurerm_virtual_network.cluster_1.id
  subnet_id           = azurerm_subnet.cluster_1_aks.id
  rbac_enabled        = true
  aad_tenant_id       = var.tenant_id
  tags                = var.tags
}

# ============================================
# AKS Cluster 2 (Private)
# ============================================

module "aks_cluster_2" {
  source = "../../modules/aks_cluster"

  cluster_name        = var.aks_cluster_2.name
  location            = var.aks_cluster_2.location
  resource_group_name = data.azurerm_resource_group.rg.name
  kubernetes_version  = var.aks_cluster_2.kubernetes_version
  system_node_pool    = var.system_node_pool
  user_node_pools     = var.user_node_pools
  vnet_id             = azurerm_virtual_network.cluster_2.id
  subnet_id           = azurerm_subnet.cluster_2_aks.id
  rbac_enabled        = true
  aad_tenant_id       = var.tenant_id
  tags                = var.tags
}

# ============================================
# AKS Fleet Manager
# ============================================

module "fleet_manager" {
  source = "../../modules/fleet_manager"

  fleet_name          = var.fleet_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  aad_tenant_id       = var.tenant_id
  tags                = var.tags
}

# ============================================
# Fleet Members - Register clusters with Fleet
# ============================================

# Fleet Member for Cluster 1
resource "azurerm_fleet_cluster" "cluster_1" {
  name           = var.aks_cluster_1.name
  fleet_id       = module.fleet_manager.id
  location       = var.aks_cluster_1.location
  resource_group = data.azurerm_resource_group.rg.name
  depends_on     = [module.aks_cluster_1]
}

# Fleet Member for Cluster 2
resource "azurerm_fleet_cluster" "cluster_2" {
  name           = var.aks_cluster_2.name
  fleet_id       = module.fleet_manager.id
  location       = var.aks_cluster_2.location
  resource_group = data.azurerm_resource_group.rg.name
  depends_on     = [module.aks_cluster_2]
}

# ============================================
# Kubernetes Role Bindings for Fleet
# ============================================

# Get AKS credentials for cluster 1 (via jump host)
resource "null_resource" "fleet_cluster1_credentials" {
  triggers = {
    cluster_name = module.aks_cluster_1.name
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "AKS Cluster 1 is private. Access via jump host:"
      echo "1. SSH to jump host: ssh ${var.jump_host_username}@${azurerm_public_ip.jump_host.ip_address}"
      echo "2. From jump host, run: az aks get-credentials --name ${module.aks_cluster_1.name} --resource-group ${data.azurerm_resource_group.rg.name}"
    EOT
  }
}

# Get AKS credentials for cluster 2 (via jump host)
resource "null_resource" "fleet_cluster2_credentials" {
  triggers = {
    cluster_name = module.aks_cluster_2.name
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "AKS Cluster 2 is private. Access via jump host:"
      echo "1. SSH to jump host: ssh ${var.jump_host_username}@${azurerm_public_ip.jump_host.ip_address}"
      echo "2. From jump host, run: az aks get-credentials --name ${module.aks_cluster_2.name} --resource-group ${data.azurerm_resource_group.rg.name}"
    EOT
  }
}
