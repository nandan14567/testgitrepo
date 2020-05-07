region                       = "us-east-1"
recipe_name                  = "Scrum-IV"
recipe_cidrs                 = ["10.0.0.0/8"]
instance_count               = 2
instance_ports               = ["443", "3389"]
vpc_id                       = "vpc-04093af6b1ff0742b"
instance_subnet_id           = "subnet-0e6e6fe4c02ba8c19"
ami_id                       = "ami-01652280c5135f94b"
instance_type                = "t2.micro"
instance_role                = "EC2SSMAgentProfile"
key_name                     = "testwind"
certificate_arn              = "arn:aws:iam::868978391936:server-certificate/my-SSL-Certificate"
ssl_policy                   = "ELBSecurityPolicy-TLS-1-2-2017-01"
resource_token               = "9f11e6db-715d-45a7-887e-01e00b9bc968"
accountid_puppet             = "868978391936"
domain_puppet                = "us.deloitte.com"
environment_puppet           = "NPD"
operatingsystem              = "windows"
securitygroup_administrators = ["us\\sg-us-868978391936-admin", "us\\sg-us-197151468794-admin"]
servernaming = {
  environment = "AWSTEPD"
  system      = "USTEPD"
  vmAllocationRequest = [
    { componentKey = "WEB"
    numberServers = "2" }
  ]
}
