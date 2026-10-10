package test

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func azureJSON(t *testing.T, args ...string) map[string]interface{} {
	t.Helper()
	output, err := exec.Command("az", append(args, "--output", "json")...).CombinedOutput()
	require.NoError(t, err, string(output))
	var result map[string]interface{}
	require.NoError(t, json.Unmarshal(output, &result))
	return result
}

func TestExamples(t *testing.T) {
	if os.Getenv("STR272_RUN_AZURE_TESTS") != "true" {
		t.Skip("Set STR272_RUN_AZURE_TESTS=true to deploy test DNS zones and links")
	}
	required := []string{"ARM_SUBSCRIPTION_ID", "STR272_DNS_RESOURCE_GROUP", "STR272_VNET_NAME", "STR272_VNET_RESOURCE_GROUP"}
	for _, key := range required {
		require.NotEmpty(t, os.Getenv(key), "Missing %s", key)
	}
	environment := os.Getenv("ARM_ENVIRONMENT")
	if environment == "" {
		environment = "usgovernment"
	}
	vnet := azureJSON(t, "network", "vnet", "show", "--subscription", os.Getenv("ARM_SUBSCRIPTION_ID"), "--resource-group", os.Getenv("STR272_VNET_RESOURCE_GROUP"), "--name", os.Getenv("STR272_VNET_NAME"))
	expectedVNet := vnet["id"].(string)
	for _, example := range []string{"basic", "complete"} {
		t.Run(example, func(t *testing.T) {
			// A unique namespace prevents collisions with service zones managed elsewhere.
			suffix := fmt.Sprintf("str272-%d", time.Now().UnixNano())
			vars := map[string]interface{}{
				"subscription_id": os.Getenv("ARM_SUBSCRIPTION_ID"), "environment": environment,
				"vnet_name": os.Getenv("STR272_VNET_NAME"), "vnet_resource_group_name": os.Getenv("STR272_VNET_RESOURCE_GROUP"),
			}
			names := []string{"vaultcore.usgovcloudapi.net", "blob.core.usgovcloudapi.net", "file.core.usgovcloudapi.net", "azurecr.us", "oms.opinsights.azure.us", "monitor.azure.us", "usgovvirginia.azmk8s.io"}
			if example == "basic" {
				vars["name"] = "privatelink." + suffix + "." + names[0]
				vars["resource_group_name"] = os.Getenv("STR272_DNS_RESOURCE_GROUP")
			} else {
				zones := map[string]interface{}{}
				for i, name := range names {
					zones[fmt.Sprintf("zone%d", i)] = map[string]interface{}{"name": "privatelink." + suffix + "." + name, "resource_group_name": os.Getenv("STR272_DNS_RESOURCE_GROUP")}
				}
				vars["private_dns_zones"] = zones
			}
			dir, err := filepath.Abs(filepath.Join("..", "examples", example))
			require.NoError(t, err)
			options := &terraform.Options{TerraformDir: dir, Vars: vars, NoColor: true}
			// Cleanup only resources in this test's Terraform state, including on assertion failure.
			defer terraform.Destroy(t, options)
			terraform.InitAndApply(t, options)
			var zones []map[string]interface{}
			if example == "basic" {
				zones = append(zones, map[string]interface{}{"id": terraform.Output(t, options, "id"), "name": terraform.Output(t, options, "name"), "vnet_link_ids": terraform.OutputMap(t, options, "vnet_link_ids")})
			} else {
				var outputs map[string]map[string]interface{}
				require.NoError(t, json.Unmarshal([]byte(terraform.OutputJson(t, options, "zones")), &outputs))
				require.Len(t, outputs, 7)
				for _, zone := range outputs {
					zones = append(zones, zone)
				}
			}
			for _, zone := range zones {
				actual := azureJSON(t, "resource", "show", "--ids", zone["id"].(string))
				require.Equal(t, zone["name"], actual["name"])
				links := map[string]string{}
				encoded, err := json.Marshal(zone["vnet_link_ids"])
				require.NoError(t, err)
				require.NoError(t, json.Unmarshal(encoded, &links))
				require.Len(t, links, 1)
				for linkName, id := range links {
					require.True(t, strings.Contains(strings.ToLower(id), "/virtualnetworklinks/"+strings.ToLower(linkName)))
					actualLink := azureJSON(t, "resource", "show", "--ids", id)
					props := actualLink["properties"].(map[string]interface{})
					require.Equal(t, strings.ToLower(expectedVNet), strings.ToLower(props["virtualNetwork"].(map[string]interface{})["id"].(string)))
					require.Equal(t, false, props["registrationEnabled"])
				}
			}
		})
	}
}
