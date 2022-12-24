output "oidc_issuer_url" {
  description = "The OIDC issuer URL that is associated with the cluster."
  value       = module.aks.oidc_issuer_url
  sensitive   = false
}

output "keyvault_uri" {
  value = azurerm_key_vault.keyvault.vault_uri
}