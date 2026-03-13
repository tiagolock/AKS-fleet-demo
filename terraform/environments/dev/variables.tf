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

variable "client_id" {
  description = "Azure Client ID (Service Principal)"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Azure Client Secret (Service Principal)"
  type        = string
  sensitive   = true
}

# Resource Group Configuration
variable "use_single_resource_group" {
  description = "Use a single resource group for all resources"
  type        = bool
  default     = false
}

variable "resource_group_name" {
  description = "Name of the shared resource group (when use_single_resource_group is true)"
  type        = string
  default     = "rg-aks-fleet"
}

variable "location" {
  description = "Default Azure region (used when use_single_resource_group is true)"
  type        = string
  default     = "eastus"
}

# AKS Cluster 1 Configuration
variable "aks_cluster_1" {
  description = "Configuration for cluster 1"
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    kubernetes_version  = string
  })
  default = {
    name                = "aks-cluster-1"
    location            = "eastus"
    resource_group_name = "rg-aks-cluster-1"
    kubernetes_version  = "1.28"
  }
}

# AKS Cluster 2 Configuration
variable "aks_cluster_2" {
  description = "Configuration for cluster 2"
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    kubernetes_version  = string
  })
  default = {
    name                = "aks-cluster-2"
    location            = "eastus2"
    resource_group_name = "rg-aks-cluster-2"
    kubernetes_version  = "1.28"
  }
}

# System Node Pool Configuration
variable "system_node_pool" {
  description = "Configuration for system node pool"
  type = object({
    name           = string
    vm_size        = string
    node_count     = number
    min_count      = number
    max_count      = number
  })
  default = {
    name       = "systempool"
    vm_size    = "Standard_DS2_v2"
    node_count = 1
    min_count  = 1
    max_count  = 3
  }
}

# User Node Pool Configuration
variable "user_node_pools" {
  description = "Configuration for user node pools"
  type = list(object({
    name           = string
    vm_size        = string
    node_count     = number
    min_count      = number
    max_count      = number
  }))
  default = [
    {
      name       = "userpool"
      vm_size    = "Standard_DS2_v2"
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

variable "fleet_resource_group_name" {
  description = "Resource group name for Fleet Manager"
  type        = string
  default     = "rg-aks-fleet"
}

# Network Configuration
variable "vnet_address_space" {
  description = "Virtual network address space"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aks_subnet_address_prefix" {
  description = "AKS subnet address prefix"
  type        = string
  default     = "10.0.1.0/24"
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
