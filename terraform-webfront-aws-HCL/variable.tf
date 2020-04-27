variable "region" {
  description = "AWS region for hosting your network"
}
variable "lb_name" {
}
variable "ec2_subnet_id" {  
}
variable "access_key"{
}
variable "secret_key"{
}
variable "ec2_security_group" {
}
variable "lb_security_group" {
}
variable "vpc_id" {
}
variable "ami_id" {
  #ami-01652280c5135f94b -- windows
  #ami-07ebfd5b3428b6f4d -- linux
}
variable "instance_type" {
}
variable "ec2-count" {
}
variable "http_tcp_listeners" {
}
variable "https_listeners" {
}
variable "listener_ssl_policy_default" {
}
variable "target_group" {
}
variable "instance_profile" {
}
variable "instance_role" {
}
variable "key_name" {
}

//Variables for Puppet Payload
variable "AccountID_Puppet" {}
//variable "ResourceLocation_Puppet" {}
variable "Domain_Puppet" {}
variable "Environment_Puppet"{}
variable "Provider_Puppet"{}
variable "OperatingSystem_Puppet"{}

//Variables for Servernaming Payload
variable "environment_servernaming" {}
variable "system_servernaming" {}
variable "componentKey_servernaming"{}

//Variables for Token Generation
variable "client_id"{}
variable "client_secret"{}
variable "resource"{}

//Variable for Security Group Yaml File
variable "SecurityGroup_Administrators" {}