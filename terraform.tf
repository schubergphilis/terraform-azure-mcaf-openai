terraform {
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

  required_version = "~> 1.9"
}
