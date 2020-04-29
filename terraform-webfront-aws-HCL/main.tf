# Configure the AWS Provider
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

#creating internal application load balancer
module "application_load_balancer" {
  source                       = "./modules/aws-load-balancer"
  region                       = var.region
  recipe_name                  = var.recipe_name
  recipe_cidrs                 = var.recipe_cidrs
  instance_count               = var.instance_count
  instance_ports               = var.instance_ports
  vpc_id                       = var.vpc_id
  instance_subnet_id           = var.instance_subnet_id
  ami_id                       = var.ami_id
  instance_type                = var.instance_type
  instance_role                = var.instance_role
  key_name                     = var.key_name
  certificate_arn              = var.certificate_arn
  ssl_policy                   = var.ssl_policy
  resource_token               = var.resource_token 
  client_id                    = var.client_id
  client_secret                = var.client_secret
  accountid_puppet             = var.accountid_puppet
  domain_puppet                = var.domain_puppet
  environment_puppet           = var.environment_puppet
  operatingsystem              = var.operatingsystem
  servernaming                 = var.servernaming
  securitygroup_administrators = var.securitygroup_administrators
}

output "puppet_response" {
  value = [module.application_load_balancer.puppet_response]
}
//  terraform {
//      backend "azurerm" {}
//  }
