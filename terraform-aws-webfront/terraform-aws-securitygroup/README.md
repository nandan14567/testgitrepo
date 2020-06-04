# **Terraform AWS Security Group**

Terraform module which creates security group with deloitte cidrs in AWS.

**These types of resources are Used:**

[aws_security_group](https://www.terraform.io/docs/providers/aws/r/security_group.html) \
[aws_security_group_rule](https://www.terraform.io/docs/providers/aws/r/security_group_rule.html) \

## **Inputs** 

Note : *Examples are for reference only*

Name | Description | Type | Examples |
---------|---------|---------|---------
 security_group_name | (Required) Unique name for security group to name resources while creating| String | ec2-security-group
 cidrs | (Required) Cidr for inboud and outbound internet traffic |  list(string)| ["10.0.0.0/8"]
 tcp_ports | (Required) Ports that your Instances/load balancer Listen to | list(string) | ["443","3389"]/["443","22"]
 vpc_id | (Required)  vpc_id having deloitte on-prem connectivity | string | vpc-38gs47ed
 