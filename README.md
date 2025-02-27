# Terraform Azure MCAF OpenAI Module

This module streamlines the deployment of Azure OpenAI resources using Terraform. It provisions essential infrastructure components—including an Azure Cognitive Services account configured for OpenAI, private endpoints with secure network integration, encryption(by default will use Azure managed encryption key and optional customer-managed encryption key), and diagnostic monitoring via a Log Analytics workspace—ensuring a secure, scalable, and production-ready environment.

## Usage

To use this module there are a few prerequisites:

- An active Azure subscription.
- Appropriate permissions to deploy and manage Azure resources such as Cognitive Accounts, Key Vaults, Private Endpoints, and DNS Zones.
- An existing resource group (its name must be provided via the `resource_group_name` variable).
- If creating a private endpoint (`create_private_endpoint = true`):
  - An existing virtual network (its ID must be provided via the `virtual_network_id` variable).
  - An existing subnet (its ID must be provided via the `subnet_id` variable).
  - Optional dedicated private IP address for the private endpoint (via the `private_ip_address` variable). If no static IP is specified, the module will assign a dynamic IP.
- An encryption key is required. If you do not provide an external key via the `encryption_key_id` variable, the module will use an Azure managed encryption key.
- A Log Analytics workspace (its ID must be provided via the `log_analytics_workspace_id` variable) for diagnostics.

## Examples

### Basic Example with Private Endpoint

```hcl
module "azure_openai" {
  source                    = "./terraform-azure-mcaf-azureopenai"

  name                      = "example"
  location                  = "swedencentral"
  log_analytics_workspace_id= "your-log-analytics-workspace-id"
  resource_group_name       = "your-resource-group"
  resource_group_location   = "your-resource-group-location"
  subnet_id                 = "your-subnet-id"
  virtual_network_id        = "your-virtual-network-id"
  models = {
        gpt-4o-mini = {
            version_upgrade_option    = "NoAutoUpgrade"
            enable_dynamic_throttling = true

            model = {
                format  = "OpenAI"
                name    = "gpt-4o-mini"
                version = "2024-07-18"
            }

            scale = {
                type     = "Standard"
                capacity = 5
            }
        },
    }
  // Optionally override the default content filters
  // content_filters = [...]
}
```

### Example with Custom Private Endpoint

```hcl
module "azure_openai" {
  source                    = "./terraform-azure-mcaf-azureopenai"

  name                      = "example"
  location                  = "swedencentral"
  log_analytics_workspace_id= "your-log-analytics-workspace-id"
  resource_group_name       = "your-resource-group"
  resource_group_location   = "your-resource-group-location"

  // Disable private endpoint creation in this module
  create_private_endpoint   = false

  models = {
    // Model definitions as above
  }
}

// Create your own private endpoint elsewhere
resource "azurerm_private_endpoint" "custom_openai_endpoint" {
  name                = "custom-openai-endpoint"
  location            = "your-location"
  resource_group_name = "your-resource-group"
  subnet_id           = "your-subnet-id"

  private_service_connection {
    name                           = "custom-openai-connection"
    is_manual_connection           = false
    private_connection_resource_id = module.azure_openai.cognitive_account_id
    subresource_names              = ["account"]
  }

  // Add your custom DNS zone group configuration here
}
```

## License

