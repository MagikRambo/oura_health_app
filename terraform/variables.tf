variable "resource_group_name" {
  description = "Resource group for the AKS cluster"
  default     = "mike-dev-rg"
}

variable "location" {
  description = "Azure region"
  default     = "East US"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  default     = "mike-dev-aks"
}

variable "acr_resource_group_name" {
  description = "Resource group that contains your ACR (magikrambo). Defaults to resource_group_name if left blank."
  default     = ""
}
