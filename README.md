# **Terraform AWS Internal Load Balancer Recipe**

Terraform module which creates security group with deloitte cidrs, Load Balancer, Target Group and EC2 Instances based on count within VPC connected to deloitte on premises on AWS.

**These types of resources are Used:**

[aws_security_group](https://www.terraform.io/docs/providers/aws/r/security_group.html) \
[aws_security_group_rule](https://www.terraform.io/docs/providers/aws/r/security_group_rule.html) \
[aws_lb](https://www.terraform.io/docs/providers/aws/r/lb.html) \
[aws_lb_target_group](https://www.terraform.io/docs/providers/aws/r/lb_target_group.html) \
[aws_lb_listener](https://www.terraform.io/docs/providers/aws/r/lb_listener.html) \
[aws_instance](https://www.terraform.io/docs/providers/aws/r/instance.html) \
[aws_lb_target_group_attachment](https://www.terraform.io/docs/providers/aws/r/lb_target_group_attachment.html) \
[null_resource](https://www.terraform.io/docs/providers/null/resource.html)

**These types of Data_Sources are used:**

[aws_subnet_ids](https://www.terraform.io/docs/providers/aws/d/subnet_ids.html) \
[null_data_source](https://www.terraform.io/docs/providers/null/data_source.html)

**Custom Provider Data_Source Used:**

restapi - Used to call the deloitte onecloud API

## **Inputs** 

Note : *Examples are for reference only*

Name | Description | Type | Examples |
---------|----------|---------|-------
 access_key | (Required) This is the AWS access key | String | --
 secret_key | (Required) This is the AWS Secret key | String | --
 region | (Required) This is the AWS region | String | us-east-1
 recipe_name | (Required) Unique name for your recipe for naming resources| String | aws-alb-webfront
 recipe_cidrs | (Required) Cidr for inboud and outbound internet traffic |  map(string)| ["10.0.0.0/8"]
 instance_count | (Required) No of EC2 Instances you want to create| number | 2
 instance_ports | (Required) Ports that your Instances Listen to | map(string) | ["443","3389"]/["443","22"]
 vpc_id | (Required)  vpc_id having deloitte on-prem connectivity | string | vpc-38gs47ed
 instance_subnet_id | (Required) subnet_id belonging to vpc_id  | string | subnet-0e6cgugd8sdgc19
 ami_id | (Required) The AMI to use for the instance | string | ami-01652280c5135f94b
 instance_type | (Required) Size of the instance | string | t2.micro/t2.nano/t2.medium/
 instance_role | (Optional) The IAM Instance Profile to launch the instance with  | string | EC2SSMAgentProfile
 key_name | (Optional) The key name of the Key Pair to use for the instance; which can be managed using the aws_key_pair resource. should be in .pem format | string | testkey
 certificate_arn | (Required) The ARN of the default SSL server certificate. Exactly one certificate is required if the protocol is HTTPS | string | arn:aws:iam::835354328:server-certificate/my-SSL-Certificate
 ssl_policy | (Required) The name of the SSL Policy for the listener for HTTPS protocol| string | ELBSecurityPolicy-TLS-1-2-2017-01
 accountid_puppet | (Required) Valid accountid required or puppet installation | string | --
 domain_puppet | (Required) Valid domain required or puppet installation| string | us.deloitte.com
 environment_puppet | (Required) Valid environment required or puppet installation| string | NPD/SBX
 operatingsystem | (Required) | string | windows/linux
 servernaming | (Required) Json payload for servernaming api |  | {"environment": "AWSPPRD","system": "USPPRD","vmAllocationRequest": [{"componentKey": "WEB","numberServers":"2"}]}
 client_id | (Required) Azure client id for token api payload | string | --
 client_secret | (Required) Azure client id for token api payload | string | --
 resource_token | (Required) Resource for token api payload | string | --
 securitygroup_administrators | (Required) Elevated Security will be used to give an AD Security Group elevated privileges on a Virtual Machine for both Windows and Linux. | map(string) | ["us\\\sg-us-87722574-admin","us\\\sg-us-9063368-admin"] / ["sg-us-87722574-admin","sg-us-9063368-admin"]
   
---------------------------------------------------------------

Note: Format of Security Groups
  
Platform | Format | Example
---------|----------|----------
 Windows | us\\\secuity_group | us\\\sg-us-87722574-admin
 Linux | security_group | sg-us-87722574-admin
 
 
