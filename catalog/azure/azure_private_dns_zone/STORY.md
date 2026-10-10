Description

Create a reusable Terraform child module for provisioning Azure Private DNS Zones that support private endpoint resolution for platform services. This module enables split-horizon DNS where private endpoint FQDNs resolve to private IPs inside the VNet.

Background

Private DNS Zones are essential for Private Endpoint connectivity. When resources like Key Vault, Storage Account, or Container Registry are configured with Private Endpoints, Azure automatically creates DNS records in the linked Private DNS Zone. This allows pods and other VNet resources to resolve service FQDNs to their private IP addresses rather than public endpoints.

The platform does NOT create or manage VNets, subnets, route tables, or peerings — these are provisioned by the networking team. This module only creates Private DNS Zones and links them to existing VNets provided as data sources.

Module Structure

The module must follow the standard child module layout defined in the [KaaS Playbook: Terraform Module Standards](https://git.web.boeing.com/kaas/guidance/kaas_playbook/-/blob/main/iac_terraform_module/iac-terraform-module.md?ref_type=heads "Follow link"):



catalog/azure/azure_private_dns_zone/

├── main.tf

├── variables.tf

├── outputs.tf

├── versions.tf

├── locals.tf

├── data.tf                      # Data sources for existing VNets

├── README.md

├── CHANGELOG.md

├── examples/

│   ├── basic/

│   │   ├── main.tf

│   │   ├── variables.tf

│   │   └── outputs.tf

│   └── complete/

│       ├── main.tf

│       ├── variables.tf

│       └── outputs.tf

├── test/

│   ├── go.mod

│   ├── go.sum

│   └── module_test.go

└── architecture/

    ├── module-overview\.drawio

    └── module-overview\.drawio.png

Private DNS Zone Names (Azure Standard)

The module must support all privatelink DNS zones required by platform services:

| **Service**              | **Private DNS Zone Name**                                                                                                                       |
| ------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| Key Vault                | [privatelink.vaultcore.usgovcloudapi.net](http://privatelink.vaultcore.usgovcloudapi.net/)                                                      |
| Storage Account (Blob)   | [privatelink.blob.core.usgovcloudapi.net](http://privatelink.blob.core.usgovcloudapi.net/)                                                      |
| Storage Account (File)   | [privatelink.file.core.usgovcloudapi.net](http://privatelink.file.core.usgovcloudapi.net/)                                                      |
| Container Registry (ACR) | [privatelink.azurecr.us](http://privatelink.azurecr.us/)                                                                                        |
| Log Analytics            | [privatelink.oms.opinsights.azure.us](http://privatelink.oms.opinsights.azure.us/)                                                              |
| Application Insights     | [privatelink.monitor.azure.us](http://privatelink.monitor.azure.us/)                                                                            |
| AKS API Server           | privatelink.\<region>.[azmk8s.io](http://azmk8s.io/) (e.g., [privatelink.usgovvirginia.azmk8s.io](http://privatelink.usgovvirginia.azmk8s.io/)) |

Required Variables

| **Variable**        | **Type**     | **Required** | **Description**                                                    |
| ------------------- | ------------ | ------------ | ------------------------------------------------------------------ |
| name                | string       | yes          | Private DNS Zone name (must be a valid privatelink zone)           |
| resource_group_name | string       | yes          | Resource group where the DNS zone will be created                  |
| vnet_links          | list(object) | no           | List of VNets to link (each with vnet_id and registration_enabled) |
| tags                | map(string)  | no           | Tags to apply to the DNS zone                                      |

**vnet_links object structure:**



{

  name                 = string  # Link name

  vnet_id              = string  # Full resource ID of the VNet (from data source)

  registration_enabled = bool    # Enable auto-registration (usually false for privatelink)

}

Required Outputs

| **Output**    | **Description**                              |
| ------------- | -------------------------------------------- |
| id            | The full resource ID of the Private DNS Zone |
| name          | The name of the Private DNS Zone             |
| vnet_link_ids | Map of VNet link names to their resource IDs |

Data Sources

The module references existing VNets as data sources. VNets are NOT created by this module:

\# Example data source usage in the calling module

data "azurerm_virtual_network" "platform" {

  name                = "vnet-kaas-cdp-dev-va"

  resource_group_name = "kaas-cdp-dev-networking-va-rg"

}



module "dns_zone_keyvault" {

  source = "..."



  name                = "[privatelink.vaultcore.usgovcloudapi.net](http://privatelink.vaultcore.usgovcloudapi.net/)"

  resource_group_name = "kaas-cdp-dev-platform-va-rg"



  vnet_links = [

    {

      name                 = "platform-vnet-link"

      vnet_id              = [data.azurerm_virtual_network.platform.id](http://data.azurerm_virtual_network.platform.id/)

      registration_enabled = false

    }

  ]

}

Validation Requirements

- DNS zone name must be a valid Azure privatelink zone format
- VNet IDs must be valid Azure resource IDs
- registration_enabled should default to false for privatelink zones

Example Usage

**Basic Example (single DNS zone):**

\# Reference existing VNet (managed by networking team)

data "azurerm_virtual_network" "platform" {

  name                = "vnet-kaas-cdp-dev-va"

  resource_group_name = "kaas-cdp-dev-networking-va-rg"

}



module "dns_zone_keyvault" {

  source = "git::[https://gitlab.example.com/kaas/catalog/azure/azure_private_dns_zone.git?ref=v1.0.0](https://gitlab.example.com/kaas/catalog/azure/azure_private_dns_zone.git?ref=v1.0.0)"



  name                = "[privatelink.vaultcore.usgovcloudapi.net](http://privatelink.vaultcore.usgovcloudapi.net/)"

  resource_group_name = "kaas-cdp-dev-platform-va-rg"



  vnet_links = [

    {

      name                 = "platform-vnet-link"

      vnet_id              = [data.azurerm_virtual_network.platform.id](http://data.azurerm_virtual_network.platform.id/)

      registration_enabled = false

    }

  ]



  tags = {

    environment = "dev"

    purpose     = "platform"

    managed_by  = "terraform"

  }

}

**Complete Example (multiple DNS zones via variable):**

variable "private_dns_zones" {

  description = "Map of private DNS zones to create"

  type = map(object({

    name                = string

    resource_group_name = string

    vnet_links = list(object({

      name                 = string

      vnet_id              = string

      registration_enabled = bool

    }))

    tags = map(string)

  }))

}



data "azurerm_virtual_network" "platform" {

  name                = "vnet-kaas-cdp-dev-va"

  resource_group_name = "kaas-cdp-dev-networking-va-rg"

}



module "private_dns_zones" {

  source   = "git::[https://gitlab.example.com/kaas/catalog/azure/azure_private_dns_zone.git?ref=v1.0.0](https://gitlab.example.com/kaas/catalog/azure/azure_private_dns_zone.git?ref=v1.0.0)"

  for_each = var.private_dns_zones



  name                = each.value.name

  resource_group_name = each.value.resource_group_name

  vnet_links          = each.value.vnet_links

  tags                = each.value.tags

}



\# Example tfvars:

\# private_dns_zones = {

\#   keyvault = {

\#     name                = "[privatelink.vaultcore.usgovcloudapi.net](http://privatelink.vaultcore.usgovcloudapi.net/)"

\#     resource_group_name = "kaas-cdp-dev-platform-va-rg"

\#     vnet_links = [

\#       {

\#         name                 = "platform-vnet-link"

\#         vnet_id              = "/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/vnet-kaas-cdp-dev-va"

\#         registration_enabled = false

\#       }

\#     ]

\#     tags = {

\#       environment = "dev"

\#       purpose     = "platform"

\#       managed_by  = "terraform"

\#     }

\#   }

\#   blob = {

\#     name                = "[privatelink.blob.core.usgovcloudapi.net](http://privatelink.blob.core.usgovcloudapi.net/)"

\#     resource_group_name = "kaas-cdp-dev-platform-va-rg"

\#     vnet_links = [

\#       {

\#         name                 = "platform-vnet-link"

\#         vnet_id              = "/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/vnet-kaas-cdp-dev-va"

\#         registration_enabled = false

\#       }

\#     ]

\#     tags = {

\#       environment = "dev"

\#       purpose     = "platform"

\#       managed_by  = "terraform"

\#     }

\#   }

\# }

Testing Requirements

- Terratest must validate that the Private DNS Zone is created
- Terratest must validate that VNet links are created and associated
- Both basic and complete examples must deploy successfully

Acceptance Criteria

- [ ] Module follows the standard directory layout from [KaaS Playbook](https://git.web.boeing.com/kaas/guidance/kaas_playbook/-/blob/main/iac_terraform_module/iac-terraform-module.md?ref_type=heads "Follow link")
- [ ] All variables have description, type, and validation blocks
- [ ] DNS zone name validation ensures valid privatelink format
- [ ] VNet links are created with for_each for flexibility
- [ ] README.md is auto-generated via terraform-docs
- [ ] CHANGELOG.md follows Keep a Changelog format
- [ ] Basic and complete examples are deployable
- [ ] Terratest passes for all examples
- [ ] Module tagged with SemVer (v1.0.0)