terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.23.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "ca4cfa9e-d1dd-4217-929b-dd2904fa41f2"
}
