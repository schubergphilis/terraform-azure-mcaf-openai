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
    time = {
      source  = "hashicorp/time"
      version = ">=0.8.0"
    }
  }

  required_version = ">= 1.10.5"
}
