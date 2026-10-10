output "zones" {
  description = "Zone resource IDs, names, and link IDs keyed by the input map."
  value = { for key, zone in module.private_dns_zones : key => {
    id            = zone.id
    name          = zone.name
    vnet_link_ids = zone.vnet_link_ids
  } }
}
