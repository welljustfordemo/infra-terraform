variable "admin_password" {}
variable "admin_username" {}
variable "location" {}
variable "db_name" {}
variable "rg_name" {}
variable "rg_location" {}
variable "backup_retention_days" {
  default = "7"
}
variable "storage_mb" {}
variable "db_version" {
  default = "14"
}
variable "zone" {
  default = "1"
}