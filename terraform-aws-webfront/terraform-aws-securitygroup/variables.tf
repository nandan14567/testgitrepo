variable "tcp_ports" {
type    = list(string)
}

variable "cidrs" {
type    = list(string)
}

variable "security_group_name" {
type = string
}

variable "vpc_id" {
type = string
}
