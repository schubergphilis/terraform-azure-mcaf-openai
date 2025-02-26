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

## Input Variables

| Name                         | Description                                                                                                                                                                                                                                                                                                                                | Type                                                                                                                                                                            | Default                            |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| `content_filters`            | (Optional) List of content filters for the OpenAI content policy. If not set, defaults to a pre-defined list.                                                                                                                                                                                                                              | `list(map(any))`                                                                                                                                                                | See variables.tf for default value |
| `create_private_endpoint`    | (Optional) Boolean flag to control whether this module creates a private endpoint. Set to false if you're managing private endpoints outside of this module.                                                                                                                                                                               | `bool`                                                                                                                                                                          | `true`                             |
| `enable_public_access`       | (Optional) Boolean flag to enable or disable public network access.                                                                                                                                                                                                                                                                        | `bool`                                                                                                                                                                          | `false`                            |
| `encryption_key_id`          | (Optional) key vault key id for encryption. If not provided, the module will use a managed encryption key.                                                                                                                                                                                                                                 | `string`                                                                                                                                                                        | `null`                             |
| `location`                   | The location for the Azure OpenAI resources.                                                                                                                                                                                                                                                                                               | `string`                                                                                                                                                                        | n/a                                |
| `log_analytics_workspace_id` | The ID of the Log Analytics workspace for diagnostics.                                                                                                                                                                                                                                                                                     | `string`                                                                                                                                                                        | n/a                                |
| `models`                     | A map of Azure OpenAI models to be deployed. Each model should specify dynamic throttling, model information, and scale settings. **Make sure your subscription has the quotas to deploy what you request in the model config** (https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/quota?source=recommendations&tabs=rest) | `map(object({ enable_dynamic_throttling = bool, model = object({ name = string, version = string, format = string }), scale = object({ type = string, capacity = number }) }))` | n/a                                |
| `name`                       | A prefix to be appended to resource names for uniqueness.                                                                                                                                                                                                                                                                                  | `string`                                                                                                                                                                        | n/a                                |
| `private_ip_address`         | (Optional) Static IP for the private endpoint. Only used when `create_private_endpoint` is true.                                                                                                                                                                                                                                           | `string`                                                                                                                                                                        | `null`                             |
| `resource_group_location`    | The location for the resource group. This can be different from the Azure OpenAI location.                                                                                                                                                                                                                                                 | `string`                                                                                                                                                                        | n/a                                |
| `resource_group_name`        | The name of the resource group.                                                                                                                                                                                                                                                                                                            | `string`                                                                                                                                                                        | n/a                                |
| `sku`                        | The SKU for the Azure OpenAI resource.                                                                                                                                                                                                                                                                                                     | `string`                                                                                                                                                                        | `"S0"`                             |
| `subnet_id`                  | The ID of the subnet where the private endpoint will be deployed. Only required when `create_private_endpoint` is true.                                                                                                                                                                                                                    | `string`                                                                                                                                                                        | `null`                             |
| `trusted_ips`                | (Optional) List of trusted IP addresses for network access. Only needed when `enable_public_access` is set to `true`.                                                                                                                                                                                                                      | `list(string)`                                                                                                                                                                  | `[]`                               |
| `virtual_network_id`         | The ID of the virtual network where the private endpoint will be deployed. Only required when `create_private_endpoint` is true.                                                                                                                                                                                                           | `string`                                                                                                                                                                        | `null`                             |

## Output Values

| Name                         | Description                                                                  |
| ---------------------------- | ---------------------------------------------------------------------------- |
| `cognitive_account_endpoint` | The endpoint of the Azure OpenAI cognitive account.                          |
| `cognitive_account_id`       | ID of the OpenAI cognitive account.                                          |
| `cognitive_account_name`     | Name of the OpenAI cognitive account.                                        |
| `private_endpoint_id`        | The ID of the private endpoint (null if `create_private_endpoint` is false). |
| `private_dns_zone_id`        | The ID of the private DNS zone (null if `create_private_endpoint` is false). |

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

