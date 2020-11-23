# **Terraform AWS Internal Load Balancer Recipe**

Terraform module which creates security group with deloitte cidrs, Load Balancer, Target Group and EC2 Instances based on count within VPC connected to deloitte on premises on AWS.

**These types of resources are Used:**

[aws_security_group](https://www.terraform.io/docs/providers/aws/r/security_group.html) \
[aws_security_group_rule](https://www.terraform.io/docs/providers/aws/r/security_group_rule.html) \
[aws_lb](https://www.terraform.io/docs/providers/aws/r/lb.html) \
[aws_lb_target_group](https://www.terraform.io/docs/providers/aws/r/lb_target_group.html) \
[aws_lb_listener](https://www.terraform.io/docs/providers/aws/r/lb_listener.html) \
[aws_instance](https://www.terraform.io/docs/providers/aws/r/instance.html) \
[aws_lb_target_group_attachment](https://www.terraform.io/docs/providers/aws/r/lb_target_group_attachment.html)

**These types of Data_Sources are used:**

[aws_subnet_ids](https://www.terraform.io/docs/providers/aws/d/subnet_ids.html)

**Custom Provider Data_Source Used:**

restapi - Used to call the deloitte onecloud API Post and Get API'S

## **Usage**
```
module "aws_load_balancer" {
  source                       = "./aws-load-balancer"
  region                       = "us-east-1"
  recipe_name                  = "recipe_aws_lb_myapp"
  recipe_cidrs                 = ["10.0.0.0/8"]
  instance_count               = 3
  instance_ports               = ["443","3389"]
  vpc_id                       = "vpc-04093af6b1ff07"
  instance_subnet_id           = "subnet-0e6e6fe4c02ba8"
  ami_id                       = "ami-01652280c5135f94b"
  instance_type                = "t2.micro"
  instance_role                = "EC2SSMAgentProfile"
  key_name                     = "mykeypair_name"
  certificate_arn              = "arn:aws:iam::8689724291936:server-certificate/mycertificate"
  ssl_policy                   = "ELBSecurityPolicy-TLS-1-2-2017-01"
  resource_token               = "9f11e6db-751d-45a7-887e-01e0cd9bc968"
  client_id                    = "7f11e6db-751d-45a7-887e"
  client_secret                = "11e6db751d45a7887e01"
  accountid_puppet             = "868978252936"
  domain_puppet                = "us.deloitte.com"
  environment_puppet           = "NPD"
  operatingsystem              = "windows"
  servernaming                 = {environment= "AWSPPRD",system= "MyApp",vmAllocationRequest= [{componentKey= "WEB",numberServers="2"}]}
  securitygroup_administrators = {Administrators="US\\SG-US-868971936-Admin","US\\SG-US-197468794-Admin"}
}
```
## **Inputs** 

Note : *Examples are for reference only*

Name | Description | Type | Examples |
---------|---------|---------|---------
 access_key | (Required) This is the AWS access key | String | --
 secret_key | (Required) This is the AWS Secret key | String | --
 region | (Required) This is the AWS region | String | us-east-1
 recipe_name | (Required) Unique name for recipe to name resources while creating| String | aws-alb-webfront
 recipe_cidrs | (Required) Cidr for inboud and outbound internet traffic |  list(string)| ["10.0.0.0/8"]
 instance_count | (Required) Nos of EC2 Instances you want to create| number | 2
 instance_ports | (Required) Ports that your Instances Listen to | list(string) | ["443","3389"]/["443","22"]
 vpc_id | (Required)  vpc_id having deloitte on-prem connectivity | string | vpc-38gs47ed
 instance_subnet_id | (Required) subnet_id belonging to vpc_id  | string | subnet-0e6cgugd8sdgc19
 ami_id | (Required) The AMI to use for the instance | string | ami-01652280c5135f94b
 instance_type | (Required) Size of the instance | string | t2.micro/t2.nano/t2.medium/
 instance_role | (Optional) The IAM Instance Profile to launch the instance with  | string | EC2SSMAgentProfile
 key_name | (Optional) The key name of the Key Pair to use for the instance; which can be managed using the aws_key_pair resource. should be in .pem format | string | testkey
 certificate_arn | (Required) The ARN of the default SSL server certificate. Exactly one certificate is required if the protocol is HTTPS | string | arn:aws:iam::835354328:server-certificate/my-SSL-Certificate
 ssl_policy | (Required) The name of the SSL Policy for the listener for HTTPS protocol| string | ELBSecurityPolicy-TLS-1-2-2017-01
 accountid_puppet | (Required) Valid accountid required for puppet installation | string | --
 domain_puppet | (Required) Valid domain required for puppet installation| string | us.deloitte.com
 environment_puppet | (Required) Valid environment required for puppet installation| string | NPD/SBX
 operatingsystem | (Required) | string | windows/linux
 servernaming | (Required) Json payload for servernaming api | Map/HCL | {environment= "AWSPPRD",system= "USPPRD",vmAllocationRequest= [{componentKey= "WEB",numberServers="2"}]}
 client_id | (Required) Azure client id for token api payload | string | --
 client_secret | (Required) Azure client id for token api payload | string | --
 resource_token | (Required) Resource for token api payload | string | --
 ad_securitygroup | (Required) Elevated Security will be used to give an AD Security Group elevated privileges on a Virtual Machine for both Windows and Linux. | Map/HCL | {Administrators="US\\\SG-US-8689783936-Admin","US\\\SG-US-1971568794-Admin"}
   
---------------------------------------------------------------

 ### Format of Security Groups 

Platform | Format | Example
---------|----------|----------
 Windows | map/HCL | {Administrators="US\\\SG-US-868971936-Admin","US\\\SG-US-197468794-Admin"}
 Linux | map/HCL | { sudo_groups= ["%sg-us-868978936-admin","%sg-us-197158794-admin"],access_groups= ["sg-us-868979136-admin","sg-us-195148794-admin"]}
