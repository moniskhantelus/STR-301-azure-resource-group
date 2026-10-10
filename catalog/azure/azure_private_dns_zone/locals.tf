locals {
  vnet_links = { for link in var.vnet_links : link.name => link }
}
