variable "lb_name" {}
variable "ec2_subnet_id" {}
variable "instance_type" {}
variable "ec2-count" {}
variable "http_tcp_listeners" {}
variable "https_listeners" {}
variable "listener_ssl_policy_default" {}
variable "instance_security_group" {}
variable "aws_lb_security_group" {}
variable "vpc_id" {}
variable "target_group" {}
variable "ami_id" {}
variable "instance_profile" {}
variable "instance_security_group_name" {}
variable "instance_names" {}
variable "instance_role"{}
variable "key_name"{}
variable "client_id" {}
variable "client_secret" {}
variable "resource"{}

//Variables for Puppet Payload
variable "AccountID" {}
variable "ResourceLocation" {}
variable "Domain" {}
variable "Environment" {}
variable "Provider" {}
variable "OperatingSystem" {}

//Variables for Security Group Yaml File
variable "SecurityGroup_Administrators" {}
