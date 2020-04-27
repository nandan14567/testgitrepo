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
}

#Creating security group for load balancer
module "alb_security_group" {
  source              = "./modules/security-group"
  security_group_name = var.lb_security_group["name"]
  tcp_ports           = var.lb_security_group["ports"]
  cidrs               = var.lb_security_group["cidrs"]
  vpc_id              = var.vpc_id
}

#Calling Servernaming API using custom provider
data "servernamingapi" "servernaming" {
  uri = "https://onecloudapi.deloitte.com/servernaming/20190215/ServerNaming"
  environment= var.environment_servernaming
	system= var.system_servernaming
  componentkey=var.componentKey_servernaming
  numberservers=var.ec2-count
  
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
  ec2_subnet_id                = var.ec2_subnet_id
  instance_names               = jsondecode(data.servernamingapi.servernaming.body).components[0].servers
  instance_security_group      = [module.instance_security_group.Security_Group_Id]
  instance_security_group_name = [module.instance_security_group.Security_Group_Name]
  aws_lb_security_group        = [module.alb_security_group.Security_Group_Id]
  AccountID                    = var.AccountID_Puppet
  ResourceLocation             = var.region
  Domain                       = var.Domain_Puppet
  Environment                  = var.Environment_Puppet
  Provider                     = var.Provider_Puppet
  OperatingSystem              = var.OperatingSystem_Puppet
  instance_role                = var.instance_role
  key_name                     = var.key_name
  client_id                    = var.client_id
  client_secret                = var.client_secret
  resource                     = var.resource
  SecurityGroup_Administrators = var.SecurityGroup_Administrators
}

#  terraform {
#      backend "azurerm" {}
#  }
