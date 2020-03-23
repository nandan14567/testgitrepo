 variable "location" {
 }
 variable "resource_group"{
 }
 variable "vnet_name" {
 }
 variable "vnet_resource_group" {
 }
 variable "prefix" {
   description = "(Required) Default prefix to use with your resource names."
 }
 variable "frontend_name" {
   description = "(Required) Specifies the name of the frontend ip configuration."
 }
 variable "lb_probe_unhealthy_threshold" {
   description = "Number of times the load balancer health probe has an unsuccessful attempt before considering the endpoint unhealthy."
   default     = 2
 }
 variable "lb_probe_interval" {
   description = "Interval in seconds the load balancer health probe rule does a check"
   default     = 15
 }
 variable "remote_port" {
     default={ssh = ["Tcp", "22"]}
}
 variable "lb_port" {
   #  default={ http  = ["80", "Tcp", "80"]
   #    https = ["443", "Tcp", "443"]
   #  }
   }
 variable "res_tags" {
 }

 variable "admin_user" {
    description = "User name to use as the admin account on the VMs that will be part of the VM Scale Set"
  
 }

 variable "admin_password" {
   
 }

 variable "subscription_id" {
  
 }
 variable "Domain" {
  
 }
variable "Environment_puppet" {
  
}
 variable "Provider_name" {
 }
 variable "OperatingSystem" {

 }
variable "resource"{
    
}
variable "client_id"{

}
variable "client_secret"{

}
 variable "vm_count" {
     description="enter the vmcount"
  
 }
variable "environment_sn"{

}
variable "system_sn"{
}

variable "componentKey_sn"{

}
variable "server_version" {
  
}

variable "subnet_name" {
  
}

