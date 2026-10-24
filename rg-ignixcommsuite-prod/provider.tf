provider "azurerm" {
  features {
  }
  use_oidc                        = false
  resource_provider_registrations = "none"
  subscription_id                 = "dc7a59f3-0f26-449c-adb4-e822fd893336"
  environment                     = "public"
  tenant_id                       = "93a9d1eb-0e13-4963-bc57-a47c548f2690"
  use_msi                         = false
  use_cli                         = true
}
