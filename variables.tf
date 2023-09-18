variable "resource_group_name" {
  type    = string
  default = "wif"
}

variable "location" {
  type    = string
  default = "East US"
}

variable "managed_identity_name" {
  type    = string
  default = "wif-identity"
}

variable "keyvault_name" {
  type    = string
  default = "keyvault-wif"
}

variable "namespace_name" {
  type    = string
  default = "wif-ns"
}

variable "service_account_name" {
  type    = string
  default = "wif-identity-sa"
}

variable "federated_identity_credential_name" {
  type    = string
  default = "wif-federated-identity"
}

variable "sku_tier" {
  type        = string
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid"
  default     = "Free"
}

variable "os_disk_size_gb" {
  type        = number
  description = "Disk size of nodes in GBs."
  default     = 50
}

variable "agents_size" {
  type        = string
  description = "The default virtual machine size for the Kubernetes agents"
  default     = "Standard_D2s_v3"
}

