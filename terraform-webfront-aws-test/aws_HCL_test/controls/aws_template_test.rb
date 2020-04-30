# copyright: 2018, The Authors
title "security group validation"
testData = inspec.profile.file('terraform.tfstate')
params = JSON.parse(testData)
print params
print params['resources'][0]['instances'][0]['attributes']['vpc_id']

# store output data in variables
VPC_ID = params['resources'][0]['instances'][0]['attributes']['vpc_id']
DNS_NAME =  params['resources'][0]['instances'][0]['attributes']['dns_name']
ALB_ARN = params['resources'][0]['instances'][0]['attributes']['arn']
print VPC_ID
print ALB_ARN
INSTANCE_SECURITY_GROUP_NAME =params['resources'][2]['instances'][0]['attributes']['name']
print INSTANCE_SECURITY_GROUP_NAME
INSTANCE_SECURITY_GROUP_ID = params['resources'][2]['instances'][0]['attributes']['id']
INSTANCE_SECURITY_GROUP_DESC = params['resources'][2]['instances'][0]['attributes']['description']
INSTANCE_SECURITY_GROUP_PROTOCOL = params['resources'][6]['instances'][0]['attributes']['protocol']
ALB_SECURITY_GROUP_ID = params['resources'][1]['instances'][0]['attributes']['id']
ALB_SECURITY_GROUP_PROTOCAL = params['resources'][5]['instances'][0]['attributes']['protocol']
ALB_SECURITY_GROUP_NAME = params['resources'][1]['instances'][0]['attributes']['name']
ALB_SECURITY_GROUP_DESC = params['resources'][1]['instances'][0]['attributes']['description']
ALB_SECURITY_GROUP_CIDR_BLOCK = params['resources'][5]['instances'][0]['attributes']['cidr_blocks'][0]
ALB_SECURITY_GROUP_PORT = params['resources'][5]['instances'][0]['attributes']['from_port']
INSTANCE_SECURITY_GROUP_CIDR_BLOCK = params['resources'][6]['instances'][0]['attributes']['cidr_blocks'][0]
INSTANCE_SECURITY_GROUP_PORT1 = params['resources'][6]['instances'][0]['attributes']['from_port']
INSTANCE_SECURITY_GROUP_PORT2 = params['resources'][6]['instances'][1]['attributes']['from_port']
CIDR_BLOCK = params['resources'][4]['instances'][0]['attributes']['cidr_blocks'][0]
EC2_INSTANCE_ID = params['resources'][7]['instances'][0]['attributes']['id']
EC2_INSTANCE_AMIID = params['resources'][7]['instances'][0]['attributes']['ami']
EC2_INSTANCE_INSTANCE_TYPE = params['resources'][7]['instances'][0]['attributes']['instance_type']
EC2_INSTANCE_KEYNAME = params['resources'][7]['instances'][0]['attributes']['key_name']
EC2_INSTANCE_AVAILABILITY_ZONE = params['resources'][7]['instances'][0]['attributes']['availability_zone']
IAM_INSTANCE_PROFILE = params['resources'][7]['instances'][0]['attributes']['iam_instance_profile'] 
SUBNET1 = params['resources'][8]['instances'][0]['attributes']['ids'][0]
SUBNET2 = params['resources'][8]['instances'][0]['attributes']['ids'][1]

control "security group name validation" do                        
  impact 0.7                                
  title "security group validation with in one VPC"             
  desc "An optional description..."
  describe aws_security_group(group_name: INSTANCE_SECURITY_GROUP_NAME, group_id:INSTANCE_SECURITY_GROUP_ID, vpc_id: VPC_ID) do
    it { should exist }
    its ('description') {should eq INSTANCE_SECURITY_GROUP_DESC}
  end
end

control "security group inbound/outbound control" do                        
  impact 0.7                                
  title "inbound/outbound rules validation "             
  desc "An optional description..."
  describe aws_security_group(group_name: INSTANCE_SECURITY_GROUP_NAME) do
    it { should allow_in(port: INSTANCE_SECURITY_GROUP_PORT1, ipv4_range: INSTANCE_SECURITY_GROUP_CIDR_BLOCK) }
    it { should allow_in(port: INSTANCE_SECURITY_GROUP_PORT2, ipv4_range: INSTANCE_SECURITY_GROUP_CIDR_BLOCK) }
    it { should allow_in(protocol: INSTANCE_SECURITY_GROUP_PROTOCOL) }
    it { should_not allow_in(ipv4_range: CIDR_BLOCK) }
  end
end

control "alb_security group name validation" do                       
  impact 0.7                                
  title "alb_security group validation with in one VPC"             
  desc "An optional description..."
  describe aws_security_group(group_name: ALB_SECURITY_GROUP_NAME, group_id:ALB_SECURITY_GROUP_ID, vpc_id: VPC_ID) do
    it { should exist }
    its ('description') {should eq ALB_SECURITY_GROUP_DESC}
  end
end

control "alb_security group inbound/outbound control" do                        
  impact 0.7                                
  title "inbound/outbound rules validation "             
  desc "An optional description..."
  describe aws_security_group(group_name: ALB_SECURITY_GROUP_NAME) do
    it { should allow_in(port: ALB_SECURITY_GROUP_PORT, ipv4_range: ALB_SECURITY_GROUP_CIDR_BLOCK) }
    it { should allow_in(protocol: ALB_SECURITY_GROUP_PROTOCAL) }
    it { should_not allow_in(port:ALB_SECURITY_GROUP_PORT, ipv4_range: CIDR_BLOCK) }
  end
