mock_provider "azurerm" {}

variables {
  name                = "privatelink.vaultcore.usgovcloudapi.net"
  resource_group_name = "dns-test-rg"
}

run "zone_without_links" {
  command = plan
  assert {
    condition     = azurerm_private_dns_zone.this.name == var.name && length(azurerm_private_dns_zone_virtual_network_link.this) == 0
    error_message = "A zone without optional links must plan successfully."
  }
}
run "two_links_default_registration" {
  command = plan
  variables {
    vnet_links = [
      { name = "one", vnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet-one" },
      { name = "two", vnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet-two" }
    ]
  }
  assert {
    condition     = length(azurerm_private_dns_zone_virtual_network_link.this) == 2 && !azurerm_private_dns_zone_virtual_network_link.this["one"].registration_enabled
    error_message = "Two distinct keyed links must plan, with registration false by default."
  }
}
run "reject_url" {
  command = plan
  variables { name = "https://privatelink.vaultcore.usgovcloudapi.net" }
  expect_failures = [var.name]
}
run "reject_non_private_zone" {
  command = plan
  variables { name = "example.com" }
  expect_failures = [var.name]
}
run "reject_malformed_vnet_id" {
  command = plan
  variables { vnet_links = [{ name = "one", vnet_id = "not-a-vnet-id" }] }
  expect_failures = [var.vnet_links]
}
run "reject_duplicate_vnet" {
  command = plan
  variables {
    vnet_links = [
      { name = "one", vnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet-one" },
      { name = "two", vnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet-one" }
    ]
  }
  expect_failures = [var.vnet_links]
}
run "reject_bad_resource_group" {
  command = plan
  variables { resource_group_name = "bad/name" }
  expect_failures = [var.resource_group_name]
}
run "reject_bad_tag" {
  command = plan
  variables { tags = { "bad/key" = "value" } }
  expect_failures = [var.tags]
}
