resource "azurerm_resource_group" "resource_groups_rg_ignixpunch_prod0" {
  location = "brazilsouth"
  name     = "rg-ignixpunch-prod"
  tags = {
    CostCenter  = "SparkTrack"
    Environment = "Production"
    Owner       = "Andres Valero"
    Project     = "IGNIX-PUNCH"
    Vendor      = "SparkTrack"
  }
}