end

control "security groups" do                        
  impact 0.7                                
  title "Test for atleast one security group should exist"             
  desc "An optional description..."
  describe aws_security_groups do
  it { should exist }
  end
end

control "secutity groups" do                        
  impact 0.7                                
  title "Test for security group count check"             
  desc "An optional description..."
  describe aws_security_groups do
    its('entries.count') { should be > 1 }
    its('entries.count') { should_not be < 1 }
  end
end

control "Examine this security group is in all VPC's" do                        
  impact 0.7                                
  title "test to check one default security group in all VPC's"             
  desc "An optional description..."
  describe aws_security_groups.where( group_name: INSTANCE_SECURITY_GROUP_NAME) do
    it { should exist }
  end
end

control "Ec2_instance " do                       
  impact 0.7                                
  title "Validate Ec2_instance"             
  desc "An optional description..."
  describe aws_ec2_instance(EC2_INSTANCE_ID) do
    it { should exist }
    it { should be_running }
    its ('image_id') { should eq EC2_INSTANCE_AMIID }
    its ('instance_type') {should eq EC2_INSTANCE_INSTANCE_TYPE}
    its ('availability_zone') { should eq EC2_INSTANCE_AVAILABILITY_ZONE }
    its ('subnet_id') {should eq SUBNET1 }
  end
end

control "Ec2_instance_tags" do                       
  impact 0.7                                
  title "Validate Ec2_instance tags"             
  desc "An optional description..."
  describe aws_ec2_instance(EC2_INSTANCE_ID) do
    it { should exist }
    it { should be_running }
    its('tags') { should include(key: 'BILLINGCODE', value: 'TPX01413-01-01-01-G688') }
    its('tags') { should include(key: 'BILLINGCONTACT', value: 'rdahlman@deloitte.com') }
    its('tags') { should include(key: 'CLIENT', value: 'DevOps Pipeline') }
    its('tags') { should include(key: 'COUNTRY', value: 'US') }
    its('tags') { should include(key: 'CSCLASS', value: 'Confidential') }
    its('tags') { should include(key: 'CSQUAL', value: 'Intellectual Property') }
    its('tags') { should include(key: 'CSTYPE', value: 'External') }
    its('tags') { should include(key: 'DCR', value: 'AWS-WEBFALB0002-0.0.1') }
    its('tags') { should include(key: 'ENVIRONMENT', value: 'NPD') }
    its('tags') { should include(key: 'FUNCTION', value: 'ITS') }
    its('tags') { should include(key: 'GROUPCONTACT', value: 'rdahlman@deloitte.com') }
    its('tags') { should include(key: 'MEMBERFIRM', value: 'US') }
    its('tags') { should include(key: 'Name', value: 'USAWSNPRD00017') }
    its('tags') { should include(key: 'PRIMARYCONTACT', value: 'IAMUSER-868978391936') }
    its('tags') { should include(key: 'SECONDARYCONTACT', value: 'rdahlman@deloitte.com') }
    its('tags') { should include(key: 'cpm backup', value: 'daily_backups_868978391936') }
  end
end
control "Ec2_instance_security_group" do                       
  impact 0.7                                
  title "test for ec2 instance security group"             
  desc "An optional description..."
  describe aws_ec2_instance(EC2_INSTANCE_ID) do
    its('security_group_ids') { should include INSTANCE_SECURITY_GROUP_ID }
  end
end

control "All subnets within a vpc" do                       
  impact 0.7                                
  title "test for all subnets within a VPC"             
  desc "An optional description..."
  describe aws_subnets.where(VPC_ID) do
    its('subnet_ids') { should include SUBNET1 }
    its('subnet_ids') { should include SUBNET2 }
    its('entries.count') {should be > 1}
  end
end

control "Application_Load_balancer" do                        
  impact 0.7                                
  title "test for application load balancer"             
  desc "An optional description..."
  describe aws_alb(load_balancer_arn: ALB_ARN) do
    it { should exist }
    its ('dns_name') {should eq DNS_NAME}
    its ('vpc_id') {should eq VPC_ID }
    its ('name') {should eq 'SDE-AWS-ALB'}
  end
end

control "Application_Load_balancer_security groups" do                        
  impact 0.7                                
  title "test for application load balancer security groups"             
  desc "An optional description..."
  describe aws_alb(load_balancer_arn: ALB_ARN) do
    its ('security_groups') {should include ALB_SECURITY_GROUP_ID}
    its ('entries.count') {should be > 1}
  end
end

control "Application_Load_balancer_subnets" do                        
  impact 0.7                                
  title "test for application load balancer subnets"             
  desc "An optional description..."
  describe aws_alb(ALB_ARN) do
    its('subnet_ids') { should include SUBNET1 }
    its('subnet_ids') { should include SUBNET2 }
    its('entries.count') {should be > 1}
  end
end

control "Application_Load_balancer_zones" do                        
  impact 0.7                                
  title "test for application load balancer zones "             
  desc "An optional description..."
  describe aws_alb('arn::alb') do
    its('zone_names.count')  { should be = 1 }
    its('zone_names')        { should include 'us-east-1' }
  end
end





















