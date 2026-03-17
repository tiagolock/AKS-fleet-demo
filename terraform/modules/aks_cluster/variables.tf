# AKS Cluster Module Variables

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "Azure location for the cluster"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "system_node_pool" {
  description = "System node pool configuration"
  type = object({
    name       = string
    vm_size    = string
    node_count = number
    min_count  = number
    max_count  = number
  })
}

variable "user_node_pools" {
  description = "List of user node pool configurations"
  type = list(object({
    name       = string
    vm_size    = string
    node_count = number
    min_count  = number
    max_count  = number
  }))
}

variable "vnet_id" {
  description = "Virtual network ID for the cluster"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID for the cluster nodes"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Azure AD Integration
variable "aad_tenant_id" {
  description = "Azure AD Tenant ID"
  type        = string
  default     = ""
}

variable "aad_admin_group_ids" {
  description = "Azure AD group IDs for cluster admin"
  type        = list(string)
  default     = []
}

# Network Configuration

variable "network_policy" {
  description = "Network policy (calico, azure)"
  type        = string
  default     = "azure"
}

variable "service_cidr" {
  description = "Service CIDR for Kubernetes services"
  type        = string
  default     = "10.96.0.0/12"
}

variable "dns_service_ip" {
  description = "DNS service IP"
  type        = string
  default     = "10.96.0.10"
}

# RBAC Configuration
variable "rbac_enabled" {
  description = "Enable RBAC"
  type        = bool
  default     = true
}
