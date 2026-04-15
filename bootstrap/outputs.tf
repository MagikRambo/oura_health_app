output "azure_client_id" {
  value = azuread_application.github_actions.client_id
}

output "azure_client_secret" {
  value     = azuread_service_principal_password.github_actions.value
  sensitive = true
}

output "azure_tenant_id" {
  value = data.azurerm_subscription.current.tenant_id
}

output "azure_subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}
