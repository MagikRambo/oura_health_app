resource "azurerm_resource_group" "tfstate" {
  name     = "mike-dev-tfstate-rg"
  location = "East US"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "mikedevtfstate"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate" {
  name                 = "tfstate"
  storage_account_name = azurerm_storage_account.tfstate.name
}
