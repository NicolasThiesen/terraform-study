terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.63.0"
    }
  }
  backend "azurerm" {
    # use_cli          = true # Can also be set via `ARM_USE_CLI` environment variable.
    # use_azuread_auth = true # Can also be set via `ARM_USE_AZUREAD` environment variable.
    # tenant_id            = "00000000-0000-0000-0000-000000000000" # Can also be set via `ARM_TENANT_ID` environment variable. Azure CLI will fallback to use the connected tenant ID if not supplied.
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstateexamples"            # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
    container_name       = "tfstate"                    # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
    key                  = "azure-vm/terraform.tfstate" # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
  }
}

provider "azurerm" {
  features {}
}

data "terraform_remote_state" "vnet" {

  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstateexamples"              # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
    container_name       = "tfstate"                      # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
    key                  = "azure-vnet/terraform.tfstate" # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
  }
}