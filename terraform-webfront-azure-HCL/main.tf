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

  recipe_name         = var.recipe_name
  client_id           = var.client_id
  client_secret       = var.client_secret
  subscription_id     = var.subscription_id
  vnet_name           = var.vnet_name
  subnet_name         = var.subnet_name
  vnet_resource_group = var.vnet_resource_group
  location            = var.location

  resource           = var.resource
  environment_sn     = var.environment_sn
  system_sn          = var.system_sn
  componentkey_sn    = var.componentkey_sn
  resource_group     = var.resource_group
  vm_count           = var.vm_count
  OperatingSystem    = var.operating_system
  marketplace_image  = var.marketplace_image
  custom_image       = var.custom_image
  frontend_name      = var.frontend_name
  domain             = var.domain
  environment_puppet = var.environment_puppet
  ad_sg_names        = var.ad_sg_names
}

terraform {
  backend "azurerm" {}
}




