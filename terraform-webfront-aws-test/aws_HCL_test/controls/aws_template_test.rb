# copyright: 2018, The Authors
require 'rubygems'
require 'json'
title "Aws template validation"
testData = inspec.profile.file('AWSILB-Recipe.tfstate')
params = JSON.parse(testData)
awsInstanceModules=[]
params['resources'].each {|n|
if n['type'] == "aws_instance"
  awsInstanceModules.push(n)
end
}
awsInstanceModules.each{|n|
  instances = n['instances']
  instances.each {|n|
    control "Ec2_instance " do                       
      impact 0.7                                
      title "Validate Ec2_instance"             
      desc "An optional description..."
      describe aws_ec2_instance(n['attributes']['id']) do
        it { should exist }
        it { should be_running }
        its ('image_id') { should eq n['attributes']['id']['ami'] }
        its ('instance_type') {should eq n['attributes']['instance_type']}
        its ('private_ip_address') { should eq n['attributes']['private_ip'] }
      end
    end
    control "Ec2_instance_security_group" do                       
      impact 0.7                                
      title "test for ec2 instance security group"             
      desc "An optional description..."
      describe aws_ec2_instance(n['attributes']['id']) do
        its('security_group_ids') { should include n['attributes']['vpc_security_group_ids'][0] }
      end
    end  
    tags = n['attributes']['tags'] 
    control "Ec2_instance_tags" do                       
      impact 0.7                                
      title "test for ec2 instance tags"             
      desc "An optional description..."
      describe aws_ec2_instance(n['attributes']['id']) do
        its ('tags') { should include tags.each {|key,value| 
        } 
    }
      end
    end  
    }
  }
    albInstanceModules=[]
    params['resources'].each {|n|
    if n['type'] == "aws_lb"
      albInstanceModules.push(n)
    end
    }
    albInstanceModules.each{|n|
      instances = n['instances']
      instances.each {|n|
        control "Application_Load_balancer" do                        
          impact 0.7                                
          title "test for application load balancer"             
          desc "An optional description..."
          describe aws_alb(n['attributes']['arn']) do
            it { should exist }
            its ('dns_name') {should eq n['attributes']['dns_name']}
            its ('vpc_id') {should eq n['attributes']['vpc_id'] }
            its ('load_balancer_name') {should eq n['attributes']['name']}
            its ('canonical_hosted_zone_id') {should eq n['attributes']['zone_id'] }
            its ('type') { should eq n['attributes']['load_balancer_type'] }
          end
        end
    
        control "Application_Load_balancer_security groups" do                        
          impact 0.7                                
          title "test for application load balancer security groups"             
          desc "An optional description..."
          describe aws_alb(load_balancer_arn: n['attributes']['arn']) do
            its ('security_groups') {should include n['attributes']['security_groups']}
          end
        end
    
        control "Application_Load_balancer_subnets" do                        
          impact 0.7                                
          title "test for application load balancer subnets"             
          desc "An optional description..."
          describe aws_alb(n['attributes']['arn']) do
            its('subnets') { should include n['attributes']['ids'][0] }
            its('subnets') { should include n['attributes']['ids'][1] }
            its('subnets.count') {should be > 1}
          end
        end

    
        control "Application_Load_balancer_zones" do                        
          impact 0.7                                
          title "test for application load balancer zones "             
          desc "An optional description..."
          describe aws_alb(n['attributes']['arn']) do
            its('zone_names.count')  { should_not be < 1 }
          end
        end  
        }
      }

ec2SecurityModules=[];
params['resources'].each {|n|
if n['module'] == "module.application_load_balancer.module.instance_security_group" && n['name'] == "del_security_group"
  ec2SecurityModules.push(n)
end 
}
ec2SecurityModules.each{|n|
  instances = n['instances']
  instances.each {|n|
    control "Ec2_security group name validation" do                       
      impact 0.7                                
      title "Ec2_security group validation with in one VPC"             
      desc "An optional description..."
      describe aws_security_group(group_name: n['attributes']['name'], group_id: n['attributes']['id'], vpc_id: n['attributes']['vpc_id']) do
        it { should exist }
        its ('description') {should eq n['attributes']['description']}
      end
    end
 
  }
}

ec2SecurityModulesRules=[]
params['resources'].each {|n|
if n['module'] == "module.application_load_balancer.module.instance_security_group" && n['name'] == "tcp"
  ec2SecurityModulesRules.push(n)
end 
}
ec2SecurityModulesRules.each{|n|
  instances = n['instances']
  instances.each {|n|
    control "security group inbound/outbound control" do                        
      impact 0.7                                
      title "inbound/outbound rules validation "             
      desc "An optional description..."
      describe aws_security_group(group_id: n['attributes']['security_group_id']) do
        it { should allow_in(port: n['attributes']['from_port'], ipv4_range: n['attributes']['cidr_blocks'][0]) }
        it { should allow_in(protocol: n['attributes']['protocol']) }
        its ('description') {should eq n['attributes']['description']}
      end
    end
    }
  }

  albSecurityModule=[]
  params['resources'].each {|n|
  if n['module'] == "module.application_load_balancer.module.alb_security_group" && n['name'] == "del_security_group"
    albSecurityModule.push(n)
  end 
  }
  albSecurityModule.each{|n|
    instances = n['instances']
    instances.each {|n|
      control "alb_security group name validation" do                       
        impact 0.7                                
        title "alb_security group validation with in one VPC"             
        desc "An optional description..."
        describe aws_security_group(group_name: n['attributes']['name'], group_id: n['attributes']['id'], vpc_id: n['attributes']['vpc_id']) do
          it { should exist }
          its ('description') {should eq n['attributes']['description']}
        end
      end 
      }
    }
  albSecurityModuleRules=[]
  params['resources'].each {|n|
  if n['module'] == "module.application_load_balancer.module.alb_security_group" && n['name'] == "tcp"
    albSecurityModuleRules.push(n)
  end 
  }
  albSecurityModuleRules.each{|n|
    instances = n['instances']
    instances.each {|n|
      control "alb_security group inbound/outbound control" do                        
        impact 0.7                                
        title "inbound/outbound rules validation "             
        desc "An optional description..."
        describe aws_security_group(group_id: n['attributes']['security_group_id']) do
          it { should allow_in(port: n['attributes'][''], ipv4_range: ALB_SECURITY_GROUP_CIDR_BLOCK) }
          it { should allow_in(protocol: ALB_SECURITY_GROUP_PROTOCAL) }
          it { should_not allow_in(port:ALB_SECURITY_GROUP_PORT, ipv4_range: CIDR_BLOCK) }
        end
      end
      }
    }
  
    

      
      
        
        