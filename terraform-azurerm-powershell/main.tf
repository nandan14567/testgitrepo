#Creating security group for ec2 instances
provider "azurerm" {
  tenant_id                  = "${var.tenant_id}"
  subscription_id            = "${var.subscription_id}"
  client_id                  = "${var.client_id}"
  client_secret              = "${var.client_secret}"
  skip_provider_registration = true
  features {}
}
module "terraform-azurerm-powershell" {
  source        = "./module/azurerm-powershell"
  client_id     = "${var.client_id}"
  client_secret = "${var.client_secret}"

  environment_sn  = "${var.environment_sn}"
  system_sn       = "${var.system_sn}"
  componentKey_sn = "${var.componentKey_sn}"
  vm_count        = "${var.vm_count}"

  subscription_id     = "${var.subscription_id}"
  resource_group_name = "${var.resource_group_name}"
  domain              = "${var.domain}"
  environment_puppet  = "${var.environment_puppet}"
  provider_name       = "${var.provider_name}"
  operating_system    = "${var.operating_system}"

  toemail_ids = "${var.toemail_ids}"

  admin_username          = "${var.admin_username}"
  admin_password          = "${var.admin_password}"
  vmname_prefix           = "${var.vmname_prefix}"
  vnet_id                 = "${var.vnet_id}"
  lb_private_ipaddress    = "${var.lb_private_ipaddress}"
  avset_updatedomaincount = "${var.avset_updatedomaincount}"
  avset_faultdomaincount  = "${var.avset_faultdomaincount}"

}
