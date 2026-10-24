resource "azurerm_resource_group" "resource_groups_rg_ignixcommsuite_prod0" {
  location = "brazilsouth"
  name     = "rg-ignixcommsuite-prod"
  tags = {
    app         = "ignix"
    environment = "prod"
    managedBy   = "bicep"
  }
}
resource "azurerm_container_app" "container_apps_ca_planos_api_prod0" {
  container_app_environment_id = azurerm_container_app_environment.managed_environments_cae_planos_prod0.id
  max_inactive_revisions       = 100
  name                         = "ca-planos-api-prod"
  resource_group_name          = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"
  identity {
    identity_ids = [azurerm_user_assigned_identity.user_assigned_identities_mi_planos_api_prod0.id]
    type         = "UserAssigned"
  }
  ingress {
    external_enabled = true
    target_port      = 8000
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
  registry {
    identity = "/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/resourceGroups/rg-ignixcommsuite-prod/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-planos-api-prod"
    server   = "ignixacrprod.azurecr.io"
  }
  secret {
    identity            = "/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/resourceGroups/rg-ignixcommsuite-prod/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-planos-api-prod"
    key_vault_secret_id = "https://kv-ignix-prod.vault.azure.net/secrets/gemini-api-key/dd2041ed0c764fd58c2116d94def511e"
    name                = "gemini-api-key"
  }
  secret {
    identity            = "/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/resourceGroups/rg-ignixcommsuite-prod/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-planos-api-prod"
    key_vault_secret_id = "https://kv-ignix-prod.vault.azure.net/secrets/pid-extraction-centria-api-token/2e7a569c833843fda830e75114152b75"
    name                = "centria-api-token"
  }
  secret {
    identity            = "/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/resourceGroups/rg-ignixcommsuite-prod/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-planos-api-prod"
    key_vault_secret_id = "https://kv-ignix-prod.vault.azure.net/secrets/pid-extraction-internal-token/eb1740f1b972438ca8b1f9d540293a51"
    name                = "internal-api-token"
  }
  secret {
    identity            = "/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/resourceGroups/rg-ignixcommsuite-prod/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-planos-api-prod"
    key_vault_secret_id = "https://kv-ignix-prod.vault.azure.net/secrets/pid-sync-schedule-token/a7a8bd830db047e5871df4d0a3d426b4"
    name                = "sync-schedule-token"
  }
  template {
    max_replicas = 2
    container {
      cpu    = 1
      image  = "ignixacrprod.azurecr.io/planos-api:main-6718cf8"
      memory = "2Gi"
      name   = "ca-planos-api-prod"
      env {
        name  = "STORAGE_BACKEND"
        value = "azure"
      }
      env {
        name  = "AZURE_STORAGE_ACCOUNT_NAME"
        value = "stplanospidprod"
      }
      env {
        name  = "AZURE_BLOB_CONTAINER_NAME"
        value = "planos"
      }
      env {
        name  = "AZURE_QUEUE_NAME"
        value = "planos-worker-jobs"
      }
      env {
        name        = "GEMINI_API_KEY"
        secret_name = "gemini-api-key"
      }
      env {
        name  = "AUTH_REQUIRED"
        value = "true"
      }
      env {
        name  = "ALLOWED_ORIGINS"
        value = "https://ca-planos-web-prod.yellowpebble-b1f7b858.brazilsouth.azurecontainerapps.io"
      }
      env {
        name  = "GEMINI_TIMEOUT_SEC"
        value = "180"
      }
      env {
        name  = "ENABLE_LEGACY_EXTRACT"
        value = "false"
      }
      env {
        name  = "AZURE_CLIENT_ID"
        value = "4117d2bb-abac-4195-afd3-fb24f1521356"
      }
      env {
        name        = "INTERNAL_API_TOKEN"
        secret_name = "internal-api-token"
      }
      env {
        name  = "CENTRIA_BASE_URL"
        value = "https://centria.tools.sparkgy.com"
      }
      env {
        name        = "PID_EXTRACTION_SERVICE_TOKEN"
        secret_name = "centria-api-token"
      }
      env {
        name        = "PID_SYNC_SCHEDULE_TOKEN"
        secret_name = "sync-schedule-token"
      }
    }
  }
}
resource "azurerm_container_app" "container_apps_ca_planos_api_stage0" {
  container_app_environment_id = azurerm_container_app_environment.managed_environments_cae_planos_stage0.id
  name                         = "ca-planos-api-stage"
  resource_group_name          = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  revision_mode                = "Single"
  tags = {
    environment = "stage"
    managedBy   = "bicep"
    system      = "pid"
  }
  workload_profile_name = "Consumption"
  identity {
    identity_ids = [azurerm_user_assigned_identity.user_assigned_identities_mi_planos_api_stage0.id]
    type         = "UserAssigned"
  }
  ingress {
    external_enabled = true
    target_port      = 8000
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "20.206.176.11/32"
      name             = "centria-stage-1"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "20.206.176.27/32"
      name             = "centria-stage-2"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.200.172/32"
      name             = "centria-stage-3"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.200.176/32"
      name             = "centria-stage-4"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.200.184/32"
      name             = "centria-stage-5"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.200.190/32"
      name             = "centria-stage-6"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.200.218/32"
      name             = "centria-stage-7"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.200.224/32"
      name             = "centria-stage-8"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.200.252/32"
      name             = "centria-stage-9"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.200.255/32"
      name             = "centria-stage-10"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.0/32"
      name             = "centria-stage-11"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.153/32"
      name             = "centria-stage-12"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.156/32"
      name             = "centria-stage-13"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.161/32"
      name             = "centria-stage-14"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.168/32"
      name             = "centria-stage-15"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.17/32"
      name             = "centria-stage-16"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.217/32"
      name             = "centria-stage-17"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.224/32"
      name             = "centria-stage-18"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.246/32"
      name             = "centria-stage-19"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.248/32"
      name             = "centria-stage-20"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.8/32"
      name             = "centria-stage-21"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.91/32"
      name             = "centria-stage-22"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.173/32"
      name             = "centria-stage-23"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.184/32"
      name             = "centria-stage-24"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.187/32"
      name             = "centria-stage-25"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.21/32"
      name             = "centria-stage-26"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.221/32"
      name             = "centria-stage-27"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.223/32"
      name             = "centria-stage-28"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.26/32"
      name             = "centria-stage-29"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.3/32"
      name             = "centria-stage-30"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.55/32"
      name             = "centria-stage-31"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.58/32"
      name             = "centria-stage-32"
    }
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
  registry {
    identity = azurerm_user_assigned_identity.user_assigned_identities_mi_planos_api_stage0.id
    server   = "ignixacrprod.azurecr.io"
  }
  secret {
    identity            = azurerm_user_assigned_identity.user_assigned_identities_mi_planos_api_stage0.id
    key_vault_secret_id = "https://kv-ignix-prod.vault.azure.net/secrets/gemini-api-key"
    name                = "gemini-api-key"
  }
  secret {
    identity            = azurerm_user_assigned_identity.user_assigned_identities_mi_planos_api_stage0.id
    key_vault_secret_id = "https://kv-ignix-prod.vault.azure.net/secrets/pid-extraction-staging-centria-api-token"
    name                = "centria-api-token"
  }
  secret {
    identity            = azurerm_user_assigned_identity.user_assigned_identities_mi_planos_api_stage0.id
    key_vault_secret_id = "https://kv-ignix-prod.vault.azure.net/secrets/pid-extraction-staging-internal-token"
    name                = "internal-api-token"
  }
  secret {
    identity            = azurerm_user_assigned_identity.user_assigned_identities_mi_planos_api_stage0.id
    key_vault_secret_id = "https://kv-ignix-prod.vault.azure.net/secrets/pid-staging-sync-schedule-token"
    name                = "sync-schedule-token"
  }
  template {
    max_replicas = 2
    container {
      cpu    = 1
      image  = "ignixacrprod.azurecr.io/planos-api:main-caa4c6b"
      memory = "2Gi"
      name   = "api"
      env {
        name  = "STORAGE_BACKEND"
        value = "azure"
      }
      env {
        name  = "AZURE_STORAGE_ACCOUNT_NAME"
        value = "stplanospidstage"
      }
      env {
        name  = "AZURE_BLOB_CONTAINER_NAME"
        value = "planos"
      }
      env {
        name  = "AZURE_QUEUE_NAME"
        value = "planos-worker-jobs"
      }
      env {
        name        = "GEMINI_API_KEY"
        secret_name = "gemini-api-key"
      }
      env {
        name  = "AUTH_REQUIRED"
        value = "true"
      }
      env {
        name  = "ALLOWED_ORIGINS"
        value = "https://centria-staging-lmkezpwwqjch2.azurewebsites.net"
      }
      env {
        name  = "GEMINI_TIMEOUT_SEC"
        value = "180"
      }
      env {
        name  = "ENABLE_LEGACY_EXTRACT"
        value = "false"
      }
      env {
        name  = "AZURE_CLIENT_ID"
        value = "f596d3f7-132d-49ff-be98-384be121ab26"
      }
      env {
        name        = "INTERNAL_API_TOKEN"
        secret_name = "internal-api-token"
      }
      env {
        name        = "PID_SYNC_SCHEDULE_TOKEN"
        secret_name = "sync-schedule-token"
      }
      env {
        name  = "CENTRIA_BASE_URL"
        value = "https://centria-staging-lmkezpwwqjch2.azurewebsites.net"
      }
      env {
        name        = "PID_EXTRACTION_SERVICE_TOKEN"
        secret_name = "centria-api-token"
      }
    }
  }
}
resource "azurerm_container_app" "container_apps_ca_planos_web_prod0" {
  container_app_environment_id = azurerm_container_app_environment.managed_environments_cae_planos_prod0.id
  max_inactive_revisions       = 100
  name                         = "ca-planos-web-prod"
  resource_group_name          = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"
  identity {
    identity_ids = [azurerm_user_assigned_identity.user_assigned_identities_mi_planos_api_prod0.id]
    type         = "UserAssigned"
  }
  ingress {
    external_enabled = true
    target_port      = 80
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
  registry {
    identity = "/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/resourceGroups/rg-ignixcommsuite-prod/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-planos-api-prod"
    server   = "ignixacrprod.azurecr.io"
  }
  template {
    max_replicas = 1
    container {
      cpu    = 0.25
      image  = "ignixacrprod.azurecr.io/planos-web:main-6718cf8"
      memory = "0.5Gi"
      name   = "ca-planos-web-prod"
    }
  }
}
resource "azurerm_container_app" "container_apps_ca_planos_web_stage0" {
  container_app_environment_id = azurerm_container_app_environment.managed_environments_cae_planos_stage0.id
  name                         = "ca-planos-web-stage"
  resource_group_name          = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  revision_mode                = "Single"
  tags = {
    environment = "stage"
    managedBy   = "bicep"
    system      = "pid"
  }
  workload_profile_name = "Consumption"
  identity {
    identity_ids = [azurerm_user_assigned_identity.user_assigned_identities_mi_planos_web_stage0.id]
    type         = "UserAssigned"
  }
  ingress {
    external_enabled = true
    target_port      = 80
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "20.206.176.11/32"
      name             = "centria-stage-1"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "20.206.176.27/32"
      name             = "centria-stage-2"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.200.172/32"
      name             = "centria-stage-3"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.200.176/32"
      name             = "centria-stage-4"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.200.184/32"
      name             = "centria-stage-5"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.200.190/32"
      name             = "centria-stage-6"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.200.218/32"
      name             = "centria-stage-7"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.200.224/32"
      name             = "centria-stage-8"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.200.252/32"
      name             = "centria-stage-9"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.200.255/32"
      name             = "centria-stage-10"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.0/32"
      name             = "centria-stage-11"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.153/32"
      name             = "centria-stage-12"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.156/32"
      name             = "centria-stage-13"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.161/32"
      name             = "centria-stage-14"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.168/32"
      name             = "centria-stage-15"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.17/32"
      name             = "centria-stage-16"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.217/32"
      name             = "centria-stage-17"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.224/32"
      name             = "centria-stage-18"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.246/32"
      name             = "centria-stage-19"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.248/32"
      name             = "centria-stage-20"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.8/32"
      name             = "centria-stage-21"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.201.91/32"
      name             = "centria-stage-22"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.173/32"
      name             = "centria-stage-23"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.184/32"
      name             = "centria-stage-24"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.187/32"
      name             = "centria-stage-25"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.21/32"
      name             = "centria-stage-26"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.221/32"
      name             = "centria-stage-27"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.223/32"
      name             = "centria-stage-28"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.26/32"
      name             = "centria-stage-29"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.3/32"
      name             = "centria-stage-30"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.55/32"
      name             = "centria-stage-31"
    }
    ip_security_restriction {
      action           = "Allow"
      description      = "CENTRIA-STAGE possible outbound IP"
      ip_address_range = "74.163.202.58/32"
      name             = "centria-stage-32"
    }
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
  registry {
    identity = azurerm_user_assigned_identity.user_assigned_identities_mi_planos_web_stage0.id
    server   = "ignixacrprod.azurecr.io"
  }
  template {
    max_replicas = 1
    container {
      cpu    = 0.25
      image  = "ignixacrprod.azurecr.io/planos-web:main-caa4c6b"
      memory = "0.5Gi"
      name   = "web"
    }
  }
}
resource "azurerm_container_app" "container_apps_ca_planos_worker_prod0" {
  container_app_environment_id = azurerm_container_app_environment.managed_environments_cae_planos_prod0.id
  max_inactive_revisions       = 100
  name                         = "ca-planos-worker-prod"
  resource_group_name          = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"
  identity {
    identity_ids = [azurerm_user_assigned_identity.user_assigned_identities_mi_planos_worker_prod0.id]
    type         = "UserAssigned"
  }
  registry {
    identity = "/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/resourceGroups/rg-ignixcommsuite-prod/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-planos-worker-prod"
    server   = "ignixacrprod.azurecr.io"
  }
  secret {
    name = "storage-conn"
  }
  secret {
    identity            = "/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/resourceGroups/rg-ignixcommsuite-prod/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-planos-worker-prod"
    key_vault_secret_id = "https://kv-ignix-prod.vault.azure.net/secrets/gemini-api-key/dd2041ed0c764fd58c2116d94def511e"
    name                = "gemini-api-key"
  }
  template {
    max_replicas = 3
    azure_queue_scale_rule {
      name         = "queue-scale"
      queue_length = 1
      queue_name   = "planos-worker-jobs"
      authentication {
        secret_name       = "storage-conn"
        trigger_parameter = "connection"
      }
    }
    container {
      command = ["uvicorn", "backend.worker.main:app"]
      cpu     = 1
      image   = "ignixacrprod.azurecr.io/planos-api:main-6718cf8"
      memory  = "2Gi"
      name    = "ca-planos-worker-prod"
      env {
        name  = "STORAGE_BACKEND"
        value = "azure"
      }
      env {
        name  = "AZURE_STORAGE_ACCOUNT_NAME"
        value = "stplanospidprod"
      }
      env {
        name  = "AZURE_BLOB_CONTAINER_NAME"
        value = "planos"
      }
      env {
        name  = "AZURE_QUEUE_NAME"
        value = "planos-worker-jobs"
      }
      env {
        name        = "GEMINI_API_KEY"
        secret_name = "gemini-api-key"
      }
      env {
        name  = "GEMINI_TIMEOUT_SEC"
        value = "180"
      }
      env {
        name  = "AZURE_CLIENT_ID"
        value = "d57b818c-c489-4239-8a3b-7d1b9d992679"
      }
    }
  }
}
resource "azurerm_container_app" "container_apps_ca_planos_worker_stage0" {
  container_app_environment_id = azurerm_container_app_environment.managed_environments_cae_planos_stage0.id
  name                         = "ca-planos-worker-stage"
  resource_group_name          = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  revision_mode                = "Single"
  tags = {
    environment = "stage"
    managedBy   = "bicep"
    system      = "pid"
  }
  workload_profile_name = "Consumption"
  identity {
    identity_ids = [azurerm_user_assigned_identity.user_assigned_identities_mi_planos_worker_stage0.id]
    type         = "UserAssigned"
  }
  registry {
    identity = azurerm_user_assigned_identity.user_assigned_identities_mi_planos_worker_stage0.id
    server   = "ignixacrprod.azurecr.io"
  }
  secret {
    identity            = azurerm_user_assigned_identity.user_assigned_identities_mi_planos_worker_stage0.id
    key_vault_secret_id = "https://kv-ignix-prod.vault.azure.net/secrets/gemini-api-key"
    name                = "gemini-api-key"
  }
  template {
    max_replicas = 3
    azure_queue_scale_rule {
      name         = "queue-scale"
      queue_length = 1
      queue_name   = "planos-worker-jobs"
      # Azure no trae authentication en esta regla. El provider lo exige para validar.
      authentication {
        secret_name       = "gemini-api-key"
        trigger_parameter = "connection"
      }
    }
    container {
      command = ["uvicorn", "backend.worker.main:app"]
      cpu     = 1
      image   = "ignixacrprod.azurecr.io/planos-api:main-caa4c6b"
      memory  = "2Gi"
      name    = "worker"
      env {
        name  = "STORAGE_BACKEND"
        value = "azure"
      }
      env {
        name  = "AZURE_STORAGE_ACCOUNT_NAME"
        value = "stplanospidstage"
      }
      env {
        name  = "AZURE_BLOB_CONTAINER_NAME"
        value = "planos"
      }
      env {
        name  = "AZURE_QUEUE_NAME"
        value = "planos-worker-jobs"
      }
      env {
        name        = "GEMINI_API_KEY"
        secret_name = "gemini-api-key"
      }
      env {
        name  = "GEMINI_TIMEOUT_SEC"
        value = "180"
      }
      env {
        name  = "AZURE_CLIENT_ID"
        value = "c80dbe6b-e160-4ea5-a85b-7fe1d9479ed3"
      }
    }
  }
  # ignore_changes evita que el authentication agregado arriba se escriba en Azure.
  lifecycle {
    ignore_changes = [template]
  }
}
resource "azurerm_container_app_job" "jobs_janus_job_prod0" {
  container_app_environment_id = azurerm_container_app_environment.managed_environments_cae_janus_prod0.id
  location                     = "brazilsouth"
  name                         = "janus-job-prod"
  replica_timeout_in_seconds   = 3600
  resource_group_name          = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  workload_profile_name        = "Consumption"
  identity {
    identity_ids = [azurerm_user_assigned_identity.user_assigned_identities_mi_janus_job_prod0.id]
    type         = "UserAssigned"
  }
  manual_trigger_config {
  }
  registry {
    identity = azurerm_user_assigned_identity.user_assigned_identities_mi_janus_job_prod0.id
    server   = "ignixacrprod.azurecr.io"
  }
  template {
    container {
      command = ["python", "-m", "janus.proceso.worker"]
      cpu     = 1
      image   = "ignixacrprod.azurecr.io/janus:8bca576e3fa02f80484dbb1ed158cdee26c1c0e3"
      memory  = "2Gi"
      name    = "janus-job"
      env {
        name  = "APP_ENV"
        value = "prod"
      }
      env {
        name  = "CENTRIA_MODULE_CODE"
        value = "janus"
      }
      env {
        name  = "CENTRIA_TENANT_ID"
        value = "cmpncj1tn0002fxekll89x6w8"
      }
      env {
        name  = "JANUS_AZURE_TENANT_ID"
        value = "93a9d1eb-0e13-4963-bc57-a47c548f2690"
      }
      env {
        name  = "JANUS_STORAGE"
        value = "blob"
      }
      env {
        name  = "JANUS_BLOB_URL"
        value = "https://stjanusprod.blob.core.windows.net"
      }
      env {
        name  = "JANUS_BLOB_CONTAINER"
        value = "janus"
      }
      env {
        name  = "JANUS_PUBLIC_URL"
        value = "https://centria.tools.sparkgy.com"
      }
      env {
        name  = "JANUS_MAX_FILE_MB"
        value = "25"
      }
      env {
        name  = "JANUS_MAX_RUN_MB"
        value = "100"
      }
      env {
        name  = "JANUS_MAX_RUN_FILES"
        value = "200"
      }
      env {
        name  = "JANUS_WEB_INTERNAL_URL"
        value = "https://janus-prod-lmkezpwwqjch2.azurewebsites.net"
      }
      env {
        name  = "JANUS_DISK_BUDGET_MB"
        value = "160"
      }
      env {
        name  = "JANUS_MAX_RUN_SECONDS"
        value = "3600"
      }
      env {
        name  = "AZURE_CLIENT_ID"
        value = "25f13624-2f5d-4ee0-bbc4-44f1d8d0448f"
      }
    }
  }
}
resource "azurerm_container_app_job" "jobs_janus_job_staging0" {
  container_app_environment_id = azurerm_container_app_environment.managed_environments_cae_janus_staging0.id
  location                     = "brazilsouth"
  name                         = "janus-job-staging"
  replica_timeout_in_seconds   = 3600
  resource_group_name          = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  workload_profile_name        = "Consumption"
  identity {
    identity_ids = [azurerm_user_assigned_identity.user_assigned_identities_mi_janus_job_staging0.id]
    type         = "UserAssigned"
  }
  manual_trigger_config {
  }
  registry {
    identity = azurerm_user_assigned_identity.user_assigned_identities_mi_janus_job_staging0.id
    server   = "ignixacrprod.azurecr.io"
  }
  template {
    container {
      command = ["python", "-m", "janus.proceso.worker"]
      cpu     = 1
      image   = "ignixacrprod.azurecr.io/janus:19ddd6a29a73be85642fc262ea2de67de4458fe9"
      memory  = "2Gi"
      name    = "janus-job"
      env {
        name  = "APP_ENV"
        value = "staging"
      }
      env {
        name  = "CENTRIA_MODULE_CODE"
        value = "janus"
      }
      env {
        name  = "CENTRIA_TENANT_ID"
        value = "cmpncj1tn0002fxekll89x6w8"
      }
      env {
        name  = "JANUS_AZURE_TENANT_ID"
        value = "93a9d1eb-0e13-4963-bc57-a47c548f2690"
      }
      env {
        name  = "JANUS_STORAGE"
        value = "blob"
      }
      env {
        name  = "JANUS_WEB_INTERNAL_URL"
        value = "https://janus-staging-lmkezpwwqjch2.azurewebsites.net"
      }
      env {
        name  = "JANUS_DISK_BUDGET_MB"
        value = "160"
      }
      env {
        name  = "JANUS_MAX_RUN_SECONDS"
        value = "3600"
      }
      env {
        name  = "AZURE_CLIENT_ID"
        value = "6ffe08a9-e416-4721-81cb-25a7385f84f4"
      }
      env {
        name  = "JANUS_BLOB_URL"
        value = "https://stjanusstaging.blob.core.windows.net"
      }
      env {
        name  = "JANUS_BLOB_CONTAINER"
        value = "janus"
      }
      env {
        name  = "JANUS_PUBLIC_URL"
        value = "https://centria-staging-lmkezpwwqjch2.azurewebsites.net"
      }
      env {
        name  = "JANUS_MAX_FILE_MB"
        value = "50"
      }
      env {
        name  = "JANUS_MAX_RUN_MB"
        value = "100"
      }
      env {
        name  = "JANUS_MAX_RUN_FILES"
        value = "200"
      }
    }
  }
}
resource "azurerm_container_app_environment" "managed_environments_cae_janus_prod0" {
  location                   = "brazilsouth"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspaces_log_ignix_prod0.id
  name                       = "cae-janus-prod"
  resource_group_name        = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
}
resource "azurerm_container_app_environment" "managed_environments_cae_janus_staging0" {
  location                   = "brazilsouth"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspaces_log_ignix_prod0.id
  name                       = "cae-janus-staging"
  resource_group_name        = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
}
resource "azurerm_container_app_environment" "managed_environments_cae_planos_prod0" {
  location                   = "brazilsouth"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspaces_log_ignix_prod0.id
  name                       = "cae-planos-prod"
  resource_group_name        = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
}
resource "azurerm_container_app_environment" "managed_environments_cae_planos_stage0" {
  location                   = "brazilsouth"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspaces_log_ignix_prod0.id
  name                       = "cae-planos-stage"
  resource_group_name        = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  tags = {
    environment = "stage"
    managedBy   = "bicep"
    system      = "pid"
  }
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
}
resource "azurerm_management_lock" "locks_do_not_delete0" {
  lock_level = "CanNotDelete"
  name       = "DoNotDelete"
  scope      = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.id
}
resource "azurerm_role_assignment" "role_assignments_00f1a767_ae17_42ab_981f_03fa55b7b26f0" {
  principal_id       = "3bfafe9a-0a44-424c-b6bf-c5b910ef05df"
  role_definition_id = "/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/providers/Microsoft.Authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f"
  scope              = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.id
}
resource "azurerm_role_assignment" "role_assignments_0f6af586_0633_4d75_82e9_0e05d532186d0" {
  principal_id       = "a2ef6060-e04d-4651-99aa-c485cad876ca"
  role_definition_id = "/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/providers/Microsoft.Authorization/roleDefinitions/f58310d9-a9f6-439a-9e8d-f62e7b41a168"
  scope              = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.id
}
resource "azurerm_role_assignment" "role_assignments_19fd781c_a03d_4241_914e_c33ff80bc0600" {
  principal_id       = "59b2e78d-d90e-4fb1-8ec8-b5744ce6943b"
  role_definition_id = "/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
  scope              = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.id
}
resource "azurerm_role_assignment" "role_assignments_3d72a6f0_e5d7_4bf4_af09_380fa4e8cc010" {
  principal_id       = "1c123df2-87b2-4eb5-be5b-dda16b2a7e86"
  role_definition_id = "/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
  scope              = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.id
}
resource "azurerm_role_assignment" "role_assignments_4863bee6_1870_4dc1_8058_4d1a5fe57d110" {
  principal_id       = "7670e791-c212-40d4-a4bd-b6e00a809b86"
  role_definition_id = "/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
  scope              = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.id
}
resource "azurerm_role_assignment" "role_assignments_74a5d3ea_8b78_4d8a_b467_d80d6b714aa40" {
  principal_id       = "f430c225-15c9-4391-9b1e-c1917697b07f"
  role_definition_id = "/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
  scope              = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.id
}
resource "azurerm_role_assignment" "role_assignments_80083f49_7f69_4aa1_8058_1a6a8bb29cef0" {
  principal_id       = "d8429656-f7c1-4566-86f3-7ae231e9ece3"
  role_definition_id = "/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
  scope              = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.id
}
resource "azurerm_role_assignment" "role_assignments_91584067_59dd_442d_a14a_c4c4157f91c60" {
  principal_id       = "15167d28-4cc8-4a8f-892f-51ffb46af189"
  role_definition_id = "/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
  scope              = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.id
}
resource "azurerm_role_assignment" "role_assignments_97461377_aaf1_486c_9c9a_1040d32112c20" {
  principal_id       = "a2ef6060-e04d-4651-99aa-c485cad876ca"
  role_definition_id = "/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
  scope              = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.id
}
resource "azurerm_role_assignment" "role_assignments_bdc60617_1082_4396_8b2b_4622f1b336b20" {
  principal_id       = "b605a97c-f837-4cfb-a127-4ff543ca3be2"
  role_definition_id = "/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
  scope              = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.id
}
resource "azurerm_communication_service" "communication_services_acs_ignix_prod0" {
  data_location       = "Brazil"
  name                = "acs-ignix-prod"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  # Azure guarda "brazil". El provider solo acepta "Brazil".
  lifecycle {
    ignore_changes = [data_location]
  }
}
resource "azurerm_email_communication_service" "email_services_ecs_ignix_prod0" {
  data_location       = "Brazil"
  name                = "ecs-ignix-prod"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
}
resource "azurerm_email_communication_service_domain" "domains_azure_managed_domain0" {
  domain_management = "AzureManaged"
  email_service_id  = azurerm_email_communication_service.email_services_ecs_ignix_prod0.id
  name              = "AzureManagedDomain"
}
resource "azurerm_email_communication_service_domain" "domains_ignix_sparkgy_com0" {
  domain_management = "CustomerManaged"
  email_service_id  = azurerm_email_communication_service.email_services_ecs_ignix_prod0.id
  name              = "ignix.sparkgy.com"
}
resource "azurerm_email_communication_service_domain" "domains_mail_sparkgy_com0" {
  domain_management = "CustomerManaged"
  email_service_id  = azurerm_email_communication_service.email_services_ecs_ignix_prod0.id
  name              = "mail.sparkgy.com"
}
resource "azurerm_email_communication_service_domain" "domains_mail_tools_sparkgy_com0" {
  domain_management = "CustomerManaged"
  email_service_id  = azurerm_email_communication_service.email_services_ecs_ignix_prod0.id
  name              = "mail.tools.sparkgy.com"
}
resource "azurerm_email_communication_service_domain" "domains_sparkgy_com0" {
  domain_management = "CustomerManaged"
  email_service_id  = azurerm_email_communication_service.email_services_ecs_ignix_prod0.id
  name              = "sparkgy.com"
}
resource "azurerm_container_registry" "registries_ignixacrprod0" {
  admin_enabled       = true
  location            = "brazilsouth"
  name                = "ignixacrprod"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  sku                 = "Basic"
  tags = {
    app         = "ignix"
    environment = "prod"
    managedBy   = "bicep"
  }
}
resource "azurerm_postgresql_flexible_server" "flexible_servers_psql_ignix_prod0" {
  location            = "brazilsouth"
  name                = "psql-ignix-prod"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  tags = {
    app         = "ignix"
    environment = "prod"
    managedBy   = "bicep"
  }
  zone = "2"
}
resource "azurerm_monitor_action_group" "actiongroups_ag_ecosistema_alertas0" {
  name                = "ag-ecosistema-alertas"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  short_name          = "ecoalertas"
  email_receiver {
    email_address = "avalero@sparkgy.com"
    name          = "mail1"
  }
}
resource "azurerm_application_insights" "components_appi_ignix_prod0" {
  application_type    = "web"
  location            = "brazilsouth"
  name                = "appi-ignix-prod"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  sampling_percentage = 0
}
resource "azurerm_application_insights" "components_turecibo_prod_ai0" {
  application_type    = "web"
  location            = "brazilsouth"
  name                = "turecibo-prod-ai"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  sampling_percentage = 0
  tags = {
    contrato = "centria"
    entorno  = "prod"
    modulo   = "turecibo"
  }
}
resource "azurerm_monitor_metric_alert" "metricalerts_eco_asp_sgi_prod_cpu_alta0" {
  auto_mitigate       = false
  description         = "asp-sgi-prod: CPU promedio > 80 % en 15 min. | Creada 11/09/2026 por Andrés Valero (ecosistema, coordinada con CENTRIA). No se puede borrar por el lock CanNotDelete del RG: deshabilitar."
  frequency           = "PT5M"
  name                = "eco-asp-sgi-prod-cpu-alta"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  scopes              = ["/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/resourceGroups/rg-ignixcommsuite-prod/providers/Microsoft.Web/serverfarms/asp-sgi-prod"]
  severity            = 2
  window_size         = "PT15M"
  action {
    action_group_id = "/subscriptions/DC7A59F3-0F26-449C-ADB4-E822FD893336/resourceGroups/rg-ignixcommsuite-prod/providers/microsoft.insights/actionGroups/ag-ecosistema-alertas"
  }
  criteria {
    aggregation      = "Average"
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "CpuPercentage"
    operator         = "GreaterThan"
    threshold        = 80
  }
}
resource "azurerm_monitor_metric_alert" "metricalerts_eco_asp_sgi_prod_memoria_alta0" {
  auto_mitigate       = false
  description         = "asp-sgi-prod: memoria promedio > 85 % en 15 min. | Creada 11/09/2026 por Andrés Valero (ecosistema, coordinada con CENTRIA). No se puede borrar por el lock CanNotDelete del RG: deshabilitar."
  frequency           = "PT5M"
  name                = "eco-asp-sgi-prod-memoria-alta"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  scopes              = ["/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/resourceGroups/rg-ignixcommsuite-prod/providers/Microsoft.Web/serverfarms/asp-sgi-prod"]
  severity            = 2
  window_size         = "PT15M"
  action {
    action_group_id = "/subscriptions/DC7A59F3-0F26-449C-ADB4-E822FD893336/resourceGroups/rg-ignixcommsuite-prod/providers/microsoft.insights/actionGroups/ag-ecosistema-alertas"
  }
  criteria {
    aggregation      = "Average"
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "MemoryPercentage"
    operator         = "GreaterThan"
    threshold        = 85
  }
}
resource "azurerm_monitor_metric_alert" "metricalerts_eco_asp_sgp_prod_cpu_alta0" {
  auto_mitigate       = false
  description         = "asp-sgp-prod: CPU promedio > 80 % en 15 min. | Creada 11/09/2026 por Andrés Valero (ecosistema, coordinada con CENTRIA). No se puede borrar por el lock CanNotDelete del RG: deshabilitar."
  frequency           = "PT5M"
  name                = "eco-asp-sgp-prod-cpu-alta"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  scopes              = ["/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/resourceGroups/rg-ignixcommsuite-prod/providers/Microsoft.Web/serverfarms/asp-sgp-prod"]
  severity            = 2
  window_size         = "PT15M"
  action {
    action_group_id = "/subscriptions/DC7A59F3-0F26-449C-ADB4-E822FD893336/resourceGroups/rg-ignixcommsuite-prod/providers/microsoft.insights/actionGroups/ag-ecosistema-alertas"
  }
  criteria {
    aggregation      = "Average"
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "CpuPercentage"
    operator         = "GreaterThan"
    threshold        = 80
  }
}
resource "azurerm_monitor_metric_alert" "metricalerts_eco_asp_sgp_prod_memoria_alta0" {
  auto_mitigate       = false
  description         = "asp-sgp-prod: memoria promedio > 85 % en 15 min. | Creada 11/09/2026 por Andrés Valero (ecosistema, coordinada con CENTRIA). No se puede borrar por el lock CanNotDelete del RG: deshabilitar."
  frequency           = "PT5M"
  name                = "eco-asp-sgp-prod-memoria-alta"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  scopes              = ["/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/resourceGroups/rg-ignixcommsuite-prod/providers/Microsoft.Web/serverfarms/asp-sgp-prod"]
  severity            = 2
  window_size         = "PT15M"
  action {
    action_group_id = "/subscriptions/DC7A59F3-0F26-449C-ADB4-E822FD893336/resourceGroups/rg-ignixcommsuite-prod/providers/microsoft.insights/actionGroups/ag-ecosistema-alertas"
  }
  criteria {
    aggregation      = "Average"
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "MemoryPercentage"
    operator         = "GreaterThan"
    threshold        = 85
  }
}
resource "azurerm_monitor_metric_alert" "metricalerts_eco_centria_plan_prod_cpu_alta0" {
  auto_mitigate       = false
  description         = "centria-plan-prod: CPU promedio > 80 % en 15 min. | Creada 11/09/2026 por Andrés Valero (ecosistema, coordinada con CENTRIA). No se puede borrar por el lock CanNotDelete del RG: deshabilitar."
  frequency           = "PT5M"
  name                = "eco-centria-plan-prod-cpu-alta"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  scopes              = ["/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/resourceGroups/rg-ignixcommsuite-prod/providers/Microsoft.Web/serverfarms/centria-plan-prod"]
  severity            = 2
  window_size         = "PT15M"
  action {
    action_group_id = "/subscriptions/DC7A59F3-0F26-449C-ADB4-E822FD893336/resourceGroups/rg-ignixcommsuite-prod/providers/microsoft.insights/actionGroups/ag-ecosistema-alertas"
  }
  criteria {
    aggregation      = "Average"
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "CpuPercentage"
    operator         = "GreaterThan"
    threshold        = 80
  }
}
resource "azurerm_monitor_metric_alert" "metricalerts_eco_centria_plan_prod_memoria_alta0" {
  auto_mitigate       = false
  description         = "centria-plan-prod: memoria promedio > 85 % en 15 min. | Creada 11/09/2026 por Andrés Valero (ecosistema, coordinada con CENTRIA). No se puede borrar por el lock CanNotDelete del RG: deshabilitar."
  frequency           = "PT5M"
  name                = "eco-centria-plan-prod-memoria-alta"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  scopes              = ["/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/resourceGroups/rg-ignixcommsuite-prod/providers/Microsoft.Web/serverfarms/centria-plan-prod"]
  severity            = 2
  window_size         = "PT15M"
  action {
    action_group_id = "/subscriptions/DC7A59F3-0F26-449C-ADB4-E822FD893336/resourceGroups/rg-ignixcommsuite-prod/providers/microsoft.insights/actionGroups/ag-ecosistema-alertas"
  }
  criteria {
    aggregation      = "Average"
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "MemoryPercentage"
    operator         = "GreaterThan"
    threshold        = 85
  }
}
resource "azurerm_monitor_metric_alert" "metricalerts_eco_psql_base_caida0" {
  auto_mitigate       = false
  description         = "psql-ignix-prod: la base no responde (is_db_alive=0). También dispara en reinicios planificados. | Creada 11/09/2026 por Andrés Valero (ecosistema, coordinada con CENTRIA). No se puede borrar por el lock CanNotDelete del RG: deshabilitar."
  name                = "eco-psql-base-caida"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  scopes              = [azurerm_postgresql_flexible_server.flexible_servers_psql_ignix_prod0.id]
  severity            = 1
  window_size         = "PT1M"
  action {
    action_group_id = "/subscriptions/DC7A59F3-0F26-449C-ADB4-E822FD893336/resourceGroups/rg-ignixcommsuite-prod/providers/microsoft.insights/actionGroups/ag-ecosistema-alertas"
  }
  criteria {
    aggregation      = "Minimum"
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "is_db_alive"
    operator         = "LessThan"
    threshold        = 1
  }
}
resource "azurerm_monitor_metric_alert" "metricalerts_eco_psql_conexiones_altas0" {
  auto_mitigate       = false
  description         = "psql-ignix-prod: más de 600 conexiones activas (de 844 útiles). Buscar pools que no devuelven conexiones. | Creada 11/09/2026 por Andrés Valero (ecosistema, coordinada con CENTRIA). No se puede borrar por el lock CanNotDelete del RG: deshabilitar."
  name                = "eco-psql-conexiones-altas"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  scopes              = [azurerm_postgresql_flexible_server.flexible_servers_psql_ignix_prod0.id]
  severity            = 2
  action {
    action_group_id = "/subscriptions/DC7A59F3-0F26-449C-ADB4-E822FD893336/resourceGroups/rg-ignixcommsuite-prod/providers/microsoft.insights/actionGroups/ag-ecosistema-alertas"
  }
  criteria {
    aggregation      = "Maximum"
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "active_connections"
    operator         = "GreaterThan"
    threshold        = 600
  }
}
resource "azurerm_monitor_metric_alert" "metricalerts_eco_psql_cpu_alta0" {
  auto_mitigate       = false
  description         = "psql-ignix-prod: CPU promedio > 70 % en 15 min. | Creada 11/09/2026 por Andrés Valero (ecosistema, coordinada con CENTRIA). No se puede borrar por el lock CanNotDelete del RG: deshabilitar."
  frequency           = "PT5M"
  name                = "eco-psql-cpu-alta"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  scopes              = [azurerm_postgresql_flexible_server.flexible_servers_psql_ignix_prod0.id]
  severity            = 2
  window_size         = "PT15M"
  action {
    action_group_id = "/subscriptions/DC7A59F3-0F26-449C-ADB4-E822FD893336/resourceGroups/rg-ignixcommsuite-prod/providers/microsoft.insights/actionGroups/ag-ecosistema-alertas"
  }
  criteria {
    aggregation      = "Average"
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "cpu_percent"
    operator         = "GreaterThan"
    threshold        = 70
  }
}
resource "azurerm_monitor_metric_alert" "metricalerts_eco_psql_memoria_alta0" {
  auto_mitigate       = false
  description         = "psql-ignix-prod: memoria promedio > 85 % en 15 min. | Creada 11/09/2026 por Andrés Valero (ecosistema, coordinada con CENTRIA). No se puede borrar por el lock CanNotDelete del RG: deshabilitar."
  frequency           = "PT5M"
  name                = "eco-psql-memoria-alta"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  scopes              = [azurerm_postgresql_flexible_server.flexible_servers_psql_ignix_prod0.id]
  severity            = 2
  window_size         = "PT15M"
  action {
    action_group_id = "/subscriptions/DC7A59F3-0F26-449C-ADB4-E822FD893336/resourceGroups/rg-ignixcommsuite-prod/providers/microsoft.insights/actionGroups/ag-ecosistema-alertas"
  }
  criteria {
    aggregation      = "Average"
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "memory_percent"
    operator         = "GreaterThan"
    threshold        = 85
  }
}
resource "azurerm_monitor_metric_alert" "metricalerts_eco_psql_storage_alto0" {
  auto_mitigate       = false
  description         = "psql-ignix-prod: storage > 80 %. Autogrow apagado: al 95 % la base pasa a solo lectura. | Creada 11/09/2026 por Andrés Valero (ecosistema, coordinada con CENTRIA). No se puede borrar por el lock CanNotDelete del RG: deshabilitar."
  frequency           = "PT15M"
  name                = "eco-psql-storage-alto"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  scopes              = [azurerm_postgresql_flexible_server.flexible_servers_psql_ignix_prod0.id]
  severity            = 1
  window_size         = "PT30M"
  action {
    action_group_id = "/subscriptions/DC7A59F3-0F26-449C-ADB4-E822FD893336/resourceGroups/rg-ignixcommsuite-prod/providers/microsoft.insights/actionGroups/ag-ecosistema-alertas"
  }
  criteria {
    aggregation      = "Maximum"
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "storage_percent"
    operator         = "GreaterThan"
    threshold        = 80
  }
}
resource "azurerm_key_vault" "vaults_kv_ignix_prod0" {
  enabled_for_template_deployment = true
  location                        = "brazilsouth"
  name                            = "kv-ignix-prod"
  resource_group_name             = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  sku_name                        = "standard"
  tags = {
    app         = "ignix"
    environment = "prod"
    managedBy   = "bicep"
  }
  tenant_id = "93a9d1eb-0e13-4963-bc57-a47c548f2690"
}
resource "azurerm_key_vault" "vaults_kvcmslmkezpwwqj0" {
  location                 = "brazilsouth"
  name                     = "kvcmslmkezpwwqj"
  purge_protection_enabled = true
  resource_group_name      = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  sku_name                 = "standard"
  tenant_id                = "93a9d1eb-0e13-4963-bc57-a47c548f2690"
}
resource "azurerm_key_vault" "vaults_turecibo_prod_kv0" {
  location                 = "brazilsouth"
  name                     = "turecibo-prod-kv"
  purge_protection_enabled = true
  resource_group_name      = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  sku_name                 = "standard"
  tags = {
    contrato = "centria"
    entorno  = "prod"
    modulo   = "turecibo"
  }
  tenant_id = "93a9d1eb-0e13-4963-bc57-a47c548f2690"
}
resource "azurerm_user_assigned_identity" "user_assigned_identities_mi_janus_job_prod0" {
  location            = "brazilsouth"
  name                = "mi-janus-job-prod"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
}
resource "azurerm_user_assigned_identity" "user_assigned_identities_mi_janus_job_staging0" {
  location            = "brazilsouth"
  name                = "mi-janus-job-staging"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
}
resource "azurerm_user_assigned_identity" "user_assigned_identities_mi_planos_api_prod0" {
  location            = "brazilsouth"
  name                = "mi-planos-api-prod"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
}
resource "azurerm_user_assigned_identity" "user_assigned_identities_mi_planos_api_stage0" {
  location            = "brazilsouth"
  name                = "mi-planos-api-stage"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  tags = {
    environment = "stage"
    managedBy   = "bicep"
    system      = "pid"
  }
}
resource "azurerm_user_assigned_identity" "user_assigned_identities_mi_planos_web_stage0" {
  location            = "brazilsouth"
  name                = "mi-planos-web-stage"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  tags = {
    environment = "stage"
    managedBy   = "bicep"
    system      = "pid"
  }
}
resource "azurerm_user_assigned_identity" "user_assigned_identities_mi_planos_worker_prod0" {
  location            = "brazilsouth"
  name                = "mi-planos-worker-prod"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
}
resource "azurerm_user_assigned_identity" "user_assigned_identities_mi_planos_worker_stage0" {
  location            = "brazilsouth"
  name                = "mi-planos-worker-stage"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  tags = {
    environment = "stage"
    managedBy   = "bicep"
    system      = "pid"
  }
}
resource "azurerm_nat_gateway" "nat_gateways_nat_centriabkp_202609280" {
  location            = "brazilsouth"
  name                = "nat-centriabkp-20260928"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  tags = {
    expires = "2026-09-28"
    purpose = "temporary-payroll-backup"
  }
}
resource "azurerm_private_dns_zone" "private_dns_zones_turecibo_prod_private_postgres_database_azure_com0" {
  name                = "turecibo-prod.private.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  tags = {
    contrato = "centria"
    entorno  = "prod"
    modulo   = "turecibo"
  }
}
resource "azurerm_private_dns_zone_virtual_network_link" "virtual_network_links_enlace_vnet0" {
  name                  = "enlace-vnet"
  private_dns_zone_name = "turecibo-prod.private.postgres.database.azure.com"
  resource_group_name   = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  virtual_network_id    = azurerm_virtual_network.virtual_networks_turecibo_prod_vnet0.id
  depends_on = [
    azurerm_private_dns_zone.private_dns_zones_turecibo_prod_private_postgres_database_azure_com0,
  ]
}
resource "azurerm_public_ip" "public_ip_addresses_pip_centriabkp_202609280" {
  allocation_method   = "Static"
  location            = "brazilsouth"
  name                = "pip-centriabkp-20260928"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  tags = {
    expires = "2026-09-28"
    purpose = "temporary-payroll-backup"
  }
}
resource "azurerm_virtual_network" "virtual_networks_turecibo_prod_vnet0" {
  address_space       = ["10.40.0.0/16"]
  location            = "brazilsouth"
  name                = "turecibo-prod-vnet"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  tags = {
    contrato = "centria"
    entorno  = "prod"
    modulo   = "turecibo"
  }
}
resource "azurerm_virtual_network" "virtual_networks_vnet_centriabkp_202609280" {
  address_space       = ["10.253.0.0/16"]
  location            = "brazilsouth"
  name                = "vnet-centriabkp-20260928"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  tags = {
    expires = "2026-09-28"
    purpose = "temporary-payroll-backup"
  }
}
resource "azurerm_log_analytics_workspace" "workspaces_log_ignix_prod0" {
  location            = "brazilsouth"
  name                = "log-ignix-prod"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
}
resource "azurerm_log_analytics_workspace" "workspaces_turecibo_prod_logs0" {
  location            = "brazilsouth"
  name                = "turecibo-prod-logs"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  tags = {
    contrato = "centria"
    entorno  = "prod"
    modulo   = "turecibo"
  }
}
resource "azurerm_storage_account" "storage_accounts_stignixprod0" {
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  allow_nested_items_to_be_public = false
  location                        = "brazilsouth"
  min_tls_version                 = "TLS1_0"
  name                            = "stignixprod"
  resource_group_name             = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
}
resource "azurerm_storage_account" "storage_accounts_stplanospidprod0" {
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  allow_nested_items_to_be_public = false
  location                        = "brazilsouth"
  name                            = "stplanospidprod"
  resource_group_name             = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
}
resource "azurerm_app_service_certificate" "certificates_centria_tools_sparkgy_com0" {
  location            = "brazilsouth"
  name                = "centria.tools.sparkgy.com"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  # El certificado ya está en App Service. La API no devuelve el pfx ni un secret de Key Vault.
  key_vault_secret_id = "https://kv-ignix-prod.vault.azure.net/secrets/imported-app-service-certificate"
  lifecycle {
    ignore_changes = [key_vault_secret_id]
  }
}
resource "azurerm_app_service_certificate" "certificates_ignix_tools_sparkgy_com0" {
  location            = "brazilsouth"
  name                = "ignix.tools.sparkgy.com"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  # El certificado ya está en App Service. La API no devuelve el pfx ni un secret de Key Vault.
  key_vault_secret_id = "https://kv-ignix-prod.vault.azure.net/secrets/imported-app-service-certificate"
  lifecycle {
    ignore_changes = [key_vault_secret_id]
  }
}
resource "azurerm_app_service_certificate" "certificates_sgi_tools_sparkgy_com0" {
  location            = "brazilsouth"
  name                = "sgi.tools.sparkgy.com"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  # El certificado ya está en App Service. La API no devuelve el pfx ni un secret de Key Vault.
  key_vault_secret_id = "https://kv-ignix-prod.vault.azure.net/secrets/imported-app-service-certificate"
  lifecycle {
    ignore_changes = [key_vault_secret_id]
  }
}
resource "azurerm_app_service_certificate" "certificates_sgp_tools_sparkgy_com0" {
  location            = "brazilsouth"
  name                = "sgp.tools.sparkgy.com"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  # El certificado ya está en App Service. La API no devuelve el pfx ni un secret de Key Vault.
  key_vault_secret_id = "https://kv-ignix-prod.vault.azure.net/secrets/imported-app-service-certificate"
  lifecycle {
    ignore_changes = [key_vault_secret_id]
  }
}
resource "azurerm_service_plan" "server_farms_asp_ignix_prod0" {
  location            = "brazilsouth"
  name                = "asp-ignix-prod"
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  sku_name            = "B2"
  tags = {
    app         = "ignix"
    environment = "prod"
    managedBy   = "bicep"
  }
}
resource "azurerm_service_plan" "server_farms_asp_ignix_staging0" {
  location            = "brazilsouth"
  name                = "asp-ignix-staging"
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  sku_name            = "B2"
}
resource "azurerm_service_plan" "server_farms_asp_sgi_prod0" {
  location            = "brazilsouth"
  name                = "asp-sgi-prod"
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  sku_name            = "B2"
  tags = {
    app         = "sgi"
    environment = "prod"
    managedBy   = "bicep"
    repo        = "SPARKGY/SGI"
  }
}
resource "azurerm_service_plan" "server_farms_asp_sgi_staging0" {
  location            = "brazilsouth"
  name                = "asp-sgi-staging"
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  sku_name            = "B1"
  tags = {
    app         = "sgi"
    environment = "staging"
    managedBy   = "bicep"
    repo        = "SPARKGY/SGI"
  }
}
resource "azurerm_service_plan" "server_farms_asp_sgp_prod0" {
  location            = "brazilsouth"
  name                = "asp-sgp-prod"
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  sku_name            = "B2"
  tags = {
    app         = "sgp"
    environment = "prod"
    managedBy   = "bicep"
    repo        = "SPARKGY/SGP"
  }
}
resource "azurerm_service_plan" "server_farms_asp_sgp_staging0" {
  location            = "brazilsouth"
  name                = "asp-sgp-staging"
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  sku_name            = "B1"
  tags = {
    app         = "sgp"
    environment = "staging"
    managedBy   = "bicep"
    repo        = "SPARKGY/SGP"
  }
}
resource "azurerm_service_plan" "server_farms_centria_plan_prod0" {
  location            = "brazilsouth"
  name                = "centria-plan-prod"
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  sku_name            = "B3"
}
resource "azurerm_service_plan" "server_farms_turecibo_prod_plan0" {
  location            = "brazilsouth"
  name                = "turecibo-prod-plan"
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  sku_name            = "B1"
  tags = {
    contrato = "centria"
    entorno  = "prod"
    modulo   = "turecibo"
  }
}
resource "azurerm_linux_web_app" "sites_ariadna_prod_lmkezpwwqjch20" {
  app_settings = {
    APP_ENV                        = "production"
    ARIADNA_BASE_PATH              = "/api/ariadna"
    ARIADNA_INTERNAL_TOKEN         = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=ariadna-internal-token)"
    ARIADNA_INTERNAL_TOKEN_PREVIO  = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=ariadna-internal-token-previo)"
    CENTRIA_API_TOKEN              = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=ariadna-centria-api-token)"
    CENTRIA_API_URL                = "https://centria.tools.sparkgy.com"
    DATABASE_URL                   = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=ariadna-database-url)"
    MOCK_CENTRIA                   = "false"
    NEXT_TELEMETRY_DISABLED        = "1"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "false"
    SYNC_SCHEDULE_TOKEN            = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=ariadna-sync-schedule-token)"
    SYNC_SCHEDULE_TOKEN_PREVIO     = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=ariadna-sync-schedule-token-previo)"
    WEBSITE_NODE_DEFAULT_VERSION   = "~20"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "ariadna-prod-lmkezpwwqjch2"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_centria_plan_prod0.id
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    app_command_line                  = "node server.js"
    health_check_path                 = "/api/ariadna/api/health"
    health_check_eviction_time_in_min = 2
    ip_restriction {
      ip_address = "20.206.176.11/32"
      priority   = 100
    }
    ip_restriction {
      ip_address = "20.206.176.27/32"
      priority   = 101
    }
    ip_restriction {
      ip_address = "74.163.200.172/32"
      priority   = 102
    }
    ip_restriction {
      ip_address = "74.163.200.176/32"
      priority   = 103
    }
    ip_restriction {
      ip_address = "74.163.200.184/32"
      priority   = 104
    }
    ip_restriction {
      ip_address = "74.163.200.190/32"
      priority   = 105
    }
    ip_restriction {
      ip_address = "74.163.200.218/32"
      priority   = 106
    }
    ip_restriction {
      ip_address = "74.163.200.224/32"
      priority   = 107
    }
    ip_restriction {
      ip_address = "74.163.200.252/32"
      priority   = 108
    }
    ip_restriction {
      ip_address = "74.163.200.255/32"
      priority   = 109
    }
    ip_restriction {
      ip_address = "74.163.201.0/32"
      priority   = 110
    }
    ip_restriction {
      ip_address = "74.163.201.8/32"
      priority   = 111
    }
    ip_restriction {
      ip_address = "74.163.201.17/32"
      priority   = 112
    }
    ip_restriction {
      ip_address = "74.163.201.91/32"
      priority   = 113
    }
    ip_restriction {
      ip_address = "74.163.201.153/32"
      priority   = 114
    }
    ip_restriction {
      ip_address = "74.163.201.156/32"
      priority   = 115
    }
    ip_restriction {
      ip_address = "74.163.201.161/32"
      priority   = 116
    }
    ip_restriction {
      ip_address = "74.163.201.168/32"
      priority   = 117
    }
    ip_restriction {
      ip_address = "74.163.201.217/32"
      priority   = 118
    }
    ip_restriction {
      ip_address = "74.163.201.224/32"
      priority   = 119
    }
    ip_restriction {
      ip_address = "74.163.201.246/32"
      priority   = 120
    }
    ip_restriction {
      ip_address = "74.163.201.248/32"
      priority   = 121
    }
    ip_restriction {
      ip_address = "74.163.202.3/32"
      priority   = 122
    }
    ip_restriction {
      ip_address = "74.163.202.21/32"
      priority   = 123
    }
    ip_restriction {
      ip_address = "74.163.202.26/32"
      priority   = 124
    }
    ip_restriction {
      ip_address = "74.163.202.55/32"
      priority   = 125
    }
    ip_restriction {
      ip_address = "74.163.202.58/32"
      priority   = 126
    }
    ip_restriction {
      ip_address = "74.163.202.173/32"
      priority   = 127
    }
    ip_restriction {
      ip_address = "74.163.202.184/32"
      priority   = 128
    }
    ip_restriction {
      ip_address = "74.163.202.187/32"
      priority   = 129
    }
    ip_restriction {
      ip_address = "74.163.202.221/32"
      priority   = 130
    }
    ip_restriction {
      ip_address = "74.163.202.223/32"
      priority   = 131
    }
  }
}
resource "azurerm_linux_web_app" "sites_ariadna_staging_lmkezpwwqjch20" {
  app_settings = {
    APP_ENV                        = "staging"
    ARIADNA_BASE_PATH              = "/api/ariadna"
    ARIADNA_INTERNAL_TOKEN         = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=ariadna-staging-internal-token)"
    ARIADNA_INTERNAL_TOKEN_PREVIO  = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=ariadna-staging-internal-token-previo)"
    CENTRIA_API_TOKEN              = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=ariadna-staging-centria-api-token)"
    CENTRIA_API_URL                = "https://centria-staging-lmkezpwwqjch2.azurewebsites.net"
    DATABASE_URL                   = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=ariadna-staging-database-url)"
    MOCK_CENTRIA                   = "false"
    NEXT_TELEMETRY_DISABLED        = "1"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "false"
    SYNC_SCHEDULE_TOKEN            = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=ariadna-staging-sync-schedule-token)"
    SYNC_SCHEDULE_TOKEN_PREVIO     = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=ariadna-staging-sync-schedule-token-previo)"
    WEBSITE_NODE_DEFAULT_VERSION   = "~20"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "ariadna-staging-lmkezpwwqjch2"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_ignix_staging0.id
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    app_command_line                  = "node server.js"
    health_check_path                 = "/api/ariadna/api/health"
    health_check_eviction_time_in_min = 2
    ip_restriction {
      ip_address = "20.206.176.11/32"
      priority   = 100
    }
    ip_restriction {
      ip_address = "20.206.176.27/32"
      priority   = 101
    }
    ip_restriction {
      ip_address = "74.163.200.172/32"
      priority   = 102
    }
    ip_restriction {
      ip_address = "74.163.200.176/32"
      priority   = 103
    }
    ip_restriction {
      ip_address = "74.163.200.184/32"
      priority   = 104
    }
    ip_restriction {
      ip_address = "74.163.200.190/32"
      priority   = 105
    }
    ip_restriction {
      ip_address = "74.163.200.218/32"
      priority   = 106
    }
    ip_restriction {
      ip_address = "74.163.200.224/32"
      priority   = 107
    }
    ip_restriction {
      ip_address = "74.163.200.252/32"
      priority   = 108
    }
    ip_restriction {
      ip_address = "74.163.200.255/32"
      priority   = 109
    }
    ip_restriction {
      ip_address = "74.163.201.0/32"
      priority   = 110
    }
    ip_restriction {
      ip_address = "74.163.201.8/32"
      priority   = 111
    }
    ip_restriction {
      ip_address = "74.163.201.17/32"
      priority   = 112
    }
    ip_restriction {
      ip_address = "74.163.201.91/32"
      priority   = 113
    }
    ip_restriction {
      ip_address = "74.163.201.153/32"
      priority   = 114
    }
    ip_restriction {
      ip_address = "74.163.201.156/32"
      priority   = 115
    }
    ip_restriction {
      ip_address = "74.163.201.161/32"
      priority   = 116
    }
    ip_restriction {
      ip_address = "74.163.201.168/32"
      priority   = 117
    }
    ip_restriction {
      ip_address = "74.163.201.217/32"
      priority   = 118
    }
    ip_restriction {
      ip_address = "74.163.201.224/32"
      priority   = 119
    }
    ip_restriction {
      ip_address = "74.163.201.246/32"
      priority   = 120
    }
    ip_restriction {
      ip_address = "74.163.201.248/32"
      priority   = 121
    }
    ip_restriction {
      ip_address = "74.163.202.3/32"
      priority   = 122
    }
    ip_restriction {
      ip_address = "74.163.202.21/32"
      priority   = 123
    }
    ip_restriction {
      ip_address = "74.163.202.26/32"
      priority   = 124
    }
    ip_restriction {
      ip_address = "74.163.202.55/32"
      priority   = 125
    }
    ip_restriction {
      ip_address = "74.163.202.58/32"
      priority   = 126
    }
    ip_restriction {
      ip_address = "74.163.202.173/32"
      priority   = 127
    }
    ip_restriction {
      ip_address = "74.163.202.184/32"
      priority   = 128
    }
    ip_restriction {
      ip_address = "74.163.202.187/32"
      priority   = 129
    }
    ip_restriction {
      ip_address = "74.163.202.221/32"
      priority   = 130
    }
    ip_restriction {
      ip_address = "74.163.202.223/32"
      priority   = 131
    }
  }
}
resource "azurerm_linux_web_app" "sites_centria_prod_lmkezpwwqjch20" {
  app_settings = {
    APP_ENV                            = "prod"
    ARIADNA_INTERNAL_TOKEN             = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=ariadna-internal-token)"
    ARIADNA_SERVICE_TOKEN              = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=ariadna-centria-api-token)"
    ARIADNA_SYNC_SCHEDULE_TOKEN        = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=ariadna-sync-schedule-token)"
    ARIADNA_URL                        = "https://ariadna-prod-lmkezpwwqjch2.azurewebsites.net"
    AZURE_AD_CLIENT_ID                 = "f2931a05-815b-4989-8e61-d13ef8fce5a3"
    AZURE_AD_CLIENT_SECRET             = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=centria-prod-azure-ad-client-secret)"
    AZURE_AD_TENANT_ID                 = "93a9d1eb-0e13-4963-bc57-a47c548f2690"
    BOOTSTRAP_ADMIN_EMAIL              = "avalero@sparkgy.com"
    DATABASE_URL                       = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=centria-database-url)"
    DEPLOY_LOG_TOKEN                   = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=centria-deploy-log-token)"
    GITHUB_TOKEN                       = var.app_secrets["sites_centria_prod_lmkezpwwqjch20.GITHUB_TOKEN"]
    HERMES_INTERNAL_TOKEN              = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=hermes-internal-token)"
    HERMES_SERVICE_TOKEN               = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=hermes-centria-api-token)"
    HERMES_SYNC_SCHEDULE_TOKEN         = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=hermes-sync-schedule-token)"
    HERMES_URL                         = "https://hermes-prod-lmkezpwwqjch2.azurewebsites.net"
    ISO_EXTRACTION_SERVICE_TOKEN       = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=iso-extraction-centria-api-token)"
    ISO_EXTRACTION_SYNC_SCHEDULE_TOKEN = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=iso-extraction-centria-sync-token)"
    ISO_EXTRACTOR_TOKEN                = "@Microsoft.KeyVault(SecretUri=https://kv-ignix-prod.vault.azure.net/secrets/iso-extraction-internal-token/)"
    ISO_EXTRACTOR_URL                  = "https://iso-extractor-prod.azurewebsites.net"
    KAIROS_INTERNAL_TOKEN              = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-internal-token)"
    KAIROS_SERVICE_TOKEN               = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-centria-api-token)"
    KAIROS_SYNC_SCHEDULE_TOKEN         = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-sync-schedule-token)"
    KAIROS_URL                         = "https://kairos-prod-lmkezpwwqjch2.azurewebsites.net"
    LICENSES_SYNC_TOKEN                = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=licenses-sync-token)"
    MENTOR_INTERNAL_TOKEN              = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-internal-token)"
    MENTOR_SERVICE_TOKEN               = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-centria-api-token)"
    MENTOR_SYNC_SCHEDULE_TOKEN         = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-sync-schedule-token)"
    MENTOR_URL                         = "https://mentor-prod-lmkezpwwqjch2.azurewebsites.net"
    MODULE_ALLOWED_HOSTS               = "timesheet-modulo-prod-lmkezpwwqjch2.azurewebsites.net,kairos-prod-lmkezpwwqjch2.azurewebsites.net,hermes-prod-lmkezpwwqjch2.azurewebsites.net,ariadna-prod-lmkezpwwqjch2.azurewebsites.net,mentor-prod-lmkezpwwqjch2.azurewebsites.net,iso-extractor-prod.azurewebsites.net,centria-tester-prod.azurewebsites.net,janus-prod-lmkezpwwqjch2.azurewebsites.net,turecibo-prod.azurewebsites.net"
    MODULE_AZURE_RESOURCE_GROUP        = "rg-ignixcommsuite-prod"
    MODULE_AZURE_SUBSCRIPTION_ID       = "dc7a59f3-0f26-449c-adb4-e822fd893336"
    MODULE_KEY_VAULT_NAME              = "kvcmslmkezpwwqj"
    MODULE_SECRETS_KEY                 = "@Microsoft.KeyVault(SecretUri=https://kv-ignix-prod.vault.azure.net/secrets/centria-module-secrets-key)"
    NEXTAUTH_SECRET                    = var.app_secrets["sites_centria_prod_lmkezpwwqjch20.NEXTAUTH_SECRET"]
    NEXTAUTH_URL                       = "https://centria.tools.sparkgy.com"
    NEXT_TELEMETRY_DISABLED            = "1"
    NOMINA_FANOUT_SCHEDULE_TOKEN       = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=centria-nomina-fanout-token)"
    PAYROLL_SYNC_TOKEN                 = var.app_secrets["sites_centria_prod_lmkezpwwqjch20.PAYROLL_SYNC_TOKEN"]
    PID_API_URL                        = "https://ca-planos-api-prod.yellowpebble-b1f7b858.brazilsouth.azurecontainerapps.io"
    PID_EXTRACTION_SERVICE_TOKEN       = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=pid-extraction-centria-api-token)"
    PID_INTERNAL_TOKEN                 = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=pid-extraction-internal-token)"
    PID_SYNC_SCHEDULE_TOKEN            = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=pid-sync-schedule-token)"
    PID_WEB_URL                        = "https://ca-planos-web-prod.yellowpebble-b1f7b858.brazilsouth.azurecontainerapps.io"
    SCM_DO_BUILD_DURING_DEPLOYMENT     = "false"
    SHAREPOINT_CLIENT_ID               = "db21b315-3981-4a9b-942a-b43634c7958d"
    SHAREPOINT_CLIENT_SECRET           = "@Microsoft.KeyVault(SecretUri=https://kv-ignix-prod.vault.azure.net/secrets/centria-sharepoint-client-secret/)"
    SHAREPOINT_TENANT_ID               = "93a9d1eb-0e13-4963-bc57-a47c548f2690"
    TURECIBO_PASSWORD                  = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=turecibo-password)"
    TURECIBO_URL                       = "https://api.turecibo.com"
    TURECIBO_USERNAME                  = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=turecibo-username)"
    WEBSITE_NODE_DEFAULT_VERSION       = "~20"
    name                               = "MODULE_SECRETS_KEY"
    slotSetting                        = "False"
    value                              = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=centria-module-secrets-key)"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "centria-prod-lmkezpwwqjch2"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_centria_plan_prod0.id
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    app_command_line = "node server.js"
  }
}
resource "azurerm_linux_web_app" "sites_centria_staging_lmkezpwwqjch20" {
  app_settings = {
    APP_ENV                            = "staging"
    ARIADNA_INTERNAL_TOKEN             = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=ariadna-staging-internal-token)"
    ARIADNA_SERVICE_TOKEN              = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=ariadna-staging-centria-api-token)"
    ARIADNA_SYNC_SCHEDULE_TOKEN        = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=ariadna-staging-sync-schedule-token)"
    ARIADNA_URL                        = "https://ariadna-staging-lmkezpwwqjch2.azurewebsites.net"
    AZURE_AD_CLIENT_ID                 = "f2931a05-815b-4989-8e61-d13ef8fce5a3"
    AZURE_AD_CLIENT_SECRET             = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=centria-staging-azure-ad-client-secret)"
    AZURE_AD_TENANT_ID                 = "93a9d1eb-0e13-4963-bc57-a47c548f2690"
    BOOTSTRAP_ADMIN_EMAIL              = "avalero@sparkgy.com"
    DATABASE_URL                       = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=centria-staging-database-url)"
    DEPLOY_LOG_TOKEN                   = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=centria-staging-deploy-log-token)"
    GITHUB_TOKEN                       = var.app_secrets["sites_centria_staging_lmkezpwwqjch20.GITHUB_TOKEN"]
    HERMES_INTERNAL_TOKEN              = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=hermes-staging-internal-token)"
    HERMES_SERVICE_TOKEN               = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=hermes-staging-centria-api-token)"
    HERMES_SYNC_SCHEDULE_TOKEN         = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=hermes-staging-sync-schedule-token)"
    HERMES_URL                         = "https://hermes-staging-lmkezpwwqjch2.azurewebsites.net"
    ISO_EXTRACTION_SERVICE_TOKEN       = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=iso-extraction-staging-centria-api-token)"
    ISO_EXTRACTION_SYNC_SCHEDULE_TOKEN = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=iso-extraction-staging-centria-sync-token)"
    ISO_EXTRACTOR_TOKEN                = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=iso-extraction-staging-internal-token)"
    ISO_EXTRACTOR_URL                  = "https://iso-extractor-staging.azurewebsites.net"
    KAIROS_INTERNAL_TOKEN              = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-staging-internal-token)"
    KAIROS_SERVICE_TOKEN               = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-staging-centria-api-token)"
    KAIROS_SYNC_SCHEDULE_TOKEN         = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-staging-sync-schedule-token)"
    KAIROS_URL                         = "https://kairos-staging-lmkezpwwqjch2.azurewebsites.net"
    LICENSES_SYNC_TOKEN                = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=centria-staging-licenses-sync-token)"
    MENTOR_INTERNAL_TOKEN              = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-staging-internal-token)"
    MENTOR_SERVICE_TOKEN               = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-staging-centria-api-token)"
    MENTOR_SYNC_SCHEDULE_TOKEN         = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-staging-sync-schedule-token)"
    MENTOR_URL                         = "https://mentor-staging-lmkezpwwqjch2.azurewebsites.net"
    MODULE_ALLOWED_HOSTS               = "timesheet-modulo-staging-lmkezpwwqjch2.azurewebsites.net,turecibo-modulo-staging.azurewebsites.net,kairos-staging-lmkezpwwqjch2.azurewebsites.net,hermes-staging-lmkezpwwqjch2.azurewebsites.net,ariadna-staging-lmkezpwwqjch2.azurewebsites.net,mentor-staging-lmkezpwwqjch2.azurewebsites.net,iso-extractor-staging.azurewebsites.net,janus-staging-lmkezpwwqjch2.azurewebsites.net,centria-tester-staging.azurewebsites.net"
    MODULE_AZURE_RESOURCE_GROUP        = "rg-ignixcommsuite-prod"
    MODULE_AZURE_SUBSCRIPTION_ID       = "dc7a59f3-0f26-449c-adb4-e822fd893336"
    MODULE_KEY_VAULT_NAME              = "kvcmslmkezpwwqj"
    MODULE_SECRETS_KEY                 = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=centria-staging-module-secrets-key)"
    NEXTAUTH_SECRET                    = var.app_secrets["sites_centria_staging_lmkezpwwqjch20.NEXTAUTH_SECRET"]
    NEXTAUTH_URL                       = "https://centria-staging-lmkezpwwqjch2.azurewebsites.net"
    NEXT_TELEMETRY_DISABLED            = "1"
    NOMINA_FANOUT_SCHEDULE_TOKEN       = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=centria-staging-nomina-fanout-token)"
    PID_API_URL                        = "https://ca-planos-api-stage.victorioussmoke-d8e25a20.brazilsouth.azurecontainerapps.io"
    PID_EXTRACTION_SERVICE_TOKEN       = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=pid-extraction-staging-centria-api-token)"
    PID_INTERNAL_TOKEN                 = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=pid-extraction-staging-internal-token)"
    PID_SYNC_SCHEDULE_TOKEN            = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=pid-staging-sync-schedule-token)"
    PID_WEB_URL                        = "https://ca-planos-web-stage.victorioussmoke-d8e25a20.brazilsouth.azurecontainerapps.io"
    SCM_DO_BUILD_DURING_DEPLOYMENT     = "false"
    TURECIBO_URL                       = "https://api.turecibo.com"
    WEBSITE_NODE_DEFAULT_VERSION       = "~20"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "centria-staging-lmkezpwwqjch2"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_ignix_staging0.id
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  logs {
    http_logs {
      file_system {
        retention_in_days = 3
        retention_in_mb   = 100
      }
    }
  }
  site_config {
    app_command_line = "node server.js"
  }
}
resource "azurerm_linux_web_app" "sites_centria_tester_prod0" {
  app_settings = {
    CENTRIA_ENTRY_TOKEN            = "@Microsoft.KeyVault(SecretUri=https://kv-ignix-prod.vault.azure.net/secrets/centria-tester-entry-token)"
    CENTRIA_MODULE_CODE            = "tester"
    CENTRIA_MODULE_CREDENTIAL      = "@Microsoft.KeyVault(SecretUri=https://kv-ignix-prod.vault.azure.net/secrets/centria-tester-credential)"
    CENTRIA_URL                    = "https://centria.tools.sparkgy.com"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "false"
    WEBSITE_NODE_DEFAULT_VERSION   = "~24"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "centria-tester-prod"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_centria_plan_prod0.id
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    app_command_line = "node server.js"
  }
}
resource "azurerm_linux_web_app" "sites_centria_tester_staging0" {
  app_settings = {
    CENTRIA_ENTRY_TOKEN            = "@Microsoft.KeyVault(SecretUri=https://kv-ignix-prod.vault.azure.net/secrets/centria-staging-tester-entry-token)"
    CENTRIA_MODULE_CODE            = "tester"
    CENTRIA_MODULE_CREDENTIAL      = "@Microsoft.KeyVault(SecretUri=https://kv-ignix-prod.vault.azure.net/secrets/centria-staging-tester-credential)"
    CENTRIA_TENANT_ID              = "cmpncj1tn0002fxekll89x6w8"
    CENTRIA_URL                    = "https://centria-staging-lmkezpwwqjch2.azurewebsites.net"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "false"
    WEBSITE_NODE_DEFAULT_VERSION   = "~24"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "centria-tester-staging"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_ignix_staging0.id
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    app_command_line = "node server.js"
  }
}
resource "azurerm_linux_web_app" "sites_hermes_prod_lmkezpwwqjch20" {
  app_settings = {
    APP_ENV                        = "production"
    CENTRIA_API_TOKEN              = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=hermes-centria-api-token)"
    CENTRIA_API_URL                = "https://centria.tools.sparkgy.com"
    DATABASE_URL                   = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=hermes-database-url)"
    DEV_GATEWAY_TENANT_ID          = ""
    DEV_GATEWAY_USER_EMAIL         = ""
    HERMES_BASE_PATH               = "/api/hermes"
    HERMES_DEFAULT_TENANT_ID       = "cmpncj1tn0002fxekll89x6w8"
    HERMES_DEV_GATEWAY             = "false"
    HERMES_INTERNAL_TOKEN          = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=hermes-internal-token)"
    NEXT_TELEMETRY_DISABLED        = "1"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "false"
    SYNC_SCHEDULE_TOKEN            = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=hermes-sync-schedule-token)"
    WEBSITE_NODE_DEFAULT_VERSION   = "~20"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "hermes-prod-lmkezpwwqjch2"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_centria_plan_prod0.id
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    app_command_line                  = "node server.js"
    health_check_path                 = "/api/hermes/api/health"
    health_check_eviction_time_in_min = 2
    ip_restriction {
      ip_address = "20.206.176.11/32"
      priority   = 100
    }
    ip_restriction {
      ip_address = "20.206.176.27/32"
      priority   = 101
    }
    ip_restriction {
      ip_address = "74.163.200.172/32"
      priority   = 102
    }
    ip_restriction {
      ip_address = "74.163.200.176/32"
      priority   = 103
    }
    ip_restriction {
      ip_address = "74.163.200.184/32"
      priority   = 104
    }
    ip_restriction {
      ip_address = "74.163.200.190/32"
      priority   = 105
    }
    ip_restriction {
      ip_address = "74.163.200.218/32"
      priority   = 106
    }
    ip_restriction {
      ip_address = "74.163.200.224/32"
      priority   = 107
    }
    ip_restriction {
      ip_address = "74.163.200.252/32"
      priority   = 108
    }
    ip_restriction {
      ip_address = "74.163.200.255/32"
      priority   = 109
    }
    ip_restriction {
      ip_address = "74.163.201.0/32"
      priority   = 110
    }
    ip_restriction {
      ip_address = "74.163.201.153/32"
      priority   = 111
    }
    ip_restriction {
      ip_address = "74.163.201.156/32"
      priority   = 112
    }
    ip_restriction {
      ip_address = "74.163.201.161/32"
      priority   = 113
    }
    ip_restriction {
      ip_address = "74.163.201.168/32"
      priority   = 114
    }
    ip_restriction {
      ip_address = "74.163.201.17/32"
      priority   = 115
    }
    ip_restriction {
      ip_address = "74.163.201.217/32"
      priority   = 116
    }
    ip_restriction {
      ip_address = "74.163.201.224/32"
      priority   = 117
    }
    ip_restriction {
      ip_address = "74.163.201.246/32"
      priority   = 118
    }
    ip_restriction {
      ip_address = "74.163.201.248/32"
      priority   = 119
    }
    ip_restriction {
      ip_address = "74.163.201.8/32"
      priority   = 120
    }
    ip_restriction {
      ip_address = "74.163.201.91/32"
      priority   = 121
    }
    ip_restriction {
      ip_address = "74.163.202.173/32"
      priority   = 122
    }
    ip_restriction {
      ip_address = "74.163.202.184/32"
      priority   = 123
    }
    ip_restriction {
      ip_address = "74.163.202.187/32"
      priority   = 124
    }
    ip_restriction {
      ip_address = "74.163.202.21/32"
      priority   = 125
    }
    ip_restriction {
      ip_address = "74.163.202.221/32"
      priority   = 126
    }
    ip_restriction {
      ip_address = "74.163.202.223/32"
      priority   = 127
    }
    ip_restriction {
      ip_address = "74.163.202.26/32"
      priority   = 128
    }
    ip_restriction {
      ip_address = "74.163.202.3/32"
      priority   = 129
    }
    ip_restriction {
      ip_address = "74.163.202.55/32"
      priority   = 130
    }
    ip_restriction {
      ip_address = "74.163.202.58/32"
      priority   = 131
    }
  }
}
resource "azurerm_linux_web_app" "sites_hermes_staging_lmkezpwwqjch20" {
  app_settings = {
    APP_ENV                        = "staging"
    CENTRIA_API_TOKEN              = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=hermes-staging-centria-api-token)"
    CENTRIA_API_URL                = "https://centria-staging-lmkezpwwqjch2.azurewebsites.net"
    DATABASE_URL                   = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=hermes-staging-database-url)"
    DEV_GATEWAY_TENANT_ID          = ""
    DEV_GATEWAY_USER_EMAIL         = ""
    HERMES_BASE_PATH               = "/api/hermes"
    HERMES_DEFAULT_TENANT_ID       = "cmpncj1tn0002fxekll89x6w8"
    HERMES_DEV_GATEWAY             = "false"
    HERMES_INTERNAL_TOKEN          = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=hermes-staging-internal-token)"
    HERMES_INTERNAL_TOKEN_PREVIO   = ""
    NEXT_TELEMETRY_DISABLED        = "1"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "false"
    SYNC_SCHEDULE_TOKEN            = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=hermes-staging-sync-schedule-token)"
    SYNC_SCHEDULE_TOKEN_PREVIO     = ""
    WEBSITE_NODE_DEFAULT_VERSION   = "~20"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "hermes-staging-lmkezpwwqjch2"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_ignix_staging0.id
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    app_command_line                  = "node server.js"
    health_check_path                 = "/api/hermes/api/health"
    health_check_eviction_time_in_min = 2
    ip_restriction {
      ip_address = "20.206.176.11/32"
      priority   = 200
    }
    ip_restriction {
      ip_address = "20.206.176.27/32"
      priority   = 201
    }
    ip_restriction {
      ip_address = "74.163.200.172/32"
      priority   = 202
    }
    ip_restriction {
      ip_address = "74.163.200.176/32"
      priority   = 203
    }
    ip_restriction {
      ip_address = "74.163.200.184/32"
      priority   = 204
    }
    ip_restriction {
      ip_address = "74.163.200.190/32"
      priority   = 205
    }
    ip_restriction {
      ip_address = "74.163.200.218/32"
      priority   = 206
    }
    ip_restriction {
      ip_address = "74.163.200.224/32"
      priority   = 207
    }
    ip_restriction {
      ip_address = "74.163.200.252/32"
      priority   = 208
    }
    ip_restriction {
      ip_address = "74.163.200.255/32"
      priority   = 209
    }
    ip_restriction {
      ip_address = "74.163.201.0/32"
      priority   = 210
    }
    ip_restriction {
      ip_address = "74.163.201.153/32"
      priority   = 211
    }
    ip_restriction {
      ip_address = "74.163.201.156/32"
      priority   = 212
    }
    ip_restriction {
      ip_address = "74.163.201.161/32"
      priority   = 213
    }
    ip_restriction {
      ip_address = "74.163.201.168/32"
      priority   = 214
    }
    ip_restriction {
      ip_address = "74.163.201.17/32"
      priority   = 215
    }
    ip_restriction {
      ip_address = "74.163.201.217/32"
      priority   = 216
    }
    ip_restriction {
      ip_address = "74.163.201.224/32"
      priority   = 217
    }
    ip_restriction {
      ip_address = "74.163.201.246/32"
      priority   = 218
    }
    ip_restriction {
      ip_address = "74.163.201.248/32"
      priority   = 219
    }
    ip_restriction {
      ip_address = "74.163.201.8/32"
      priority   = 220
    }
    ip_restriction {
      ip_address = "74.163.201.91/32"
      priority   = 221
    }
    ip_restriction {
      ip_address = "74.163.202.173/32"
      priority   = 222
    }
    ip_restriction {
      ip_address = "74.163.202.184/32"
      priority   = 223
    }
    ip_restriction {
      ip_address = "74.163.202.187/32"
      priority   = 224
    }
    ip_restriction {
      ip_address = "74.163.202.21/32"
      priority   = 225
    }
    ip_restriction {
      ip_address = "74.163.202.221/32"
      priority   = 226
    }
    ip_restriction {
      ip_address = "74.163.202.223/32"
      priority   = 227
    }
    ip_restriction {
      ip_address = "74.163.202.26/32"
      priority   = 228
    }
    ip_restriction {
      ip_address = "74.163.202.3/32"
      priority   = 229
    }
    ip_restriction {
      ip_address = "74.163.202.55/32"
      priority   = 230
    }
    ip_restriction {
      ip_address = "74.163.202.58/32"
      priority   = 231
    }
  }
}
resource "azurerm_linux_web_app" "sites_ignix_api_prod0" {
  app_settings = {
    ACS_CONNECTION_STRING                 = var.app_secrets["sites_ignix_api_prod0.ACS_CONNECTION_STRING"]
    ACS_SENDER_ADDRESS                    = "DoNotReply@bbf6073a-25f5-49e8-bf5c-44a3bb1a132d.azurecomm.net"
    APPINSIGHTS_INSTRUMENTATIONKEY        = ""
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.app_secrets["sites_ignix_api_prod0.APPLICATIONINSIGHTS_CONNECTION_STRING"]
    APP_URL                               = "https://ignix.tools.sparkgy.com"
    AZURE_STORAGE_CONNECTION_STRING       = "@Microsoft.KeyVault(SecretUri=https://kv-ignix-prod.vault.azure.net/secrets/storage-connection-string/)"
    AZURE_STORAGE_CONTAINER               = "project-files"
    BUILD_DATE                            = "2026-04-30 22:17"
    BUILD_ID                              = "p26"
    CORS_ORIGIN                           = "https://ignix.tools.sparkgy.com,https://ignix-web-prod.azurewebsites.net"
    DATABASE_URL                          = "@Microsoft.KeyVault(SecretUri=https://kv-ignix-prod.vault.azure.net/secrets/ignix-database-url/)"
    DEPLOY_TAG                            = "feat-formularios-digitales-p26"
    ENV_NAME                              = "prod"
    GITHUB_REPO                           = "SPARKGY/IGNIXCommSuite"
    GITHUB_TOKEN                          = var.app_secrets["sites_ignix_api_prod0.GITHUB_TOKEN"]
    JWT_SECRET                            = "@Microsoft.KeyVault(SecretUri=https://kv-ignix-prod.vault.azure.net/secrets/jwt-secret/f347a379f66143feabc22e2e98b34d70)"
    NODE_ENV                              = "production"
    PORT                                  = "3001"
    SCM_DO_BUILD_DURING_DEPLOYMENT        = "false"
    SEED_ADMIN_PASSWORD                   = var.app_secrets["sites_ignix_api_prod0.SEED_ADMIN_PASSWORD"]
    SEED_ADMIN_USERNAME                   = "admin"
    SERVER_URL                            = "https://ignix-api-prod.azurewebsites.net"
    SISTEMATIZACION_EMAIL                 = "sistematizacion@sparkgy.com"
    SMOKE_REGRESSION_TOKEN                = var.app_secrets["sites_ignix_api_prod0.SMOKE_REGRESSION_TOKEN"]
    UPLOADS_DIR                           = "/home/uploads"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = "true"
    WEBSITES_PORT                         = "3001"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "ignix-api-prod"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_ignix_prod0.id
  tags = {
    app         = "ignix"
    environment = "prod"
    managedBy   = "bicep"
  }
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  logs {
    http_logs {
      file_system {
        retention_in_days = 3
        retention_in_mb   = 100
      }
    }
  }
  site_config {
    container_registry_use_managed_identity = true
  }
  storage_account {
    access_key   = var.app_secrets["sites_ignix_api_prod0.storage_account.0.access_key"]
    account_name = "stignixprod"
    mount_path   = "/app/uploads"
    name         = "uploads"
    share_name   = "uploads"
    type         = "AzureFiles"
  }
}
resource "azurerm_linux_web_app" "sites_ignix_web_prod0" {
  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.app_secrets["sites_ignix_web_prod0.APPLICATIONINSIGHTS_CONNECTION_STRING"]
    BUILD_DATE                            = "2026-04-30 23:00"
    BUILD_ID                              = "p27"
    DEPLOY_TAG                            = "feat-formularios-digitales-p27"
    ENV_NAME                              = "prod"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = "false"
    WEBSITES_PORT                         = "80"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "ignix-web-prod"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_ignix_prod0.id
  tags = {
    app         = "ignix"
    environment = "prod"
    managedBy   = "bicep"
  }
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    container_registry_use_managed_identity = true
  }
}
resource "azurerm_linux_web_app" "sites_iso_extractor_prod0" {
  app_settings = {
    ANTHROPIC_API_KEY                   = "@Microsoft.KeyVault(SecretUri=https://kv-ignix-prod.vault.azure.net/secrets/iso-extraction-anthropic-api-key/)"
    AZURE_STORAGE_ACCOUNT_URL           = "https://stignixprod.blob.core.windows.net"
    AZURE_STORAGE_CONTAINER             = "iso-extraction"
    CENTRIA_API_URL                     = "https://centria-prod-lmkezpwwqjch2.azurewebsites.net"
    CENTRIA_IDENTITY_ENABLED            = "true"
    CENTRIA_SERVICE_TOKEN               = "@Microsoft.KeyVault(SecretUri=https://kv-ignix-prod.vault.azure.net/secrets/iso-extraction-centria-api-token/)"
    CENTRIA_SYNC_TOKEN                  = "@Microsoft.KeyVault(SecretUri=https://kv-ignix-prod.vault.azure.net/secrets/iso-extraction-centria-sync-token/)"
    DATA_DIR                            = "/data"
    DB_URL                              = "@Microsoft.KeyVault(SecretUri=https://kv-ignix-prod.vault.azure.net/secrets/iso-extraction-database-url/)"
    GITHUB_TOKEN                        = var.app_secrets["sites_iso_extractor_prod0.GITHUB_TOKEN"]
    INTERNAL_API_TOKEN                  = "@Microsoft.KeyVault(SecretUri=https://kv-ignix-prod.vault.azure.net/secrets/iso-extraction-internal-token/)"
    STORAGE_BACKEND                     = "azure"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "5000"
  }
  client_affinity_enabled                        = true
  ftp_publish_basic_authentication_enabled       = false
  location                                       = "brazilsouth"
  name                                           = "iso-extractor-prod"
  resource_group_name                            = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id                                = azurerm_service_plan.server_farms_centria_plan_prod0.id
  webdeploy_publish_basic_authentication_enabled = false
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 100
      }
    }
  }
  site_config {
    container_registry_use_managed_identity = true
    ftps_state                              = "FtpsOnly"
    health_check_path                       = "/health"
    health_check_eviction_time_in_min       = 2
    http2_enabled                           = true
  }
}
resource "azurerm_linux_web_app" "sites_iso_extractor_staging0" {
  app_settings = {
    ANTHROPIC_API_KEY                   = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=iso-extraction-staging-anthropic-api-key)"
    AZURE_ARCHIVE_CONTAINER             = "iso-archive-staging"
    AZURE_STORAGE_ACCOUNT_URL           = "https://stignixprod.blob.core.windows.net/"
    AZURE_STORAGE_CONTAINER             = "iso-extraction-staging"
    CENTRIA_API_URL                     = "https://centria-staging-lmkezpwwqjch2.azurewebsites.net"
    CENTRIA_IDENTITY_ENABLED            = "true"
    CENTRIA_SERVICE_TOKEN               = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=iso-extraction-staging-centria-api-token)"
    CENTRIA_SYNC_TOKEN                  = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=iso-extraction-staging-centria-sync-token)"
    DATA_DIR                            = "/data"
    DB_NAME_EXPECTED                    = "iso_staging"
    DB_URL                              = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=iso-extraction-staging-database-url)"
    DEPLOY_ENV                          = "staging"
    INTERNAL_API_TOKEN                  = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=iso-extraction-staging-internal-token)"
    STORAGE_BACKEND                     = "azure"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "5000"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "iso-extractor-staging"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_ignix_staging0.id
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    container_registry_use_managed_identity = true
    health_check_path                       = "/health"
    health_check_eviction_time_in_min       = 2
    http2_enabled                           = true
    ip_restriction_default_action           = "Deny"
    ip_restriction {
      ip_address = "20.206.176.11/32"
      priority   = 100
    }
    ip_restriction {
      ip_address = "20.206.176.27/32"
      priority   = 101
    }
    ip_restriction {
      ip_address = "74.163.200.172/32"
      priority   = 102
    }
    ip_restriction {
      ip_address = "74.163.200.176/32"
      priority   = 103
    }
    ip_restriction {
      ip_address = "74.163.200.184/32"
      priority   = 104
    }
    ip_restriction {
      ip_address = "74.163.200.190/32"
      priority   = 105
    }
    ip_restriction {
      ip_address = "74.163.200.218/32"
      priority   = 106
    }
    ip_restriction {
      ip_address = "74.163.200.224/32"
      priority   = 107
    }
    ip_restriction {
      ip_address = "74.163.200.252/32"
      priority   = 108
    }
    ip_restriction {
      ip_address = "74.163.200.255/32"
      priority   = 109
    }
    ip_restriction {
      ip_address = "74.163.201.0/32"
      priority   = 110
    }
    ip_restriction {
      ip_address = "74.163.201.153/32"
      priority   = 111
    }
    ip_restriction {
      ip_address = "74.163.201.156/32"
      priority   = 112
    }
    ip_restriction {
      ip_address = "74.163.201.161/32"
      priority   = 113
    }
    ip_restriction {
      ip_address = "74.163.201.168/32"
      priority   = 114
    }
    ip_restriction {
      ip_address = "74.163.201.17/32"
      priority   = 115
    }
    ip_restriction {
      ip_address = "74.163.201.217/32"
      priority   = 116
    }
    ip_restriction {
      ip_address = "74.163.201.224/32"
      priority   = 117
    }
    ip_restriction {
      ip_address = "74.163.201.246/32"
      priority   = 118
    }
    ip_restriction {
      ip_address = "74.163.201.248/32"
      priority   = 119
    }
    ip_restriction {
      ip_address = "74.163.201.8/32"
      priority   = 120
    }
    ip_restriction {
      ip_address = "74.163.201.91/32"
      priority   = 121
    }
    ip_restriction {
      ip_address = "74.163.202.173/32"
      priority   = 122
    }
    ip_restriction {
      ip_address = "74.163.202.184/32"
      priority   = 123
    }
    ip_restriction {
      ip_address = "74.163.202.187/32"
      priority   = 124
    }
    ip_restriction {
      ip_address = "74.163.202.21/32"
      priority   = 125
    }
    ip_restriction {
      ip_address = "74.163.202.221/32"
      priority   = 126
    }
    ip_restriction {
      ip_address = "74.163.202.223/32"
      priority   = 127
    }
    ip_restriction {
      ip_address = "74.163.202.26/32"
      priority   = 128
    }
    ip_restriction {
      ip_address = "74.163.202.3/32"
      priority   = 129
    }
    ip_restriction {
      ip_address = "74.163.202.55/32"
      priority   = 130
    }
    ip_restriction {
      ip_address = "74.163.202.58/32"
      priority   = 131
    }
  }
}
resource "azurerm_linux_web_app" "sites_janus_prod_lmkezpwwqjch20" {
  app_settings = {
    APP_ENV                             = "prod"
    AZURE_RESOURCE_GROUP                = "rg-ignixcommsuite-prod"
    AZURE_SUBSCRIPTION_ID               = "dc7a59f3-0f26-449c-adb4-e822fd893336"
    CENTRIA_ENTRY_TOKEN                 = "@Microsoft.KeyVault(VaultName=kvcmslmkezpwwqj;SecretName=janus-prod-modulo-token-entrada-cmpncj1tn0002fxekll89x6w8)"
    CENTRIA_ENTRY_TOKEN_PREVIO          = "@Microsoft.KeyVault(VaultName=kvcmslmkezpwwqj;SecretName=janus-prod-modulo-token-entrada-previo-cmpncj1tn0002fxekll89x6w8)"
    CENTRIA_MODULE_CODE                 = "janus"
    CENTRIA_MODULE_CREDENTIAL           = "@Microsoft.KeyVault(VaultName=kvcmslmkezpwwqj;SecretName=janus-prod-modulo-credencial-cmpncj1tn0002fxekll89x6w8)"
    CENTRIA_MODULE_CREDENTIAL_PREVIO    = "@Microsoft.KeyVault(VaultName=kvcmslmkezpwwqj;SecretName=janus-prod-modulo-credencial-previo-cmpncj1tn0002fxekll89x6w8)"
    CENTRIA_TENANT_ID                   = "cmpncj1tn0002fxekll89x6w8"
    CENTRIA_URL                         = "https://centria.tools.sparkgy.com"
    JANUS_ACA_CONTAINER                 = "janus-job"
    JANUS_ACA_IMAGE                     = "ignixacrprod.azurecr.io/janus:8bca576e3fa02f80484dbb1ed158cdee26c1c0e3"
    JANUS_ACA_JOB                       = "janus-job-prod"
    JANUS_ACA_JOB_PRINCIPAL_ID          = "5c2a6b72-8c9a-4429-8905-8eaaa5699bfd"
    JANUS_AZURE_TENANT_ID               = "93a9d1eb-0e13-4963-bc57-a47c548f2690"
    JANUS_BLOB_CONTAINER                = "janus"
    JANUS_BLOB_URL                      = "https://stjanusprod.blob.core.windows.net"
    JANUS_DISK_BUDGET_MB                = "160"
    JANUS_MAX_FILE_MB                   = "25"
    JANUS_MAX_RUN_FILES                 = "200"
    JANUS_MAX_RUN_MB                    = "100"
    JANUS_MAX_RUN_SECONDS               = "3600"
    JANUS_PUBLIC_URL                    = "https://centria.tools.sparkgy.com"
    JANUS_SESSION_TIMEOUT_SECONDS       = "45"
    JANUS_STORAGE                       = "blob"
    JANUS_WEB_INTERNAL_URL              = "https://janus-prod-lmkezpwwqjch2.azurewebsites.net"
    PORT                                = "8000"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "8000"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "janus-prod-lmkezpwwqjch2"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_centria_plan_prod0.id
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    container_registry_use_managed_identity = true
  }
}
resource "azurerm_linux_web_app" "sites_janus_staging_lmkezpwwqjch20" {
  app_settings = {
    APP_ENV                             = "staging"
    AZURE_RESOURCE_GROUP                = "rg-ignixcommsuite-prod"
    AZURE_SUBSCRIPTION_ID               = "dc7a59f3-0f26-449c-adb4-e822fd893336"
    CENTRIA_ENTRY_TOKEN                 = "@Microsoft.KeyVault(VaultName=kvcmslmkezpwwqj;SecretName=janus-staging-modulo-token-entrada-cmpncj1tn0002fxekll89x6w8)"
    CENTRIA_ENTRY_TOKEN_PREVIO          = "@Microsoft.KeyVault(VaultName=kvcmslmkezpwwqj;SecretName=janus-staging-modulo-token-entrada-previo-cmpncj1tn0002fxekll89x6w8)"
    CENTRIA_MODULE_CODE                 = "janus"
    CENTRIA_MODULE_CREDENTIAL           = "@Microsoft.KeyVault(VaultName=kvcmslmkezpwwqj;SecretName=janus-staging-modulo-credencial-cmpncj1tn0002fxekll89x6w8)"
    CENTRIA_MODULE_CREDENTIAL_PREVIO    = "@Microsoft.KeyVault(VaultName=kvcmslmkezpwwqj;SecretName=janus-staging-modulo-credencial-previo-cmpncj1tn0002fxekll89x6w8)"
    CENTRIA_TENANT_ID                   = "cmpncj1tn0002fxekll89x6w8"
    CENTRIA_URL                         = "https://centria-staging-lmkezpwwqjch2.azurewebsites.net"
    JANUS_ACA_CONTAINER                 = "janus-job"
    JANUS_ACA_IMAGE                     = "ignixacrprod.azurecr.io/janus:19ddd6a29a73be85642fc262ea2de67de4458fe9"
    JANUS_ACA_JOB                       = "janus-job-staging"
    JANUS_ACA_JOB_PRINCIPAL_ID          = "14c8f236-c76e-42e8-88b0-8b47e4433b11"
    JANUS_AZURE_TENANT_ID               = "93a9d1eb-0e13-4963-bc57-a47c548f2690"
    JANUS_BLOB_CONTAINER                = "janus"
    JANUS_BLOB_URL                      = "https://stjanusstaging.blob.core.windows.net"
    JANUS_DISK_BUDGET_MB                = "160"
    JANUS_MAX_FILE_MB                   = "50"
    JANUS_MAX_RUN_FILES                 = "200"
    JANUS_MAX_RUN_MB                    = "100"
    JANUS_MAX_RUN_SECONDS               = "3600"
    JANUS_PUBLIC_URL                    = "https://centria-staging-lmkezpwwqjch2.azurewebsites.net"
    JANUS_SESSION_TIMEOUT_SECONDS       = "45"
    JANUS_STORAGE                       = "blob"
    JANUS_WEB_INTERNAL_URL              = "https://janus-staging-lmkezpwwqjch2.azurewebsites.net"
    PORT                                = "8000"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "8000"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "janus-staging-lmkezpwwqjch2"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_ignix_staging0.id
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    container_registry_use_managed_identity = true
  }
}
resource "azurerm_linux_web_app" "sites_kairos_prod_lmkezpwwqjch20" {
  app_settings = {
    ACS_CONNECTION_STRING          = var.app_secrets["sites_kairos_prod_lmkezpwwqjch20.ACS_CONNECTION_STRING"]
    ACS_SENDER_ADDRESS             = "DoNotReply@bbf6073a-25f5-49e8-bf5c-44a3bb1a132d.azurecomm.net"
    APP_ENV                        = "prod"
    CENTRIA_API_TOKEN              = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-centria-api-token)"
    CENTRIA_API_URL                = "https://centria.tools.sparkgy.com"
    DATABASE_URL                   = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-database-url)"
    FEEDBACK_PUBLIC_URL            = "https://kairos-prod-lmkezpwwqjch2.azurewebsites.net/api/timesheets"
    FERIADOS_SYNC_TOKEN            = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-feriados-token-2)"
    FERIADOS_SYNC_TOKEN_PREVIO     = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-feriados-token)"
    GITHUB_FEEDBACK_REPO           = "SPARKGY/KAiROS"
    GITHUB_FEEDBACK_TOKEN          = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-github-feedback-token)"
    KAIROS_DEFAULT_TENANT_ID       = "cmpncj1tn0002fxekll89x6w8"
    KAIROS_INTERNAL_TOKEN          = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-internal-token)"
    KAIROS_INTERNAL_TOKEN_PREVIO   = ""
    NEXT_TELEMETRY_DISABLED        = "1"
    OPENAI_API_KEY                 = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-openai-api-key)"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "false"
    SYNC_SCHEDULE_TOKEN            = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-sync-schedule-token)"
    SYNC_SCHEDULE_TOKEN_PREVIO     = ""
    TURECIBO_PASSWORD              = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=turecibo-password)"
    TURECIBO_URL                   = "https://api.turecibo.com"
    TURECIBO_USER                  = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=turecibo-username)"
    WEBSITE_NODE_DEFAULT_VERSION   = "~20"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "kairos-prod-lmkezpwwqjch2"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_centria_plan_prod0.id
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  logs {
    http_logs {
      file_system {
        retention_in_days = 3
        retention_in_mb   = 100
      }
    }
  }
  site_config {
    app_command_line = "node server.js"
  }
}
resource "azurerm_linux_web_app" "sites_kairos_staging_lmkezpwwqjch20" {
  app_settings = {
    ACS_CONNECTION_STRING          = var.app_secrets["sites_kairos_staging_lmkezpwwqjch20.ACS_CONNECTION_STRING"]
    ACS_SENDER_ADDRESS             = "DoNotReply@bbf6073a-25f5-49e8-bf5c-44a3bb1a132d.azurecomm.net"
    APP_ENV                        = "staging"
    CENTRIA_API_TOKEN              = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-staging-centria-api-token)"
    CENTRIA_API_URL                = "https://centria-staging-lmkezpwwqjch2.azurewebsites.net"
    CENTRIA_ENTRY_TOKEN            = "@Microsoft.KeyVault(VaultName=kvcmslmkezpwwqj;SecretName=kairos-staging-modulo-token-entrada-cmpncj1tn0002fxekll89x6w8)"
    CENTRIA_TENANT_ID              = "cmpncj1tn0002fxekll89x6w8"
    DATABASE_URL                   = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-staging-database-url)"
    FEEDBACK_DISABLED              = "1"
    FEEDBACK_PUBLIC_URL            = ""
    FERIADOS_SYNC_TOKEN            = ""
    FERIADOS_SYNC_TOKEN_PREVIO     = ""
    GITHUB_FEEDBACK_REPO           = "SPARKGY/KAiROS"
    GITHUB_FEEDBACK_TOKEN          = ""
    KAIROS_DEFAULT_TENANT_ID       = "cmpncj1tn0002fxekll89x6w8"
    KAIROS_INTERNAL_TOKEN          = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-staging-internal-token)"
    KAIROS_INTERNAL_TOKEN_PREVIO   = ""
    KAIROS_MAIL_DISABLED           = "1"
    NEXT_TELEMETRY_DISABLED        = "1"
    OPENAI_API_KEY                 = ""
    SCM_DO_BUILD_DURING_DEPLOYMENT = "false"
    SYNC_SCHEDULE_TOKEN            = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-staging-sync-schedule-token)"
    SYNC_SCHEDULE_TOKEN_PREVIO     = ""
    TURECIBO_DISABLED              = "1"
    TURECIBO_PASSWORD              = ""
    TURECIBO_URL                   = ""
    TURECIBO_USER                  = ""
    WEBSITE_NODE_DEFAULT_VERSION   = "~20"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "kairos-staging-lmkezpwwqjch2"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_ignix_staging0.id
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    app_command_line = "node server.js"
    ip_restriction {
      ip_address = "74.163.201.248/32"
      priority   = 100
    }
    ip_restriction {
      ip_address = "74.163.202.3/32"
      priority   = 101
    }
    ip_restriction {
      ip_address = "74.163.202.21/32"
      priority   = 102
    }
    ip_restriction {
      ip_address = "74.163.200.184/32"
      priority   = 103
    }
    ip_restriction {
      ip_address = "74.163.202.26/32"
      priority   = 104
    }
    ip_restriction {
      ip_address = "74.163.202.55/32"
      priority   = 105
    }
    ip_restriction {
      ip_address = "74.163.200.176/32"
      priority   = 106
    }
    ip_restriction {
      ip_address = "74.163.200.172/32"
      priority   = 107
    }
    ip_restriction {
      ip_address = "74.163.200.190/32"
      priority   = 108
    }
    ip_restriction {
      ip_address = "74.163.200.218/32"
      priority   = 109
    }
    ip_restriction {
      ip_address = "74.163.200.224/32"
      priority   = 110
    }
    ip_restriction {
      ip_address = "74.163.200.252/32"
      priority   = 111
    }
    ip_restriction {
      ip_address = "20.206.176.11/32"
      priority   = 112
    }
    ip_restriction {
      ip_address = "20.206.176.27/32"
      priority   = 113
    }
  }
}
resource "azurerm_linux_web_app" "sites_mentor_prod_lmkezpwwqjch20" {
  app_settings = {
    APP_ENV                        = "production"
    CENTRIA_API_TOKEN              = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-centria-api-token)"
    CENTRIA_API_URL                = "https://centria.tools.sparkgy.com"
    DATABASE_URL                   = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-database-url)"
    DEV_GATEWAY_TENANT_ID          = ""
    DEV_GATEWAY_USER_EMAIL         = ""
    GITHUB_ISSUES_REPO             = "SPARKGY/MENTOR"
    GITHUB_ISSUES_TOKEN            = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-github-issues-token)"
    MENTOR_BASE_PATH               = "/api/mentor"
    MENTOR_DEFAULT_TENANT_ID       = ""
    MENTOR_DEV_GATEWAY             = "false"
    MENTOR_INTERNAL_TOKEN          = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-internal-token)"
    MENTOR_INTERNAL_TOKEN_PREVIO   = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-internal-token-previo)"
    MOCK_CENTRIA                   = "false"
    NEXT_TELEMETRY_DISABLED        = "1"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "false"
    SYNC_SCHEDULE_TOKEN            = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-sync-schedule-token)"
    SYNC_SCHEDULE_TOKEN_PREVIO     = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-sync-schedule-token-previo)"
    WEBSITE_NODE_DEFAULT_VERSION   = "~20"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "mentor-prod-lmkezpwwqjch2"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_centria_plan_prod0.id
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  logs {
    detailed_error_messages = true
    failed_request_tracing  = true
    application_logs {
      file_system_level = "Information"
    }
  }
  site_config {
    app_command_line                  = "node server.js"
    health_check_path                 = "/api/mentor/api/health"
    health_check_eviction_time_in_min = 2
    ip_restriction {
      ip_address = "20.206.176.11/32"
      priority   = 100
    }
    ip_restriction {
      ip_address = "20.206.176.27/32"
      priority   = 101
    }
    ip_restriction {
      ip_address = "74.163.200.172/32"
      priority   = 102
    }
    ip_restriction {
      ip_address = "74.163.200.176/32"
      priority   = 103
    }
    ip_restriction {
      ip_address = "74.163.200.184/32"
      priority   = 104
    }
    ip_restriction {
      ip_address = "74.163.200.190/32"
      priority   = 105
    }
    ip_restriction {
      ip_address = "74.163.200.218/32"
      priority   = 106
    }
    ip_restriction {
      ip_address = "74.163.200.224/32"
      priority   = 107
    }
    ip_restriction {
      ip_address = "74.163.200.252/32"
      priority   = 108
    }
    ip_restriction {
      ip_address = "74.163.200.255/32"
      priority   = 109
    }
    ip_restriction {
      ip_address = "74.163.201.0/32"
      priority   = 110
    }
    ip_restriction {
      ip_address = "74.163.201.8/32"
      priority   = 111
    }
    ip_restriction {
      ip_address = "74.163.201.17/32"
      priority   = 112
    }
    ip_restriction {
      ip_address = "74.163.201.91/32"
      priority   = 113
    }
    ip_restriction {
      ip_address = "74.163.201.153/32"
      priority   = 114
    }
    ip_restriction {
      ip_address = "74.163.201.156/32"
      priority   = 115
    }
    ip_restriction {
      ip_address = "74.163.201.161/32"
      priority   = 116
    }
    ip_restriction {
      ip_address = "74.163.201.168/32"
      priority   = 117
    }
    ip_restriction {
      ip_address = "74.163.201.217/32"
      priority   = 118
    }
    ip_restriction {
      ip_address = "74.163.201.224/32"
      priority   = 119
    }
    ip_restriction {
      ip_address = "74.163.201.246/32"
      priority   = 120
    }
    ip_restriction {
      ip_address = "74.163.201.248/32"
      priority   = 121
    }
    ip_restriction {
      ip_address = "74.163.202.3/32"
      priority   = 122
    }
    ip_restriction {
      ip_address = "74.163.202.21/32"
      priority   = 123
    }
    ip_restriction {
      ip_address = "74.163.202.26/32"
      priority   = 124
    }
    ip_restriction {
      ip_address = "74.163.202.55/32"
      priority   = 125
    }
    ip_restriction {
      ip_address = "74.163.202.58/32"
      priority   = 126
    }
    ip_restriction {
      ip_address = "74.163.202.173/32"
      priority   = 127
    }
    ip_restriction {
      ip_address = "74.163.202.184/32"
      priority   = 128
    }
    ip_restriction {
      ip_address = "74.163.202.187/32"
      priority   = 129
    }
    ip_restriction {
      ip_address = "74.163.202.221/32"
      priority   = 130
    }
    ip_restriction {
      ip_address = "74.163.202.223/32"
      priority   = 131
    }
  }
}
resource "azurerm_linux_web_app" "sites_mentor_staging_lmkezpwwqjch20" {
  app_settings = {
    APP_ENV                        = "staging"
    CENTRIA_API_TOKEN              = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-staging-centria-api-token)"
    CENTRIA_API_URL                = "https://centria-staging-lmkezpwwqjch2.azurewebsites.net"
    DATABASE_URL                   = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-staging-database-url)"
    DEV_GATEWAY_TENANT_ID          = ""
    DEV_GATEWAY_USER_EMAIL         = ""
    GITHUB_ISSUES_REPO             = "SPARKGY/MENTOR"
    GITHUB_ISSUES_TOKEN            = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-github-issues-token)"
    MENTOR_BASE_PATH               = "/api/mentor"
    MENTOR_DEFAULT_TENANT_ID       = "cmpncj1tn0002fxekll89x6w8"
    MENTOR_DEV_GATEWAY             = "false"
    MENTOR_INTERNAL_TOKEN          = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-staging-internal-token)"
    MENTOR_INTERNAL_TOKEN_PREVIO   = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-staging-internal-token-previo)"
    MOCK_CENTRIA                   = "false"
    NEXT_TELEMETRY_DISABLED        = "1"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "false"
    SYNC_SCHEDULE_TOKEN            = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-staging-sync-schedule-token)"
    SYNC_SCHEDULE_TOKEN_PREVIO     = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=mentor-staging-sync-schedule-token-previo)"
    WEBSITE_NODE_DEFAULT_VERSION   = "~20"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "mentor-staging-lmkezpwwqjch2"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_ignix_staging0.id
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    app_command_line                  = "node server.js"
    health_check_path                 = "/api/mentor/api/health"
    health_check_eviction_time_in_min = 2
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "20.206.176.11/32"
      priority    = 100
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "20.206.176.27/32"
      priority    = 101
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.200.172/32"
      priority    = 102
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.200.176/32"
      priority    = 103
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.200.184/32"
      priority    = 104
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.200.190/32"
      priority    = 105
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.200.218/32"
      priority    = 106
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.200.224/32"
      priority    = 107
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.200.252/32"
      priority    = 108
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.200.255/32"
      priority    = 109
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.201.0/32"
      priority    = 110
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.201.8/32"
      priority    = 111
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.201.17/32"
      priority    = 112
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.201.91/32"
      priority    = 113
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.201.153/32"
      priority    = 114
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.201.156/32"
      priority    = 115
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.201.161/32"
      priority    = 116
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.201.168/32"
      priority    = 117
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.201.217/32"
      priority    = 118
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.201.224/32"
      priority    = 119
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.201.246/32"
      priority    = 120
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.201.248/32"
      priority    = 121
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.202.3/32"
      priority    = 122
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.202.21/32"
      priority    = 123
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.202.26/32"
      priority    = 124
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.202.55/32"
      priority    = 125
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.202.58/32"
      priority    = 126
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.202.173/32"
      priority    = 127
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.202.184/32"
      priority    = 128
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.202.187/32"
      priority    = 129
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.202.221/32"
      priority    = 130
    }
    ip_restriction {
      description = "CENTRIA-STAGE"
      ip_address  = "74.163.202.223/32"
      priority    = 131
    }
  }
}
resource "azurerm_linux_web_app" "sites_sgi_spark_api_prod0" {
  app_settings = {
    ACS_CONNECTION_STRING                 = var.app_secrets["sites_sgi_spark_api_prod0.ACS_CONNECTION_STRING"]
    ACS_SENDER_ADDRESS                    = "DoNotReply@bbf6073a-25f5-49e8-bf5c-44a3bb1a132d.azurecomm.net"
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.app_secrets["sites_sgi_spark_api_prod0.APPLICATIONINSIGHTS_CONNECTION_STRING"]
    AZURE_BLOB_CONTAINER                  = "sgi-adjuntos"
    AZURE_STORAGE_CONNECTION_STRING       = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=storage-connection-string)"
    CORS_ORIGINS                          = "https://sgi.tools.sparkgy.com,https://sgi-spark-web-prod.azurewebsites.net"
    DATABASE_URL                          = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=sgi-database-url-prod)"
    JWT_ALGORITHM                         = "HS256"
    JWT_EXPIRE_MINUTES                    = "1440"
    JWT_SECRET                            = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=sgi-jwt-secret-prod)"
    MAX_UPLOAD_MB                         = "25"
    NOTIFICACIONES_ACTIVAS                = "true"
    OTEL_RESOURCE_ATTRIBUTES              = "deployment.environment=prod"
    OTEL_SERVICE_NAME                     = "sgi-api-prod"
    OTEL_TRACES_SAMPLER_ARG               = "1.0"
    SCM_DO_BUILD_DURING_DEPLOYMENT        = "false"
    STORAGE_BACKEND                       = "azure"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = "false"
    WEBSITES_PORT                         = "8000"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "sgi-spark-api-prod"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_sgi_prod0.id
  tags = {
    app         = "sgi"
    environment = "prod"
    managedBy   = "bicep"
    repo        = "SPARKGY/SGI"
  }
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    container_registry_use_managed_identity = true
    health_check_path                       = "/health"
    health_check_eviction_time_in_min       = 2
    http2_enabled                           = true
  }
}
resource "azurerm_linux_web_app" "sites_sgi_spark_api_staging0" {
  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.app_secrets["sites_sgi_spark_api_staging0.APPLICATIONINSIGHTS_CONNECTION_STRING"]
    AZURE_BLOB_CONTAINER                  = "sgi-adjuntos-staging"
    AZURE_STORAGE_CONNECTION_STRING       = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=storage-connection-string)"
    CORS_ORIGINS                          = "https://sgi-staging.tools.sparkgy.com,https://sgi-spark-web-staging.azurewebsites.net"
    DATABASE_URL                          = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=sgi-database-url-staging)"
    JWT_ALGORITHM                         = "HS256"
    JWT_EXPIRE_MINUTES                    = "1440"
    JWT_SECRET                            = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=sgi-jwt-secret-staging)"
    MAX_UPLOAD_MB                         = "25"
    OTEL_RESOURCE_ATTRIBUTES              = "deployment.environment=staging"
    OTEL_SERVICE_NAME                     = "sgi-api-staging"
    OTEL_TRACES_SAMPLER_ARG               = "1.0"
    SCM_DO_BUILD_DURING_DEPLOYMENT        = "false"
    STORAGE_BACKEND                       = "azure"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = "false"
    WEBSITES_PORT                         = "8000"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "sgi-spark-api-staging"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_sgi_staging0.id
  tags = {
    app         = "sgi"
    environment = "staging"
    managedBy   = "bicep"
    repo        = "SPARKGY/SGI"
  }
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    container_registry_use_managed_identity = true
    health_check_path                       = "/health"
    health_check_eviction_time_in_min       = 2
    http2_enabled                           = true
  }
}
resource "azurerm_linux_web_app" "sites_sgi_spark_web_prod0" {
  app_settings = {
    API_INTERNAL_URL_INFORMATIVO        = "https://sgi-spark-api-prod.azurewebsites.net"
    NEXT_TELEMETRY_DISABLED             = "1"
    NODE_ENV                            = "production"
    SCM_DO_BUILD_DURING_DEPLOYMENT      = "false"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "3000"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "sgi-spark-web-prod"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_sgi_prod0.id
  tags = {
    app         = "sgi"
    environment = "prod"
    managedBy   = "bicep"
    repo        = "SPARKGY/SGI"
  }
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    container_registry_use_managed_identity = true
    health_check_path                       = "/login"
    health_check_eviction_time_in_min       = 2
    http2_enabled                           = true
  }
}
resource "azurerm_linux_web_app" "sites_sgi_spark_web_staging0" {
  app_settings = {
    API_INTERNAL_URL_INFORMATIVO        = "https://sgi-spark-api-staging.azurewebsites.net"
    NEXT_TELEMETRY_DISABLED             = "1"
    NODE_ENV                            = "production"
    SCM_DO_BUILD_DURING_DEPLOYMENT      = "false"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "3000"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "sgi-spark-web-staging"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_sgi_staging0.id
  tags = {
    app         = "sgi"
    environment = "staging"
    managedBy   = "bicep"
    repo        = "SPARKGY/SGI"
  }
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    container_registry_use_managed_identity = true
    health_check_path                       = "/login"
    health_check_eviction_time_in_min       = 2
    http2_enabled                           = true
  }
}
resource "azurerm_linux_web_app" "sites_sgp_api_staging0" {
  app_settings = {
    ACCESS_TOKEN_EXPIRE_MINUTES           = "120"
    ALGORITHM                             = "HS256"
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.app_secrets["sites_sgp_api_staging0.APPLICATIONINSIGHTS_CONNECTION_STRING"]
    AZURE_BLOB_CONTAINER                  = "sgp-adjuntos-staging"
    AZURE_STORAGE_CONNECTION_STRING       = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=storage-connection-string)"
    CORS_ORIGINS                          = "https://sgp-staging.tools.sparkgy.com,https://sgp-web-staging.azurewebsites.net"
    DATABASE_URL                          = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=sgp-database-url-staging)"
    ENVIRONMENT                           = "staging"
    SCM_DO_BUILD_DURING_DEPLOYMENT        = "false"
    SECRET_KEY                            = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=sgp-secret-key-staging)"
    STORAGE_BACKEND                       = "azure"
    STORAGE_MAX_MB                        = "25"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = "false"
    WEBSITES_PORT                         = "8000"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "sgp-api-staging"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_sgp_staging0.id
  tags = {
    app         = "sgp"
    environment = "staging"
    managedBy   = "bicep"
    repo        = "SPARKGY/SGP"
  }
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    container_registry_use_managed_identity = true
    health_check_path                       = "/api/v1/health"
    health_check_eviction_time_in_min       = 2
  }
}
resource "azurerm_linux_web_app" "sites_sgp_spark_api_prod0" {
  app_settings = {
    ACCESS_TOKEN_EXPIRE_MINUTES           = "120"
    ACS_CONNECTION_STRING                 = var.app_secrets["sites_sgp_spark_api_prod0.ACS_CONNECTION_STRING"]
    ACS_SENDER_ADDRESS                    = "DoNotReply@bbf6073a-25f5-49e8-bf5c-44a3bb1a132d.azurecomm.net"
    ALGORITHM                             = "HS256"
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.app_secrets["sites_sgp_spark_api_prod0.APPLICATIONINSIGHTS_CONNECTION_STRING"]
    AZURE_BLOB_CONTAINER                  = "sgp-adjuntos"
    AZURE_STORAGE_CONNECTION_STRING       = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=storage-connection-string)"
    CORS_ORIGINS                          = "https://sgp.tools.sparkgy.com,https://sgp-spark-web-prod.azurewebsites.net"
    DATABASE_URL                          = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=sgp-database-url-prod)"
    ENVIRONMENT                           = "prod"
    GITHUB_FEEDBACK_LABELS                = "feedback"
    GITHUB_REPO                           = "SPARKGY/SGP"
    GITHUB_TOKEN                          = var.app_secrets["sites_sgp_spark_api_prod0.GITHUB_TOKEN"]
    NOTIFICACIONES_ACTIVAS                = "true"
    OTEL_RESOURCE_ATTRIBUTES              = "deployment.environment=prod"
    OTEL_SERVICE_NAME                     = "sgp-api-prod"
    OTEL_TRACES_SAMPLER_ARG               = "1.0"
    PUBLIC_API_URL                        = "https://sgp-spark-api-prod.azurewebsites.net"
    PUBLIC_URL                            = "https://sgp.tools.sparkgy.com"
    SCM_DO_BUILD_DURING_DEPLOYMENT        = "false"
    SECRET_KEY                            = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=sgp-secret-key-prod)"
    SESSION_MAX_MINUTES                   = "720"
    STORAGE_BACKEND                       = "azure"
    STORAGE_MAX_MB                        = "25"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = "false"
    WEBSITES_PORT                         = "8000"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "sgp-spark-api-prod"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_sgp_prod0.id
  tags = {
    app         = "sgp"
    environment = "prod"
    managedBy   = "bicep"
    repo        = "SPARKGY/SGP"
  }
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    container_registry_use_managed_identity = true
    health_check_path                       = "/api/v1/health"
    health_check_eviction_time_in_min       = 2
    http2_enabled                           = true
  }
}
resource "azurerm_linux_web_app" "sites_sgp_spark_api_staging0" {
  app_settings = {
    ACCESS_TOKEN_EXPIRE_MINUTES           = "120"
    ALGORITHM                             = "HS256"
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.app_secrets["sites_sgp_spark_api_staging0.APPLICATIONINSIGHTS_CONNECTION_STRING"]
    AZURE_BLOB_CONTAINER                  = "sgp-adjuntos-staging"
    AZURE_STORAGE_CONNECTION_STRING       = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=storage-connection-string)"
    CORS_ORIGINS                          = "https://sgp-staging.tools.sparkgy.com,https://sgp-spark-web-staging.azurewebsites.net"
    DATABASE_URL                          = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=sgp-database-url-staging)"
    ENVIRONMENT                           = "staging"
    OTEL_RESOURCE_ATTRIBUTES              = "deployment.environment=staging"
    OTEL_SERVICE_NAME                     = "sgp-api-staging"
    OTEL_TRACES_SAMPLER_ARG               = "1.0"
    SCM_DO_BUILD_DURING_DEPLOYMENT        = "false"
    SECRET_KEY                            = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=sgp-secret-key-staging)"
    STORAGE_BACKEND                       = "azure"
    STORAGE_MAX_MB                        = "25"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = "false"
    WEBSITES_PORT                         = "8000"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "sgp-spark-api-staging"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_sgp_staging0.id
  tags = {
    app         = "sgp"
    environment = "staging"
    managedBy   = "bicep"
    repo        = "SPARKGY/SGP"
  }
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    container_registry_use_managed_identity = true
    health_check_path                       = "/api/v1/health"
    health_check_eviction_time_in_min       = 2
    http2_enabled                           = true
  }
}
resource "azurerm_linux_web_app" "sites_sgp_spark_web_prod0" {
  app_settings = {
    API_INTERNAL_URL_INFORMATIVO        = "https://sgp-spark-api-prod.azurewebsites.net"
    NEXT_TELEMETRY_DISABLED             = "1"
    NODE_ENV                            = "production"
    SCM_DO_BUILD_DURING_DEPLOYMENT      = "false"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "3000"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "sgp-spark-web-prod"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_sgp_prod0.id
  tags = {
    app         = "sgp"
    environment = "prod"
    managedBy   = "bicep"
    repo        = "SPARKGY/SGP"
  }
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    container_registry_use_managed_identity = true
    health_check_path                       = "/login"
    health_check_eviction_time_in_min       = 2
    http2_enabled                           = true
  }
}
resource "azurerm_linux_web_app" "sites_sgp_spark_web_staging0" {
  app_settings = {
    API_INTERNAL_URL_INFORMATIVO        = "https://sgp-spark-api-staging.azurewebsites.net"
    NEXT_TELEMETRY_DISABLED             = "1"
    NODE_ENV                            = "production"
    SCM_DO_BUILD_DURING_DEPLOYMENT      = "false"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "3000"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "sgp-spark-web-staging"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_sgp_staging0.id
  tags = {
    app         = "sgp"
    environment = "staging"
    managedBy   = "bicep"
    repo        = "SPARKGY/SGP"
  }
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    container_registry_use_managed_identity = true
    health_check_path                       = "/login"
    health_check_eviction_time_in_min       = 2
    http2_enabled                           = true
  }
}
resource "azurerm_linux_web_app" "sites_sgp_web_prod0" {
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "sgp-web-prod"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_sgp_prod0.id
  tags = {
    app         = "sgp"
    environment = "prod"
    managedBy   = "bicep"
    repo        = "SPARKGY/SGP"
  }
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    container_registry_use_managed_identity = true
    health_check_path                       = "/login"
    health_check_eviction_time_in_min       = 2
  }
}
resource "azurerm_linux_web_app" "sites_sgp_web_staging0" {
  app_settings = {
    API_INTERNAL_URL_INFORMATIVO        = "https://sgp-api-staging.azurewebsites.net"
    NEXT_TELEMETRY_DISABLED             = "1"
    NODE_ENV                            = "production"
    SCM_DO_BUILD_DURING_DEPLOYMENT      = "false"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "3000"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "sgp-web-staging"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_sgp_staging0.id
  tags = {
    app         = "sgp"
    environment = "staging"
    managedBy   = "bicep"
    repo        = "SPARKGY/SGP"
  }
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    container_registry_use_managed_identity = true
    health_check_path                       = "/login"
    health_check_eviction_time_in_min       = 2
  }
}
resource "azurerm_linux_web_app" "sites_timesheet_modulo_prod_lmkezpwwqjch20" {
  app_settings = {
    CENTRIA_ENTRY_TOKEN            = "@Microsoft.KeyVault(SecretUri=https://kvcmslmkezpwwqj.vault.azure.net/secrets/timesheet-prod-modulo-token-entrada-cmpncj1tn0002fxekll89x6w8)"
    CENTRIA_ENTRY_TOKEN_PREVIO     = ""
    CENTRIA_MODULE_CODE            = "timesheet"
    CENTRIA_MODULE_CREDENTIAL      = "@Microsoft.KeyVault(SecretUri=https://kvcmslmkezpwwqj.vault.azure.net/secrets/timesheet-prod-modulo-credencial-cmpncj1tn0002fxekll89x6w8)"
    CENTRIA_URL                    = "https://centria.tools.sparkgy.com"
    DATABASE_URL                   = "@Microsoft.KeyVault(SecretUri=https://kv-ignix-prod.vault.azure.net/secrets/timesheet-modulo-database-url)"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "false"
    WEBSITE_NODE_DEFAULT_VERSION   = "~24"
    WEBSITE_RUN_FROM_PACKAGE       = "1"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "timesheet-modulo-prod-lmkezpwwqjch2"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_centria_plan_prod0.id
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    app_command_line = "node modulo/server.js"
  }
}
resource "azurerm_linux_web_app" "sites_timesheet_modulo_staging_lmkezpwwqjch20" {
  app_settings = {
    CENTRIA_ENTRY_TOKEN            = "@Microsoft.KeyVault(VaultName=kvcmslmkezpwwqj;SecretName=timesheet-staging-modulo-token-entrada-cmpncj1tn0002fxekll89x6w8)"
    CENTRIA_MODULE_CODE            = "timesheet"
    CENTRIA_MODULE_CREDENTIAL      = "@Microsoft.KeyVault(VaultName=kvcmslmkezpwwqj;SecretName=timesheet-staging-modulo-credencial-cmpncj1tn0002fxekll89x6w8)"
    CENTRIA_URL                    = "https://centria-staging-lmkezpwwqjch2.azurewebsites.net"
    DATABASE_URL                   = "@Microsoft.KeyVault(SecretUri=https://kv-ignix-prod.vault.azure.net/secrets/timesheet-staging-modulo-database-url)"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "false"
    WEBSITE_NODE_DEFAULT_VERSION   = "~24"
    WEBSITE_RUN_FROM_PACKAGE       = "1"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "timesheet-modulo-staging-lmkezpwwqjch2"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_ignix_staging0.id
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    app_command_line = "node modulo/server.js"
  }
}
resource "azurerm_linux_web_app" "sites_timesheet_prod_lmkezpwwqjch20" {
  app_settings = {
    ACS_CONNECTION_STRING           = var.app_secrets["sites_timesheet_prod_lmkezpwwqjch20.ACS_CONNECTION_STRING"]
    ACS_SENDER_ADDRESS              = "DoNotReply@bbf6073a-25f5-49e8-bf5c-44a3bb1a132d.azurecomm.net"
    APP_ENV                         = "prod"
    CENTRIA_API_TOKEN               = "@Microsoft.KeyVault(VaultName=kvcmslmkezpwwqj;SecretName=timesheet-prod-modulo-credencial-cmpncj1tn0002fxekll89x6w8)"
    CENTRIA_API_URL                 = "https://centria.tools.sparkgy.com"
    DATABASE_URL                    = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=timesheet-database-url)"
    FERIADOS_SYNC_TOKEN             = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-feriados-token-2)"
    FERIADOS_SYNC_TOKEN_PREVIO      = ""
    NEXT_TELEMETRY_DISABLED         = "1"
    PROGRAMADOR_AZURE_ENABLED       = "false"
    SCM_DO_BUILD_DURING_DEPLOYMENT  = "false"
    SYNC_SCHEDULE_TOKEN             = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-sync-schedule-token)"
    SYNC_SCHEDULE_TOKEN_PREVIO      = ""
    TIMESHEET_ADMINS                = ""
    TIMESHEET_BASE_PATH             = "/api/timesheets"
    TIMESHEET_INTERNAL_TOKEN        = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-internal-token)"
    TIMESHEET_INTERNAL_TOKEN_PREVIO = ""
    TIMESHEET_TENANT_ID             = "cmpncj1tn0002fxekll89x6w8"
    TIMESHEET_URL_PUBLICA           = "https://centria.tools.sparkgy.com/timesheets"
    TURECIBO_PASSWORD               = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=turecibo-password)"
    TURECIBO_URL                    = "https://api.turecibo.com"
    TURECIBO_USER                   = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=turecibo-username)"
    WEBSITE_NODE_DEFAULT_VERSION    = "~20"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "timesheet-prod-lmkezpwwqjch2"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_centria_plan_prod0.id
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    app_command_line                  = "node scripts/iniciar.mjs"
    health_check_path                 = "/api/timesheets/api/health"
    health_check_eviction_time_in_min = 2
  }
}
resource "azurerm_linux_web_app" "sites_timesheet_staging_lmkezpwwqjch20" {
  app_settings = {
    ACS_CONNECTION_STRING           = var.app_secrets["sites_timesheet_staging_lmkezpwwqjch20.ACS_CONNECTION_STRING"]
    ACS_SENDER_ADDRESS              = ""
    APP_ENV                         = "staging"
    CENTRIA_API_TOKEN               = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=timesheet-staging-modulo-credential)"
    CENTRIA_API_URL                 = "https://centria-staging-lmkezpwwqjch2.azurewebsites.net"
    DATABASE_URL                    = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=timesheet-staging-database-url)"
    FERIADOS_SYNC_TOKEN             = ""
    FERIADOS_SYNC_TOKEN_PREVIO      = ""
    NEXT_TELEMETRY_DISABLED         = "1"
    PROGRAMADOR_AZURE_ENABLED       = "false"
    SCM_DO_BUILD_DURING_DEPLOYMENT  = "false"
    SYNC_SCHEDULE_TOKEN             = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-staging-sync-schedule-token)"
    SYNC_SCHEDULE_TOKEN_PREVIO      = ""
    TIMESHEET_ADMINS                = ""
    TIMESHEET_BASE_PATH             = "/api/timesheets"
    TIMESHEET_INTERNAL_TOKEN        = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=kairos-staging-internal-token)"
    TIMESHEET_INTERNAL_TOKEN_PREVIO = ""
    TIMESHEET_MAIL_DISABLED         = "1"
    TIMESHEET_TENANT_ID             = "cmpncj1tn0002fxekll89x6w8"
    TIMESHEET_URL_PUBLICA           = ""
    TURECIBO_DISABLED               = "1"
    TURECIBO_PASSWORD               = ""
    TURECIBO_URL                    = ""
    TURECIBO_USER                   = ""
    WEBSITE_NODE_DEFAULT_VERSION    = "~20"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "timesheet-staging-lmkezpwwqjch2"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_asp_ignix_staging0.id
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    app_command_line                  = "node scripts/iniciar.mjs"
    health_check_path                 = "/api/timesheets/api/health"
    health_check_eviction_time_in_min = 2
    ip_restriction {
      ip_address = "20.206.176.11/32"
      priority   = 100
    }
    ip_restriction {
      ip_address = "20.206.176.27/32"
      priority   = 101
    }
    ip_restriction {
      ip_address = "74.163.200.172/32"
      priority   = 102
    }
    ip_restriction {
      ip_address = "74.163.200.176/32"
      priority   = 103
    }
    ip_restriction {
      ip_address = "74.163.200.184/32"
      priority   = 104
    }
    ip_restriction {
      ip_address = "74.163.200.190/32"
      priority   = 105
    }
    ip_restriction {
      ip_address = "74.163.200.218/32"
      priority   = 106
    }
    ip_restriction {
      ip_address = "74.163.200.224/32"
      priority   = 107
    }
    ip_restriction {
      ip_address = "74.163.200.252/32"
      priority   = 108
    }
    ip_restriction {
      ip_address = "74.163.200.255/32"
      priority   = 109
    }
    ip_restriction {
      ip_address = "74.163.201.0/32"
      priority   = 110
    }
    ip_restriction {
      ip_address = "74.163.201.153/32"
      priority   = 111
    }
    ip_restriction {
      ip_address = "74.163.201.156/32"
      priority   = 112
    }
    ip_restriction {
      ip_address = "74.163.201.161/32"
      priority   = 113
    }
    ip_restriction {
      ip_address = "74.163.201.168/32"
      priority   = 114
    }
    ip_restriction {
      ip_address = "74.163.201.17/32"
      priority   = 115
    }
    ip_restriction {
      ip_address = "74.163.201.217/32"
      priority   = 116
    }
    ip_restriction {
      ip_address = "74.163.201.224/32"
      priority   = 117
    }
    ip_restriction {
      ip_address = "74.163.201.246/32"
      priority   = 118
    }
    ip_restriction {
      ip_address = "74.163.201.248/32"
      priority   = 119
    }
    ip_restriction {
      ip_address = "74.163.201.8/32"
      priority   = 120
    }
    ip_restriction {
      ip_address = "74.163.201.91/32"
      priority   = 121
    }
    ip_restriction {
      ip_address = "74.163.202.173/32"
      priority   = 122
    }
    ip_restriction {
      ip_address = "74.163.202.184/32"
      priority   = 123
    }
    ip_restriction {
      ip_address = "74.163.202.187/32"
      priority   = 124
    }
    ip_restriction {
      ip_address = "74.163.202.21/32"
      priority   = 125
    }
    ip_restriction {
      ip_address = "74.163.202.221/32"
      priority   = 126
    }
    ip_restriction {
      ip_address = "74.163.202.223/32"
      priority   = 127
    }
    ip_restriction {
      ip_address = "74.163.202.26/32"
      priority   = 128
    }
    ip_restriction {
      ip_address = "74.163.202.3/32"
      priority   = 129
    }
    ip_restriction {
      ip_address = "74.163.202.55/32"
      priority   = 130
    }
    ip_restriction {
      ip_address = "74.163.202.58/32"
      priority   = 131
    }
  }
}
resource "azurerm_linux_web_app" "sites_turecibo_modulo_staging0" {
  app_settings = {
    CENTRIA_BASE_URL                    = "https://centria-staging-lmkezpwwqjch2.azurewebsites.net"
    CENTRIA_ENTRY_TOKEN                 = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=turecibo-staging-modulo-entry-token)"
    CENTRIA_MODULE_CODE                 = "turecibo"
    CENTRIA_MODULE_NAME                 = "TuRecibo"
    CENTRIA_SERVICE_TOKEN               = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=turecibo-staging-modulo-credential)"
    CENTRIA_URL                         = "https://centria-staging-lmkezpwwqjch2.azurewebsites.net"
    DATABASE_URL                        = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=turecibo-staging-database-url)"
    FERIADOS_TOKEN                      = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=turecibo-staging-feriados-token)"
    NEXT_TELEMETRY_DISABLED             = "1"
    NODE_ENV                            = "production"
    PORT                                = "8080"
    PROGRAMADOR_AZURE_ENABLED           = "true"
    SYNC_TOKEN                          = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=turecibo-staging-sync-token)"
    TURECIBO_PASSWORD                   = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=turecibo-password)"
    TURECIBO_USER                       = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=turecibo-username)"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "8080"
  }
  client_affinity_enabled                  = true
  ftp_publish_basic_authentication_enabled = false
  https_only                               = true
  location                                 = "brazilsouth"
  name                                     = "turecibo-modulo-staging"
  resource_group_name                      = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id                          = azurerm_service_plan.server_farms_asp_ignix_staging0.id
  tags = {
    entorno = "staging"
    modulo  = "turecibo"
  }
  webdeploy_publish_basic_authentication_enabled = false
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    container_registry_use_managed_identity = true
    health_check_path                       = "/"
    health_check_eviction_time_in_min       = 2
  }
}
resource "azurerm_linux_web_app" "sites_turecibo_prod0" {
  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.app_secrets["sites_turecibo_prod0.APPLICATIONINSIGHTS_CONNECTION_STRING"]
    CENTRIA_BASE_URL                      = "@Microsoft.KeyVault(VaultName=turecibo-prod-kv;SecretName=centria-base-url)"
    CENTRIA_ENTRY_TOKEN                   = "@Microsoft.KeyVault(VaultName=kvcmslmkezpwwqj;SecretName=turecibo-prod-modulo-token-entrada-cmpncj1tn0002fxekll89x6w8)"
    CENTRIA_MODULE_CODE                   = "turecibo"
    CENTRIA_MODULE_NAME                   = "Tu Recibo"
    CENTRIA_SERVICE_TOKEN                 = "@Microsoft.KeyVault(VaultName=kvcmslmkezpwwqj;SecretName=turecibo-prod-modulo-credencial-cmpncj1tn0002fxekll89x6w8)"
    DATABASE_URL                          = "@Microsoft.KeyVault(VaultName=turecibo-prod-kv;SecretName=database-url)"
    FERIADOS_AZURE_ENABLED                = "true"
    FERIADOS_PANEL_PASSWORD               = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=turecibo-password)"
    FERIADOS_PANEL_USER                   = "@Microsoft.KeyVault(VaultName=kv-ignix-prod;SecretName=turecibo-username)"
    FERIADOS_TOKEN                        = "@Microsoft.KeyVault(VaultName=turecibo-prod-kv;SecretName=feriados-token)"
    KEY_VAULT_PREFIJO                     = "turecibo"
    KEY_VAULT_URL                         = "https://turecibo-prod-kv.vault.azure.net/"
    NEXT_TELEMETRY_DISABLED               = "1"
    NODE_ENV                              = "production"
    PORT                                  = "8080"
    PROGRAMADOR_AZURE_ENABLED             = "true"
    PUBLICACION_AUSENCIAS_DIAS            = "180"
    PUBLICACION_AUSENCIAS_DIAS_MAX        = "1098"
    SYNC_TOKEN                            = "@Microsoft.KeyVault(VaultName=turecibo-prod-kv;SecretName=sync-token)"
    TURECIBO_PASSWORD                     = "@Microsoft.KeyVault(VaultName=turecibo-prod-kv;SecretName=turecibo-password)"
    TURECIBO_USER                         = "@Microsoft.KeyVault(VaultName=turecibo-prod-kv;SecretName=turecibo-user)"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = "false"
    WEBSITES_PORT                         = "8080"
  }
  client_affinity_enabled = true
  https_only              = true
  location                = "brazilsouth"
  name                    = "turecibo-prod"
  resource_group_name     = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  service_plan_id         = azurerm_service_plan.server_farms_centria_plan_prod0.id
  tags = {
    contrato = "centria"
    entorno  = "prod"
    modulo   = "turecibo"
  }
  auth_settings {
    enabled                       = false
    token_refresh_extension_hours = 0
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    container_registry_use_managed_identity = true
    health_check_path                       = "/centria/salud"
    health_check_eviction_time_in_min       = 2
  }
}
resource "azurerm_monitor_smart_detector_alert_rule" "smart_detector_alert_rules_failure_anomalies_appi_ignix_prod0" {
  description         = "Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls."
  detector_type       = "FailureAnomaliesDetector"
  frequency           = "PT1M"
  name                = "Failure Anomalies - appi-ignix-prod"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  scope_resource_ids  = ["/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/resourceGroups/rg-ignixcommsuite-prod/providers/microsoft.insights/components/appi-ignix-prod"]
  severity            = "Sev3"
  action_group {
    ids = ["/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/resourceGroups/rg-ignixcommsuite-prod/providers/Microsoft.Insights/actionGroups/application insights smart detection"]
  }
}
resource "azurerm_monitor_smart_detector_alert_rule" "smart_detector_alert_rules_failure_anomalies_turecibo_prod_ai0" {
  description         = "Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls."
  detector_type       = "FailureAnomaliesDetector"
  frequency           = "PT1M"
  name                = "Failure Anomalies - turecibo-prod-ai"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  scope_resource_ids  = ["/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/resourceGroups/rg-ignixcommsuite-prod/providers/microsoft.insights/components/turecibo-prod-ai"]
  severity            = "Sev3"
  action_group {
    ids = ["/subscriptions/dc7a59f3-0f26-449c-adb4-e822fd893336/resourceGroups/rg-ignixcommsuite-prod/providers/Microsoft.Insights/actionGroups/application insights smart detection"]
  }
}
resource "azurerm_monitor_action_group" "actiongroups_application_insights_smart_detection0" {
  name                = "Application Insights Smart Detection"
  resource_group_name = azurerm_resource_group.resource_groups_rg_ignixcommsuite_prod0.name
  short_name          = "SmartDetect"
  arm_role_receiver {
    name                    = "Monitoring Contributor"
    role_id                 = "749f88d5-cbae-40b8-bcfc-e573ddc772fa"
    use_common_alert_schema = true
  }
  arm_role_receiver {
    name                    = "Monitoring Reader"
    role_id                 = "43d0d8ad-25c7-4714-9337-8ba259a9fe05"
    use_common_alert_schema = true
  }
}
resource "azurerm_nat_gateway_public_ip_association" "nat_centriabkp_pip" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gateways_nat_centriabkp_202609280.id
  public_ip_address_id = azurerm_public_ip.public_ip_addresses_pip_centriabkp_202609280.id
}
