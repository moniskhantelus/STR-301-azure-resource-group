output "id" {
  description = "Child module id."
  value       = module.dns_zone_keyvault.id
}
output "name" {
  description = "Child module name."
  value       = module.dns_zone_keyvault.name
}
output "vnet_link_ids" {
  description = "Child module vnet_link_ids."
  value       = module.dns_zone_keyvault.vnet_link_ids
}
