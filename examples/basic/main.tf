terraform {
  required_version = ">= 1.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4"
    }
  }
}

module "azure_openai" {
  source = "git::https://github.com/schubergphilis/terraform-azure-mcaf-openai.git?ref=release-1.0.0"

  name                       = "example"
  location                   = "swedencentral"
  log_analytics_workspace_id = "your-log-analytics-workspace-id"
  resource_group_name        = "your-resource-group"
  resource_group_location    = "your-resource-group-location"
  subnet_id                  = "your-subnet-id"
  virtual_network_id         = "your-virtual-network-id"
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
