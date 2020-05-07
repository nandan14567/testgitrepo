variable "access_key"{}
variable "secret_key"{}
variable "region"{}
variable "recipe_name"{}
variable "recipe_cidrs"{}
variable "instance_count"{}
variable "instance_ports"{}
variable "vpc_id"{}
variable "instance_subnet_id"{}
variable "ami_id" {}
variable "instance_type"{}
variable "instance_role"{}
variable "key_name"{}
variable "certificate_arn"{}
variable "ssl_policy"{}

//Variables for Puppet Payload
variable "accountid_puppet"{}
variable "domain_puppet"{}
variable "environment_puppet"{}
variable "operatingsystem"{}

//Variables for Servernaming Payload
variable "servernaming" {}

//Variables for Token Generation
variable "client_id"{}
variable "client_secret"{}
variable "resource_token"{}

//Variable for Security Group Yaml File
variable "securitygroup_administrators" {}