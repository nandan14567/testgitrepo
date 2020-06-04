variable "region"{
    type = string
}
variable "recipe_name"{
    type = string
}
variable "recipe_cidrs"{
    type    = list(string)
}
variable "instance_count"{
    type = number
}
variable "instance_ports"{
    type    = list(string)
}
variable "vpc_id"{
    type = string
}
variable "instance_subnet_id"{
    type = string
}
variable "ami_id" {
    type = string
}
variable "instance_type"{
    type = string
}
variable "instance_role"{
    type = string
}
variable "key_name"{
    type = string
}
variable "certificate_arn"{
    type = string
}
variable "ssl_policy"{
    type = string
}

//Variables for Puppet Payload
variable "accountid_puppet"{
    type = string
}
variable "domain_puppet"{
    type = string
}
variable "environment_puppet"{
    type = string
}
variable "operatingsystem"{
    type = string
}

//Variables for Servernaming Payload
variable "servernaming" {
    type = map
}

//Variables for Token Generation
variable "client_id"{
    type = string
}
variable "client_secret"{
    type = string
}
variable "resource_token"{
    type = string
}

//Variable for Security Group Yaml File
variable "securitygroup_administrators" {
    type = map
}
