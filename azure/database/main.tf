resource "azurerm_resource_group" "rg" {
  location = var.rg_location
  name     = var.rg_name
}

resource "azurerm_postgresql_flexible_server" "devops" {
  administrator_login          = var.admin_username
  administrator_password       = var.admin_password
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = false
  location                     = var.location
  name                         = var.db_name
  resource_group_name          = azurerm_resource_group.rg.name
  storage_mb                   = var.storage_mb
  sku_name                     = "GP_Standard_D4s_v3"

  version = var.db_version
  zone    = var.zone

  authentication {
    active_directory_auth_enabled = false
    password_auth_enabled         = true
  }
}
