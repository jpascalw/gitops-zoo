terraform {
  backend "azurerm" {
    key                  = "gitopszoo.terraform.tfstate"
  }
}