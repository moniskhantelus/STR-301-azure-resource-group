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
variable "private_dns_zones" {
  description = "Map of zones. Empty vnet_links uses the existing platform VNet data source; explicit IDs can come from other callers."
  type = map(object({
    name                = string
    resource_group_name = string
    vnet_links = optional(list(object({
      name                 = string
      vnet_id              = string
      registration_enabled = optional(bool, false)
    })), [])
    tags = optional(map(string), {})
  }))
  validation {
    condition     = length(var.private_dns_zones) > 0 && alltrue([for zone in values(var.private_dns_zones) : startswith(zone.name, "privatelink.") && length(trimspace(zone.resource_group_name)) > 0])
    error_message = "Provide at least one zone with a privatelink name and existing resource group; child modules validate all fields."
  }
}