This module is licensed under the MIT License. See the LICENSE file for more details.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.5 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.16 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 2.2 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.16 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.content_filters](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_cognitive_account.openai](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account) | resource |
| [azurerm_cognitive_account_customer_managed_key.oai_cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account_customer_managed_key) | resource |
| [azurerm_cognitive_deployment.models](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_deployment) | resource |
| [azurerm_monitor_diagnostic_setting.openaidiag](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_dns_zone.openaidns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.vnetopenaidnslink](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.openaipep](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.cognitive_crypto_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The location for the Azure OpenAI resources. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | The ID of the Log Analytics workspace for diagnostics. | `string` | n/a | yes |
| <a name="input_models"></a> [models](#input\_models) | A map of Azure OpenAI models to be deployed. Each model should specify dynamic throttling, model information, and scale settings. | <pre>map(object({<br/>    enable_dynamic_throttling = bool<br/>    model = object({<br/>      name    = string<br/>      version = string<br/>      format  = string<br/>    })<br/>    scale = object({<br/>      type     = string<br/>      capacity = number<br/>    })<br/>  }))</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | A prefix to be appended to resource names for uniqueness. | `string` | n/a | yes |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | The location for the resource group. This can be different from the Azure OpenAI location. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet where the private endpoint will be deployed. Only required when `create_private_endpoint` is true. | `string` | n/a | yes |
| <a name="input_virtual_network_id"></a> [virtual\_network\_id](#input\_virtual\_network\_id) | The ID of the virtual network where the private endpoint will be deployed. Only required when `create_private_endpoint` is true. | `string` | n/a | yes |
| <a name="input_allowed_fqdns"></a> [allowed\_fqdns](#input\_allowed\_fqdns) | A list of allowed FQDNs for the Azure OpenAI resource. | `list(string)` | <pre>[<br/>  "openai.azure.com"<br/>]</pre> | no |
| <a name="input_content_filters"></a> [content\_filters](#input\_content\_filters) | Optional list of content filters for the OpenAI content policy. If not set, defaults to a pre-defined list. | `list(map(any))` | <pre>[<br/>  {<br/>    "blocking": true,<br/>    "enabled": true,<br/>    "name": "Violence",<br/>    "severityThreshold": "High",<br/>    "source": "Prompt"<br/>  },<br/>  {<br/>    "blocking": true,<br/>    "enabled": true,<br/>    "name": "Violence",<br/>    "severityThreshold": "High",<br/>    "source": "Completion"<br/>  },<br/>  {<br/>    "blocking": true,<br/>    "enabled": true,<br/>    "name": "Hate",<br/>    "severityThreshold": "High",<br/>    "source": "Prompt"<br/>  },<br/>  {<br/>    "blocking": true,<br/>    "enabled": true,<br/>    "name": "Hate",<br/>    "severityThreshold": "High",<br/>    "source": "Completion"<br/>  },<br/>  {<br/>    "blocking": true,<br/>    "enabled": true,<br/>    "name": "Sexual",<br/>    "severityThreshold": "High",<br/>    "source": "Prompt"<br/>  },<br/>  {<br/>    "blocking": true,<br/>    "enabled": true,<br/>    "name": "Sexual",<br/>    "severityThreshold": "High",<br/>    "source": "Completion"<br/>  },<br/>  {<br/>    "blocking": true,<br/>    "enabled": true,<br/>    "name": "Selfharm",<br/>    "severityThreshold": "High",<br/>    "source": "Prompt"<br/>  },<br/>  {<br/>    "blocking": true,<br/>    "enabled": true,<br/>    "name": "Selfharm",<br/>    "severityThreshold": "High",<br/>    "source": "Completion"<br/>  },<br/>  {<br/>    "blocking": true,<br/>    "enabled": true,<br/>    "name": "Jailbreak",<br/>    "source": "Prompt"<br/>  },<br/>  {<br/>    "blocking": true,<br/>    "enabled": true,<br/>    "name": "Jailbreak",<br/>    "source": "Completion"<br/>  },<br/>  {<br/>    "blocking": true,<br/>    "enabled": true,<br/>    "name": "Indirect Attack",<br/>    "source": "Prompt"<br/>  },<br/>  {<br/>    "blocking": true,<br/>    "enabled": true,<br/>    "name": "Indirect Attack",<br/>    "source": "Completion"<br/>  },<br/>  {<br/>    "blocking": true,<br/>    "enabled": true,<br/>    "name": "Protected Material Text",<br/>    "source": "Prompt"<br/>  },<br/>  {<br/>    "blocking": true,<br/>    "enabled": true,<br/>    "name": "Protected Material Text",<br/>    "source": "Completion"<br/>  },<br/>  {<br/>    "blocking": true,<br/>    "enabled": true,<br/>    "name": "Protected Material Code",<br/>    "source": "Prompt"<br/>  },<br/>  {<br/>    "blocking": false,<br/>    "enabled": true,<br/>    "name": "Protected Material Code",<br/>    "source": "Completion"<br/>  }<br/>]</pre> | no |
| <a name="input_create_private_endpoint"></a> [create\_private\_endpoint](#input\_create\_private\_endpoint) | Optional boolean flag to control whether this module creates a private endpoint. Set to false if you're managing private endpoints outside of this module. | `bool` | `true` | no |
| <a name="input_enable_public_access"></a> [enable\_public\_access](#input\_enable\_public\_access) | Optional boolean flag to enable or disable public network access. | `bool` | `false` | no |
| <a name="input_encryption_key_id"></a> [encryption\_key\_id](#input\_encryption\_key\_id) | Optional key vault key ID to use for encryption. If not provided, the module will use a managed encryption key. | `string` | `null` | no |
| <a name="input_private_ip_address"></a> [private\_ip\_address](#input\_private\_ip\_address) | Optional static IP for the private endpoint. Only used when `create_private_endpoint` is true. | `string` | `null` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU for the Azure OpenAI resource. | `string` | `"S0"` | no |
| <a name="input_trusted_ips"></a> [trusted\_ips](#input\_trusted\_ips) | Optional list of trusted IP addresses for network access. Only needed when `enable_public_access` is set to `true`. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cognitive_account_endpoint"></a> [cognitive\_account\_endpoint](#output\_cognitive\_account\_endpoint) | The endpoint of the Azure OpenAI cognitive account. |
| <a name="output_cognitive_account_id"></a> [cognitive\_account\_id](#output\_cognitive\_account\_id) | ID of the OpenAI cognitive account. |
| <a name="output_cognitive_account_name"></a> [cognitive\_account\_name](#output\_cognitive\_account\_name) | Name of the OpenAI cognitive account. |
| <a name="output_private_dns_zone_id"></a> [private\_dns\_zone\_id](#output\_private\_dns\_zone\_id) | The ID of the private DNS zone (null if create\_private\_endpoint is false). |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | The ID of the private endpoint (null if create\_private\_endpoint is false). |
<!-- END_TF_DOCS -->
