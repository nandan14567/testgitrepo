# Configure the AWS Provider
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

#creating internal application load balancer
module "application_load_balancer" {
  source                       = "./modules/aws-load-balancer"
  recipe_name                  = var.recipe_name
  ami_id                       = var.ami_id
  vpc_id                       = var.vpc_id
  instance_type                = var.instance_type
  ec2-count                    = var.ec2-count
  https_listeners              = var.https_listeners
  ec2_subnet_id                = var.ec2_subnet_id
  instance_role                = var.instance_role
  key_name                     = var.key_name
  token                        = var.token 
  client_id                    = var.client_id
  client_secret                = var.client_secret
  puppet                       = var.puppet
  servernaming                 = var.servernaming
  ec2_security_group           = var.ec2_security_group
  lb_security_group           = var.lb_security_group
  SecurityGroup_Administrators = var.SecurityGroup_Administrators
}

output "puppet_response" {
  value = [module.application_load_balancer.puppet_response]
}
//  terraform {
//      backend "azurerm" {}
//  }
