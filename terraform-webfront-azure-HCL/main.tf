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

  recipe_name          = var.recipe_name
  client_id            = var.client_id
  client_secret        = var.client_secret
  subscription_id      = var.subscription_id
  resource             = var.resource
  servernaming_payload = var.servernaming_payload
  vnet_name            = var.vnet_name
  subnet_name          = var.subnet_name
  vnet_resource_group  = var.vnet_resource_group

  location          = var.location
  resource_group    = var.resource_group
  vm_count          = var.vm_count
  operating_system  = var.operating_system
  marketplace_image = var.marketplace_image
  custom_image      = var.custom_image

  frontend_name      = var.frontend_name
  domain             = var.domain
  environment_puppet = var.environment_puppet
  ad_security_groups = var.ad_security_groups
}

output "puppet_response" {
  value = module.azure-load-balancer-module.puppet_response
}

terraform {
  backend "azurerm" {}
}




