module "private_dns_zones" {
  source              = "../.."
  for_each            = var.private_dns_zones
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  vnet_links = length(each.value.vnet_links) > 0 ? each.value.vnet_links : [{
    name                 = "platform-vnet-link"
    vnet_id              = data.azurerm_virtual_network.platform.id
    registration_enabled = false
  }]
  tags = each.value.tags
}
