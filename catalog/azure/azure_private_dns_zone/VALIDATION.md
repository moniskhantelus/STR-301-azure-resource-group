# STR-272 acceptance and validation

Checked on 2026-10-10 using Terraform 1.9.8, AzureRM 4.81.0, terraform-docs 0.19.0 and Go 1.23.12.

| Acceptance criterion | Implementation / evidence | Status |
|---|---|---|
| Standard child-module directory layout | All files listed in the attached story, including data.tf, examples, test/go.sum and architecture files | Implemented against supplied layout; internal playbook inaccessible |
| Variables have type, description, validation | variables.tf and both example variable files | Implemented |
| Valid privatelink format | DNS-label syntax and length checks | Implemented; runtime tests blocked |
| Valid VNet IDs | Resource type path and subscription UUID checks, plus duplicate checks | Implemented; runtime tests blocked |
| registration_enabled defaults false | optional(bool, false) | Implemented |
| Links use for_each | locals.vnet_links keyed by link.name | Implemented |
| README generated using terraform-docs | Actual terraform-docs command completed; generated reference embedded | Passed |
| Keep a Changelog | CHANGELOG.md with 1.0.0 entry | Implemented |
| Basic / complete examples | Both initialized; editable terraform.tfvars and existing VNet data sources included | Azure deployment pending |
| Terratest passes all examples | Integration test applies both examples and queries Azure to check zone/link association | Compiled; deployment tests skipped, not passed |
| SemVer v1.0.0 tag | VERSION and changelog prepared; release commands below | Remote tag pending |
| No networking resources created | Only resource blocks are azurerm_private_dns_zone and azurerm_private_dns_zone_virtual_network_link | Static inspection passed |
| Terraform formatting | terraform fmt -check -recursive | Passed |
| Terraform validate / mocked tests | Attempted; provider startup failed: listen unix /tmp/plugin*: socket: operation not permitted | Blocked by runtime; no validation pass claimed |

One example validation attempt also reported a cached provider checksum mismatch. Provider caches are excluded from the deliverable. On a clean checkout run `terraform init` to install verified provider packages before validation. Provider lock files are included.

## Required checks in your test environment

1. Edit the example terraform.tfvars placeholders with your subscription and existing resources. Match the Azure CLI cloud to the provider environment.
2. Run `terraform init`, `terraform validate`, and `terraform plan` in both examples. Do not apply both examples to the same production Key Vault zone; they are alternatives.
3. Run `terraform test` at the module root with Terraform >=1.7. This exercises valid links, omitted links, false registration defaults, invalid names, malformed IDs, duplicate VNets, invalid resource groups and tags.
4. Run the opt-in Terratest suite with a dedicated test resource group and VNet as documented in test/README.md. It uses unique test zone names and destroys its resources.
5. Confirm real service DNS resolution from the linked VNet after the separate private endpoint deployment creates DNS records. That integration lies outside this DNS-only module.
6. After review and passing deployment tests, commit and create the release tag in your repository:

```bash
git tag -a v1.0.0 -m "STR-272: Azure Private DNS Zone module"
git push origin v1.0.0
```

No Azure resources were deployed or destroyed during package creation. No remote Git tag was created.
