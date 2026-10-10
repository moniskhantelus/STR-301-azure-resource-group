# Terratest integration checks

Requires Go 1.23+, Terraform, Azure CLI authenticated to the same cloud and subscription as AzureRM, and a dedicated existing test resource group and existing test VNet. No networking resources or resource groups are provisioned.

```bash
export ARM_SUBSCRIPTION_ID="your-subscription-uuid"
export ARM_ENVIRONMENT="usgovernment"
export STR272_DNS_RESOURCE_GROUP="existing-dedicated-test-rg"
export STR272_VNET_NAME="existing-test-vnet"
export STR272_VNET_RESOURCE_GROUP="existing-networking-rg"
export STR272_RUN_AZURE_TESTS=true
go mod tidy
go test -v -timeout 45m
```

The test applies both examples, checks Azure resource existence, zone names, link IDs, VNet associations and disabled auto-registration, then destroys its DNS resources. Unique names under `privatelink.str272-<timestamp>.*` avoid adopting platform service zones. This verifies deployment mechanics, not endpoint DNS resolution. Do not run concurrently in the same example directory or against a directory containing an existing Terraform state. A failed/interrupted cleanup requires inspecting the example state and running `terraform destroy` with the same test inputs.
