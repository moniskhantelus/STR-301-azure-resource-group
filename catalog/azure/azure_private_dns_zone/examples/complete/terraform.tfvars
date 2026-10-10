subscription_id          = "c82d5dd9-5800-4651-9179-d1131cc167aa"
environment              = "public"//"usgovernment"
vnet_name                = "vnet-kaas-cdp-dev-va"
vnet_resource_group_name = "kaas-cdp-dev-networking-va-rg"
private_dns_zones = {
  keyvault = {
    name                = "privatelink.vaultcore.usgovcloudapi.net"
    resource_group_name = "kaas-cdp-dev-platform-va-rg"
    tags                = { environment = "dev", managed_by = "terraform", purpose = "platform" }
  }
  blob = {
    name                = "privatelink.blob.core.usgovcloudapi.net"
    resource_group_name = "kaas-cdp-dev-platform-va-rg"
    tags                = { environment = "dev", managed_by = "terraform", purpose = "platform" }
  }
  file = {
    name                = "privatelink.file.core.usgovcloudapi.net"
    resource_group_name = "kaas-cdp-dev-platform-va-rg"
    tags                = { environment = "dev", managed_by = "terraform", purpose = "platform" }
  }
  acr = {
    name                = "privatelink.azurecr.us"
    resource_group_name = "kaas-cdp-dev-platform-va-rg"
    tags                = { environment = "dev", managed_by = "terraform", purpose = "platform" }
  }
  log_analytics = {
    name                = "privatelink.oms.opinsights.azure.us"
    resource_group_name = "kaas-cdp-dev-platform-va-rg"
    tags                = { environment = "dev", managed_by = "terraform", purpose = "platform" }
  }
  application_insights = {
    name                = "privatelink.monitor.azure.us"
    resource_group_name = "kaas-cdp-dev-platform-va-rg"
    tags                = { environment = "dev", managed_by = "terraform", purpose = "platform" }
  }
  aks = {
    name                = "privatelink.usgovvirginia.azmk8s.io"
    resource_group_name = "kaas-cdp-dev-platform-va-rg"
    tags                = { environment = "dev", managed_by = "terraform", purpose = "platform" }
  }
}
