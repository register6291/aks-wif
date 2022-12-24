resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
}

#Referenced from https://registry.terraform.io/modules/Azure/aks/azurerm/latest 
module "aks" {
  depends_on = [
    null_resource.check_workload_identity_status
  ]
  source                          = "Azure/aks/azurerm"
  version                         = "6.2.0"
  resource_group_name             = azurerm_resource_group.resource_group.name
  prefix                          = var.resource_group_name
  log_analytics_workspace_enabled = false
  oidc_issuer_enabled             = true
  workload_identity_enabled       = true
  location                        = var.location
}

resource "azurerm_user_assigned_identity" "wif_identity" {
  location            = var.location
  name                = var.managed_identity_name
  resource_group_name = azurerm_resource_group.resource_group.name
}


resource "azurerm_key_vault" "keyvault" {
  name                        = var.keyvault_name
  location                    = var.location
  resource_group_name         = azurerm_resource_group.resource_group.name
  enabled_for_disk_encryption = true
  sku_name                    = "standard"
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.wif_identity.principal_id

    secret_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set",
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "Set", "List"
    ]
    storage_permissions = [
      "Get", "Set"
    ]
  }
}

resource "azurerm_key_vault_secret" "secret" {
  name         = "what-is-the-secret"
  value        = "secret-is-wif"
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    annotations = {
      name = var.namespace_name
    }
    name = var.namespace_name
  }
}

resource "kubernetes_service_account" "wif_identity_sa" {
  metadata {
    name        = var.service_account_name
    annotations = { "azure.workload.identity/client-id" : "${azurerm_user_assigned_identity.wif_identity.client_id}" }
    labels      = { "azure.workload.identity/use" : "true" }
    namespace   = var.namespace_name
  }
  depends_on = [
    module.aks, kubernetes_namespace.namespace
  ]
}

resource "azapi_resource" "federated_identity_credential" {
  schema_validation_enabled = false
  name                      = var.federated_identity_credential_name
  parent_id                 = azurerm_user_assigned_identity.wif_identity.id
  type                      = "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2022-01-31-preview"

  location = var.location
  body = jsonencode({
    properties = {
      issuer    = module.aks.oidc_issuer_url
      subject   = "system:serviceaccount:${var.namespace_name}:${var.service_account_name}"
      audiences = ["api://AzureADTokenExchange"]
    }
  })
}

resource "kubectl_manifest" "wif_test_pod" {
  force_new = true
  yaml_body = templatefile("${path.module}/manifest.yaml", { SERVICE_ACCOUNT_NAMESPACE = var.namespace_name, SERVICE_ACCOUNT_NAME = var.service_account_name, KEYVAULT_URL = azurerm_key_vault.keyvault.vault_uri, KEYVAULT_SECRET_NAME = "what-is-the-secret" })
}

