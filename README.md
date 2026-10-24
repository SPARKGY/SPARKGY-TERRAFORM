# SPARK-TERRAFORM

Infraestructura actual de Azure, importada para mantenerla desde acá. El import solo leyó Azure: no creó, no cambió y no borró recursos.

Suscripción `Azure subscription 1` (`dc7a59f3-0f26-449c-adb4-e822fd893336`), tenant SPARK ENERGY SOLUTIONS, cuenta `ngmico@sparkgy.com`.

| Stack | Resource group | Recursos en el state |
|---|---|---|
| `rg-ignixpunch-prod` | `rg-ignixpunch-prod` | el resource group, vacío |
| `rg-ignixcommsuite-prod` | `rg-ignixcommsuite-prod` | 118 recursos |

`rg-ignixcommsuite-prod` tiene un lock `CanNotDelete` llamado `DoNotDelete`. Está importado.

## Qué no entró

Tres storage accounts no se pueden importar con el provider `azurerm` 4.80.0: tienen deshabilitada la autenticación por clave y el import intenta leer las queue properties con esa clave. Siguen en Azure, fuera de este state:

- `stjanusprod`
- `stjanusstaging`
- `stplanospidstage`

## Secretos

Los app settings que apuntan a Key Vault quedaron como referencia. Los que tenían el valor en claro se movieron a `rg-ignixcommsuite-prod/terraform.tfvars`, que está en `.gitignore`. El state local también tiene secretos y tampoco se versiona.

`terraform plan` en `rg-ignixpunch-prod` no propone cambios. En `rg-ignixcommsuite-prod` propone 51 updates in-place y cero altas o bajas: el provider no puede expresar algunos valores tal como están en Azure (por ejemplo namespaces de alertas vacíos, health checks y certificados ya cargados). No correr `terraform apply` hasta revisar ese plan.
