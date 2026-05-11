terraform {
  required_version = ">= 1.10.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.16"
    }

    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.2"
    }
  }
}

provider "azurerm" {
  features {}
}

module "azure_openai" {
  source = "../.."

  name                = "example"
  location            = "swedencentral"
  resource_group_name = "your-resource-group"
  models = {
    gpt-4o-mini = {
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
