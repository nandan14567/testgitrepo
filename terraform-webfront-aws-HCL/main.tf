# Configure the AWS Provider
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

#Creating security group for ec2 instances
module "instance_security_group" {
  source              = "./modules/security-group"
  security_group_name = var.ec2_security_group["name"]
  tcp_ports           = var.ec2_security_group["ports"]
  cidrs               = var.ec2_security_group["cidrs"]
  vpc_id              = var.vpc_id
  receipe_tags        = var.receipe_tags

}

#Creating security group for load balancer
module "alb_security_group" {
  source              = "./modules/security-group"
  security_group_name = var.lb_security_group["name"]
  tcp_ports           = var.lb_security_group["ports"]
  cidrs               = var.lb_security_group["cidrs"]
  vpc_id              = var.vpc_id
  receipe_tags        = var.receipe_tags

}

#Calling Servernaming API
data "external" "servernaming" {
  program = ["sh", "${path.module}/servernaming.sh"]
  query = {
    numberServers = var.ec2-count
    environment   = var.environment_servernaming
    system        = var.system_servernaming
    componentKey  = var.componentKey_servernaming
  }
}

#creating internal application load balancer
module "application_load_balancer" {
  source                       = "./modules/aws-load-balancer"
  ami_id                       = var.ami_id
  vpc_id                       = var.vpc_id
  instance_type                = var.instance_type
  ec2-count                    = var.ec2-count
  http_tcp_listeners           = var.http_tcp_listeners
  https_listeners              = var.https_listeners
  listener_ssl_policy_default  = var.listener_ssl_policy_default
  target_group                 = var.target_group
  instance_profile             = var.instance_profile
  lb_name                      = var.lb_name
  receipe_tags                 = var.receipe_tags
  instance_names               = jsondecode(base64decode(data.external.servernaming.result["base64_encoded"])).servers
  instance_security_group      = [module.instance_security_group.Security_Group_Id]
  instance_security_group_name = [module.instance_security_group.Security_Group_Name]
  aws_lb_security_group        = [module.alb_security_group.Security_Group_Id]
  AccountID                    = var.AccountID_Puppet
  ResourceLocation             = var.ResourceLocation_Puppet
  Domain                       = var.Domain_Puppet
  Environment                  = var.Environment_Puppet
  Provider                     = var.Provider_Puppet
  OperatingSystem              = var.OperatingSystem_Puppet
  SecurityGroup                = var.SecurityGroup_Puppet
  instance_role                = var.instance_role
  key_name                     = var.key_name
  client_id                    = var.client_id
  client_secret                = var.client_secret
  resource                     = var.resource
}

#  terraform {
#      backend "azurerm" {}
#  }
