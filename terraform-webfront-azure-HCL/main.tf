provider "azurerm" {
  tenant_id                  = "${var.tenant_id}"
  subscription_id            = "${var.subscription_id}"
  client_id                  = "${var.client_id}"
  client_secret              = "${var.client_secret}"
  skip_provider_registration = true
  features {}
}

module "azure-load-balancer-module" {
  source = "./azure-load-balancer"

  client_id     = "${var.client_id}"
  client_secret = "${var.client_secret}"

  vnet_name           = "${var.vnet_name}"
  vnet_resource_group = "${var.vnet_resource_group}"

  location       = "${var.location}"
  resource_group = "${var.resource_group}"
  vm_count       = "${var.vm_count}"
  lb_port        = "${var.lb_port}"
  frontend_name  = "${var.frontend_name}"

  res_tags       = "${var.res_tags}"
  prefix         = "${var.prefix}"
  admin_user     = "${var.admin_user}"
  admin_password = "${var.admin_password}"

  subscription_id    = "${var.subscription_id}"
  Domain             = "${var.domain}"
  Environment_puppet = "${var.environment_puppet}"
  Provider_name      = "${var.provider_name}"
  OperatingSystem    = "${var.operating_system}"

  resource        = "${var.resource}"
  environment_sn  = "${var.environment_sn}"
  system_sn       = "${var.system_sn}"
  componentKey_sn = "${var.componentKey_sn}"
  server_version  = "${var.server_version}"
}

terraform {
  backend "azurerm" {}
}




