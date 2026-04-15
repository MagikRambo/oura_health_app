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

# Service Principal for GitHub Actions
data "azurerm_subscription" "current" {}

resource "azuread_application" "github_actions" {
  display_name = "github-actions-oura"
}

resource "azuread_service_principal" "github_actions" {
  client_id = azuread_application.github_actions.client_id
}

resource "azuread_service_principal_password" "github_actions" {
  service_principal_id = azuread_service_principal.github_actions.id
}

resource "azurerm_role_assignment" "github_actions_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github_actions.object_id
}

# Store Azure credentials in 1Password
data "onepassword_vault" "main" {
  name = var.op_vault_name
}

resource "onepassword_item" "azure_credentials" {
  vault = data.onepassword_vault.main.uuid
  title = "Azure Service Principal - GitHub Actions"
  category = "login"

  section {
    label = "Azure Credentials"

    field {
      label = "AZURE_CLIENT_ID"
      value = azuread_application.github_actions.client_id
      type  = "CONCEALED"
    }

    field {
      label = "AZURE_CLIENT_SECRET"
      value = azuread_service_principal_password.github_actions.value
      type  = "CONCEALED"
    }

    field {
      label = "AZURE_TENANT_ID"
      value = data.azurerm_subscription.current.tenant_id
      type  = "CONCEALED"
    }

    field {
      label = "AZURE_SUBSCRIPTION_ID"
      value = data.azurerm_subscription.current.subscription_id
      type  = "CONCEALED"
    }
  }
}
