variable "name" {
  description = "Private DNS zone FQDN beginning with privatelink; no URL scheme or trailing dot."
  type        = string
  nullable    = false
  validation {
    condition     = length(var.name) <= 253 && can(regex("^privatelink\\.([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z]([a-z0-9-]{0,61}[a-z0-9])?$", var.name))
    error_message = "Use a lowercase privatelink FQDN with valid DNS labels (maximum 253 characters)."
  }
}
variable "resource_group_name" {
  description = "Existing resource group in which the DNS zone and links are created."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[A-Za-z0-9_.()-]{1,90}$", var.resource_group_name)) && !endswith(var.resource_group_name, ".")
    error_message = "Use a valid resource group name, 1-90 characters, without a trailing period."
  }
}
variable "vnet_links" {
  description = "Links to existing VNets. Link names and VNet IDs must be unique; registration defaults to false."
  type = list(object({
    name                 = string
    vnet_id              = string
    registration_enabled = optional(bool, false)
  }))
  default  = []
  nullable = false
  validation {
    condition     = alltrue([for link in var.vnet_links : can(regex("^[A-Za-z0-9][A-Za-z0-9_.-]{0,78}[A-Za-z0-9_]$|^[A-Za-z0-9]$", link.name))])
    error_message = "Link names must be 1-80 valid characters and cannot end in a hyphen or period."
  }
  validation {
    condition     = alltrue([for link in var.vnet_links : can(regex("(?i)^/subscriptions/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+$", link.vnet_id))])
    error_message = "Each vnet_id must be a full Microsoft.Network/virtualNetworks Azure resource ID with a subscription UUID."
  }
  validation {
    condition     = length(distinct([for link in var.vnet_links : lower(link.name)])) == length(var.vnet_links) && length(distinct([for link in var.vnet_links : lower(link.vnet_id)])) == length(var.vnet_links)
    error_message = "Link names and VNet IDs must be unique within a zone (case insensitive)."
  }
}
variable "tags" {
  description = "Tags applied to the DNS zone and its VNet links."
  type        = map(string)
  default     = {}
  nullable    = false
  validation {
    condition     = length(var.tags) <= 50 && alltrue([for key, value in var.tags : length(key) > 0 && length(key) <= 512 && !can(regex("[<>%&\\\\?/]", key)) && try(length(value) <= 256, false)])
    error_message = "Use at most 50 tags, valid keys of 1-512 characters, and non-null values up to 256 characters."
  }
}
