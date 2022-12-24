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


