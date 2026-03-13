# Azure Provider Variables
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  sensitive   = true
}

# Resource Group Configuration
variable "resource_group_name" {
  description = "Name of the shared resource group (when use_single_resource_group is true)"
  type        = string
  default     = "rg-aks-fleet"
}

variable "location" {
  description = "Default Azure region (used when use_single_resource_group is true)"
  type        = string
  default     = "eastus2"
}

# AKS Cluster 1 Configuration
variable "aks_cluster_1" {
  description = "Configuration for cluster 1"
  type = object({
    name                      = string
    location                  = string
    kubernetes_version        = string
    vnet_address_space        = string
    aks_subnet_address_prefix = string
  })
  default = {
    name                      = "aks-cluster-1"
    location                  = "eastus2"
    kubernetes_version        = "1.28"
    vnet_address_space        = "10.1.0.0/16"
    aks_subnet_address_prefix = "10.1.1.0/24"
  }
}

# AKS Cluster 2 Configuration
variable "aks_cluster_2" {
  description = "Configuration for cluster 2"
  type = object({
    name                      = string
    location                  = string
    kubernetes_version        = string
    vnet_address_space        = string
    aks_subnet_address_prefix = string
  })
  default = {
    name                      = "aks-cluster-2"
    location                  = "centralus"
    kubernetes_version        = "1.28"
    vnet_address_space        = "10.2.0.0/16"
    aks_subnet_address_prefix = "10.2.1.0/24"
  }
}

# Private Cluster Configuration
variable "enable_private_cluster" {
  description = "Enable private AKS clusters (no public API server endpoint)"
  type        = bool
  default     = true
}

variable "private_cluster_dns_zone" {
  description = "Private DNS zone name for private cluster"
  type        = string
  default     = "privatelink.hcp.eastus.azmk8s.io"
}

# Jump Host Configuration
variable "enable_jump_host" {
  description = "Enable jump host (bastion) for accessing clusters"
  type        = bool
  default     = true
}

variable "jump_host_vm_size" {
  description = "VM size for the jump host"
  type        = string
  default     = "Standard_B2s"
}

variable "jump_host_username" {
  description = "Username for the jump host"
  type        = string
  default     = "azureuser"
}

variable "jump_host_subnet_address_prefix" {
  description = "Address prefix for jump host subnet"
  type        = string
  default     = "172.16.0.0/24"
}

# System Node Pool Configuration
variable "system_node_pool" {
  description = "Configuration for system node pool"
  type = object({
    name       = string
    vm_size    = string
    node_count = number
    min_count  = number
    max_count  = number
  })
  default = {
    name       = "systempool"
    vm_size    = "Standard_D2ads_v7"
    node_count = 1
    min_count  = 1
    max_count  = 3
  }
}

# User Node Pool Configuration
variable "user_node_pools" {
  description = "Configuration for user node pools"
  type = list(object({
    name       = string
    vm_size    = string
    node_count = number
    min_count  = number
    max_count  = number
  }))
  default = [
    {
      name       = "userpool"
      vm_size    = "Standard_D2ads_v7"
      node_count = 1
      min_count  = 1
      max_count  = 3
    }
  ]
}

# AKS Fleet Manager Configuration
variable "fleet_name" {
  description = "Name of the AKS Fleet Manager"
  type        = string
  default     = "fleet-manager"
}

variable "fleet_location" {
  description = "Location for the Fleet Manager"
  type        = string
  default     = "eastus"
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "AKS-Fleet-Demo"
    ManagedBy   = "Terraform"
  }
}
