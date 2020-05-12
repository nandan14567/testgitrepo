variable "resource_group" {
}
variable "vm_count" {
}
variable "tenant_id" {
}
variable "subscription_id" {
}
variable "location" {
}
variable "vnet_name" {
}
variable "vnet_resource_group" {
}
variable "frontend_name" {
}
variable "recipe_name" {
}
variable "client_id" {
}
variable "client_secret" {
}
variable "resource" {
}
variable "domain" {
}
variable "environment_puppet" {
}
variable "operating_system" {
}
variable "subnet_name" {
}
variable "ad_security_groups" {
  default = "not specified"
}
variable "servernaming_payload" {
}
variable "marketplace_image" {
  type = map
  default = {
    publisher = null,
    offer     = null,
    sku       = null
  }
}
variable "custom_image" {
  type = map
  default = {
    image_name           = null,
    gallery_name         = null,
    image_resource_group = null
  }
}







