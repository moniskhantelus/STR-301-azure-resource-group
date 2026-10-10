variable "subscription_id" {
  description = "Subscription containing the existing zone resource group and example VNet."
  type        = string
  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id))
    error_message = "Provide a subscription UUID."
  }
}
variable "environment" {
  description = "AzureRM environment: usgovernment or public."
  type        = string
  default     = "usgovernment"
  validation {
    condition     = contains(["usgovernment", "public"], var.environment)
    error_message = "Choose usgovernment or public."
  }
}
variable "vnet_name" {
  description = "Existing networking-team-managed VNet name."
  type        = string
  validation {
    condition     = length(trimspace(var.vnet_name)) > 0
    error_message = "Provide an existing VNet name."
  }
}
variable "vnet_resource_group_name" {
  description = "Existing VNet resource group name."
  type        = string
  validation {
    condition     = length(trimspace(var.vnet_resource_group_name)) > 0
    error_message = "Provide the existing networking resource group name."
  }
}
variable "name" {
  description = "Zone name; validated by the child module."
  type        = string
  default     = "privatelink.vaultcore.usgovcloudapi.net"
  validation {
    condition     = startswith(var.name, "privatelink.")
    error_message = "Use a privatelink zone name."
  }
}
variable "resource_group_name" {
  description = "Existing DNS zone resource group."
  type        = string
  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "Provide the existing zone resource group."
  }
}
