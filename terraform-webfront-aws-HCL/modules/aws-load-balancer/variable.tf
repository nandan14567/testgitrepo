variable "ec2_subnet_id" {}
variable "instance_type" {}
variable "ec2-count" {}
variable "https_listeners" {}
variable "recipe_name"{}
variable "vpc_id" {}
variable "ami_id" {}
variable "instance_role"{}
variable "key_name"{}

//Variables for Token payload
variable "client_id" {}
variable "client_secret" {}
variable "token"{}

//Variables for Puppet Payload
variable "puppet" {}

//Variables for Security Group Yaml File
variable "SecurityGroup_Administrators" {}

//Variables or servernaming
variable "servernaming"{}

//Variables for Security Group Creation
variable "ec2_security_group"{}
variable "lb_security_group"{}