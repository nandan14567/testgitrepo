variable "location" {
}
variable "resource_group" {
}
variable "vnet_name" {
}
variable "vnet_resource_group" {
}
variable "recipe_name" {
}
variable "frontend_name" {
  description = "(Required) Specifies the name of the frontend ip configuration."
}
variable "lb_probe_unhealthy_threshold" {
  description = "Number of times the load balancer health probe has an unsuccessful attempt before considering the endpoint unhealthy."
  default     = 2
}
variable "lb_probe_interval" {
  description = "Interval in seconds the load balancer health probe rule does a check"
  default     = 15
}
variable "remote_port" {
  default = { ssh = ["Tcp", "22"] }
}
variable "lb_port" {
  #  default={ http  = ["80", "Tcp", "80"]
  #    https = ["443", "Tcp", "443"]
  #  }
}
variable "subscription_id" {
}
variable "domain" {
}
variable "environment_puppet" {
}
variable "operating_system" {
}
variable "resource" {
}
variable "client_id" {
}
variable "client_secret" {
}
variable "vm_count" {
  description = "enter the vmcount"
}
variable "subnet_name" {
}
variable "ad_sg_names" {
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







