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
  description = "(Required) Specifies the name of the frontend ip configuration."
}
variable "prefix" {
  description = "(Required) Default prefix to use with your resource names."
}
variable "client_id" {
}
variable "client_secret" {
}
variable "admin_user" {
  description = "User name to use as the admin account on the VMs that will be part of the VM Scale Set"

}
variable "admin_password" {
}
variable "lb_port" {
  #  default={ http  = ["80", "Tcp", "80"]
  #    https = ["443", "Tcp", "443"]
  #  }
}
variable "domain" {
}
variable "environment_puppet" {
}
variable "provider_name" {
}
variable "operating_system" {
}
variable "resource" {
}
variable "environment_sn" {
}
variable "system_sn" {
}
variable "componentKey_sn" {
}
variable "server_version" {
}
variable "subnet_name" {  
}
variable "ad_sg_names" {  
}



