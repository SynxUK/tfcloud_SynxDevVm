terraform {
  cloud {
    organization = "SynxUK75"
    workspaces {
      name = "tfcloud_SynxDevVm"
    }
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.95.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}


