resource "azurerm_container_app_environment" "container_app_environment" {
    for_each = var.locations
    name                = "${var.project_name}-container-app-env-${each.key}"
    location            = each.value
    resource_group_name = azurerm_resource_group.rg.name
    logs_destination = "azure-monitor"
}

resource "azurerm_container_app_job" "container_app_job" {
    for_each = var.locations
    name                = "${var.project_name}-job-${each.key}"
    location            = each.value
    resource_group_name = azurerm_resource_group.rg.name
    container_app_environment_id = azurerm_container_app_environment.container_app_environment[each.key].id
    replica_timeout_in_seconds = 600
    template {
      container {
        name   = "${var.project_name}-container-${each.key}"
        image  = "ghcr.io/joystick01/anycast-tracker:main"
        cpu    = "0.25"
        memory = "0.5Gi"
        env {
            name = "REGION"
            value = each.key
        }
        env {
            name = "URL"
            value = azurerm_cosmosdb_account.cosmosdb_account.endpoint
        }
        env {
            name = "KEY"
            value = azurerm_cosmosdb_account.cosmosdb_account.primary_key
        }
        env {
            name = "DATABASE_NAME"
            value = azurerm_cosmosdb_sql_database.cosmosdb_sql_database.name
        }
        env {
            name = "CONTAINER_NAME_V4"
            value = azurerm_cosmosdb_sql_container.ipv4_cosmosdb_sql_container.name
        }
        env {
            name = "CONTAINER_NAME_V6"
            value = azurerm_cosmosdb_sql_container.ipv6_cosmosdb_sql_container.name
        }
      }
    }
    schedule_trigger_config {
        # The cron expression for the schedule trigger every 30 minutes
      cron_expression = "0 */30 * * *"
    }
}