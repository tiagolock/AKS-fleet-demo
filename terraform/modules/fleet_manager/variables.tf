# AKS Fleet Manager Module Variables

variable "fleet_name" {
  description = "Name of the AKS Fleet Manager"
  type        = string
}

variable "location" {
  description = "Azure location for the Fleet Manager"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for the Fleet Manager"
  type        = string
}

variable "aad_tenant_id" {
  description = "Azure AD Tenant ID"
  type        = string
  default     = ""
}

variable "aad_admin_group_ids" {
  description = "Azure AD group IDs for Fleet Manager admin"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Hub API Server Access Configuration
variable "enable_hub_api_server_access" {
  description = "Enable hub API server access"
  type        = bool
  default     = true
}

variable "api_server_access_profile_subnet_ids" {
  description = "Subnet IDs for API server access"
  type        = list(string)
  default     = []
}
