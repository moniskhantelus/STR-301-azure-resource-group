# STR-272 — Azure Private DNS Zone

Creates one Private DNS Zone and optional links to existing VNets. Invoke this child module with `for_each` to create several zones. Networking-team resources and existing resource groups are prerequisites; no VNet, subnet, peering, route table, resource group, role assignment, private endpoint, or DNS record is created.

## Deployment

Requirements: Terraform >=1.6, AzureRM 4.x, Azure CLI login, existing resource groups/VNets, and pre-registered Microsoft.Network. Default examples target Azure Government.

```bash
az cloud set --name AzureUSGovernment
az login
az account set --subscription YOUR_SUBSCRIPTION_ID
cd catalog/azure/azure_private_dns_zone/examples/basic
# Edit terraform.tfvars: subscription_id and existing RG/VNet names.
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Use `examples/complete` for all seven story zones. The tfvars map carries zone names, resource groups, optional explicit vnet_links and tags. When links are omitted/empty in this example, the platform VNet data source supplies one link. The child module itself allows zero links. No Terraform data-source expressions belong in tfvars.

## Design and boundaries

- Required interface: name, resource_group_name; optional vnet_links and tags. Outputs: id, name, vnet_link_ids.
- registration_enabled defaults to false; true is accepted because the story permits it. VM auto-registration does not create private endpoint DNS records.
- Link names form stable for_each keys. Renaming a link changes its resource address; changing the zone name replaces the zone.
- Caller data sources read existing VNets. For a different networking subscription, use an aliased AzureRM provider on the caller data source, then pass its ID. The child module provider remains the DNS-zone subscription.
- DNS zone groups on private endpoints, or a separate record-management process, must populate records. A zone and a VNet link alone do not prove private endpoint resolution.
- With custom VNet DNS, networking must configure forwarding/resolver reachability to Azure private DNS.
- Do not duplicate a centrally managed zone or existing VNet link. Import an existing resource if this state should own it, otherwise consume its ID outside this module.
- Deployment identity needs zone write permissions and VNet link/join permissions on the existing VNet. This module does not grant those permissions.

## Supported story zones

| Service | Example zone |
|---|---|
| Key Vault | privatelink.vaultcore.usgovcloudapi.net |
| Blob | privatelink.blob.core.usgovcloudapi.net |
| File | privatelink.file.core.usgovcloudapi.net |
| ACR | privatelink.azurecr.us |
| Log Analytics | privatelink.oms.opinsights.azure.us |
| Application Insights | privatelink.monitor.azure.us |
| AKS | privatelink.usgovvirginia.azmk8s.io |

Zone names above preserve the story. Confirm service/cloud-specific requirements with the platform owner before deployment; monitor private link designs can require additional zones outside this story. The validator checks DNS syntax, not whether a service supports a particular suffix.

## Tests and documentation

```bash
# Terraform >=1.7 required for mocked provider tests (no Azure deployment).
terraform init
terraform test
# Regenerate the reference below using terraform-docs.
terraform-docs markdown table --output-file README.md --output-mode inject .
# Integration tests create and destroy only test DNS zones and links.
cd test
go mod tidy
STR272_RUN_AZURE_TESTS=true go test -v -timeout 45m
```

See test/README.md for required environment variables and cleanup behavior. Never run integration tests against production zone names. See VALIDATION.md for actual checks performed and outstanding acceptance gates. The internal KaaS Playbook URL was not accessible; layout follows the supplied story, not an independently verified playbook revision.

References: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link and https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.81.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Private DNS zone FQDN beginning with privatelink; no URL scheme or trailing dot. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Existing resource group in which the DNS zone and links are created. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the DNS zone and its VNet links. | `map(string)` | `{}` | no |
| <a name="input_vnet_links"></a> [vnet\_links](#input\_vnet\_links) | Links to existing VNets. Link names and VNet IDs must be unique; registration defaults to false. | <pre>list(object({<br/>    name                 = string<br/>    vnet_id              = string<br/>    registration_enabled = optional(bool, false)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Full resource ID of the Private DNS Zone. |
| <a name="output_name"></a> [name](#output\_name) | Name of the Private DNS Zone. |
| <a name="output_vnet_link_ids"></a> [vnet\_link\_ids](#output\_vnet\_link\_ids) | Map of VNet link names to their resource IDs. |
<!-- END_TF_DOCS -->
