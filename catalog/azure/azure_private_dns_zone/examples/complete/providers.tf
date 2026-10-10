provider "azurerm" {
  features {}
  subscription_id                 = var.subscription_id
  environment                     = var.environment
  resource_provider_registrations = "none"
}
