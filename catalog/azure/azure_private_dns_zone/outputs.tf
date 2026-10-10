output "id" {
  description = "Full resource ID of the Private DNS Zone."
  value       = azurerm_private_dns_zone.this.id
}
output "name" {
  description = "Name of the Private DNS Zone."
  value       = azurerm_private_dns_zone.this.name
}
output "vnet_link_ids" {
  description = "Map of VNet link names to their resource IDs."
  value       = { for name, link in azurerm_private_dns_zone_virtual_network_link.this : name => link.id }
}
