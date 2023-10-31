/*

The following links provide the documentation for the new blocks used
in this terraform configuration file

1. azurerm_resource_group - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group

*/

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.8.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "a298e774-396b-4cd5-a5ef-f9cc25830e5f"
  client_id       = "6d85898b-1376-4762-a2ec-0e1903c4abc9"
  client_secret   = "7a3e7e6a-ddc5-4614-9272-cb938c2349f2"
  tenant_id       = "16b3c013-d300-468d-ac64-7eda0820b6d3"
  features {}
}

# Configure the GitHub Provider
provider "github" {
  token = "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"
}

resource "github_repository" "example" {
  name        = "example"
  description = "My awesome codebase"

  visibility = "public"
}
provider "azurerm" {
  features {
    key_vault {
      purge_soft_deleted_keys_on_destroy = true
      recover_soft_deleted_keys          = true
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_key_vault" "example" {
  name                       = "examplekeyvault"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Delete",
      "Get",
      "Purge",
      "Recover",
      "Update",
      "GetRotationPolicy",
      "SetRotationPolicy"
    ]

    secret_permissions = [
      "Set",
    ]
  }
}

resource "azurerm_key_vault_key" "generated" {
  name         = "generated-certificate"
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }

    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }
}