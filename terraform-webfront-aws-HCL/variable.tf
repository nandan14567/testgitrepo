variable "region"{}
variable "recipe_name"{}
variable "ec2_subnet_id"{}
variable "access_key"{}
variable "secret_key"{}
variable "vpc_id"{}
variable "ami_id" {}
variable "instance_type"{}
variable "ec2-count"{}
variable "https_listeners"{}
variable "instance_role"{}
variable "key_name"{}

//Variables for security Group
variable "ec2_security_group"{}
variable "lb_security_group"{}

//Variables for Puppet Payload
variable "puppet" {}

//Variables for Servernaming Payload
variable "servernaming" {}

//Variables for Token Generation
variable "client_id"{}
variable "client_secret"{}
variable "token"{}

//Variable for Security Group Yaml File
variable "SecurityGroup_Administrators" {}