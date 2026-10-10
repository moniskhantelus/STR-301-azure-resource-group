data "azurerm_virtual_network" "platform" {
  name                = var.vnet_name
  resource_group_name = var.vnet_resource_group_name
}
