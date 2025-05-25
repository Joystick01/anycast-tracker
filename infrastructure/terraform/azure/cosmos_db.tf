resource "azurerm_cosmosdb_account" "cosmosdb_account" {
  name = "${var.project_name}-cosmosdb-account"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type = "Standard"
  kind = "GlobalDocumentDB"
  free_tier_enabled = true
  consistency_policy {
    consistency_level = "Session"
  }
  geo_location {
    location = azurerm_resource_group.rg.location
    failover_priority = 0
  } 
}

resource "azurerm_cosmosdb_sql_database" "cosmosdb_sql_database" {
  name                = "${var.project_name}-cosmosdb-sql-database"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "ipv4_cosmosdb_sql_container" {
  name                = "ipv4-${var.project_name}-cosmosdb-sql-container"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
  database_name       = azurerm_cosmosdb_sql_database.cosmosdb_sql_database.name
  partition_key_paths  = ["/utctime", "/region"]
  partition_key_kind = "MultiHash"
  partition_key_version = 2
}

resource "azurerm_cosmosdb_sql_container" "ipv6_cosmosdb_sql_container" {
  name                = "ipv6-${var.project_name}-cosmosdb-sql-container"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
  database_name       = azurerm_cosmosdb_sql_database.cosmosdb_sql_database.name
  partition_key_paths  = ["/utctime", "/region"]
  partition_key_kind = "MultiHash"
  partition_key_version = 2
}