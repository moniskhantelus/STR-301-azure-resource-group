module "dns_zone_keyvault" {
  source              = "../.."
  name                = var.name
  resource_group_name = var.resource_group_name
  vnet_links = [{
    name    = "platform-vnet-link"
    vnet_id = data.azurerm_virtual_network.platform.id
  }]
  tags = { managed_by = "terraform", purpose = "platform" }
}
