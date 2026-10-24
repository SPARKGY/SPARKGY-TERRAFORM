variable "app_secrets" {
  description = "App settings que hoy no son referencia de Key Vault. Los valores viven en terraform.tfvars, que no se versiona."
  type        = map(string)
  sensitive   = true
}
