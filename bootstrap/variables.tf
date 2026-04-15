variable "op_service_account_token" {
  description = "1Password Service Account token"
  type        = string
  sensitive   = true
}

variable "op_vault_name" {
  description = "Name of the 1Password vault to store Azure credentials"
  type        = string
  default     = "dev"
}
