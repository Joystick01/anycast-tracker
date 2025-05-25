output "URL" {
  value = azurerm_cosmosdb_account.cosmosdb_account.endpoint
}

output "KEY" {
  value = nonsensitive(azurerm_cosmosdb_account.cosmosdb_account.primary_key)
}

output "DATABASE_NAME" {
  value = azurerm_cosmosdb_sql_database.cosmosdb_sql_database.name
}

output "CONTAINER_NAME_V4" {
  value = azurerm_cosmosdb_sql_container.ipv4_cosmosdb_sql_container.name
}

output "CONTAINER_NAME_V6" {
  value = azurerm_cosmosdb_sql_container.ipv6_cosmosdb_sql_container.name
}