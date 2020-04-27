provider "azurerm" {
  tenant_id                  = var.tenant_id
  subscription_id            = var.subscription_id
  client_id                  = var.client_id
  client_secret              = var.client_secret
  skip_provider_registration = true
  features {}
}

module "azure-load-balancer-module" {
  source = "./azure-load-balancer"

  client_id           = var.client_id
  client_secret       = var.client_secret
  vnet_name           = var.vnet_name
  subnet_name         = var.subnet_name
  vnet_resource_group = var.vnet_resource_group
  location            = var.location
  resource_group      = var.resource_group
  vm_count            = var.vm_count

  lb_port            = var.lb_port
  frontend_name      = var.frontend_name
  prefix             = var.prefix
  ad_sg_names        = var.ad_sg_names
  golden_image_name  = var.golden_image_name
  img_gallery_name   = var.img_gallery_name
  img_resource_group = var.img_resource_group

  subscription_id    = var.subscription_id
  Domain             = var.domain
  Environment_puppet = var.environment_puppet
  Provider_name      = var.provider_name
  OperatingSystem    = var.operating_system

  resource        = var.resource
  environment_sn  = var.environment_sn
  system_sn       = var.system_sn
  componentKey_sn = var.componentKey_sn
  server_version  = var.server_version
}

# terraform {
#   backend "azurerm" {}
# }




