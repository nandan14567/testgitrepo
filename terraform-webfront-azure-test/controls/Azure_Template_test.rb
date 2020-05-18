# copyright: 2018, The Authors
require 'rubygems'
require 'json'
title "Azure template validation"
testData = inspec.profile.file('AZILB-Recipe.tfstate')
azureparams = JSON.parse(testData)
azureInstanceModules=[]
azureparams['resources'].each {|n| puts n
puts n['type']
if n['type'] == "azurerm_virtual_network"
  azureInstanceModules.push(n)
end
}
puts azureInstanceModules
azureInstanceModules.each{|n| puts n
  puts n['instances']
  instances = n['instances']
  instances.each {|n| puts n
    control "azurerm_virtual_network_validation " do                       
        impact 0.7                                
        title "Validate azurerm_virtual_network"             
        desc "An optional description..."
        describe azurerm_virtual_network(resource_group: n['attributes']['resource_group_name'], name: n['attributes']['name']) do
            it                                { should exist }
            its ('id') {should eq n['attributes']['id']}
            its ('address_space') {should eq n['attributes']['address_space']}
            its ('location') { should eq n['attributes']['location'] }
            its ('vnet_peerings') { should eq n['attributes']['vnet_peerings'] }
          end
        end

    control "azurerm_virtual_network_Dns_server_validation " do                       
        impact 0.7                                
        title "Validate azurerm_virtual_network dns_servers"             
        desc "An optional description..."    
        describe azurerm_virtual_network(resource_group: n['attributes']['resource_group_name'], name: n['attributes']['name']) do
            it                                { should exist }
            its ('dns_servers') { should eq [n['attributes']['dns_servers'][0], n['attributes']['dns_servers'][1], n['attributes']['dns_servers'][2]] }
          end
        end

    control "azurerm_virtual_network_subnets" do                       
        impact 0.7                                
        title "Validate azurerm_virtual_network subnets"             
        desc "An optional description..."    
        describe azurerm_virtual_network(resource_group: n['attributes']['resource_group_name'], name: n['attributes']['name']) do
            it                                { should exist }
            its ('subnets') { should eq [n['attributes']['subnets'][0], n['attributes']['subnets'][1], n['attributes']['subnets'][2]] }
          end
        end
  }
}
azurermNetworkInterfaceModule=[]
azureparams['resources'].each {|n| puts n
puts n['type']
if n['type'] == "azurerm_network_interface"
    azurermNetworkInterfaceModule.push(n)
end
}
puts azurermNetworkInterfaceModule
azurermNetworkInterfaceModule.each{|n| puts n
  puts n['instances']
  instances = n['instances']
  instances.each {|n| puts n

   control "azurerm_Network_Interface" do                       
        impact 0.7                                
        title "Validate azurerm_Network_Interface"             
        desc "An optional description..."    
        describe azurerm_network_interface(resource_group: n['attributes']['resource_group_name'], name: n['attributes']['name'] ) do
            it { should exist }
            its ('id') {should eq n['attributes']['id']}
            its ('location') { should eq n['attributes']['location'] }
          end
        end
        
  tags = n['attributes']['tags'] 
  control "azurerm_Network_Interface_tags" do                       
    impact 0.7                                
    title "Validate azurerm_Network_Interface tags"             
    desc "An optional description..."    
    describe azurerm_network_interface(resource_group: n['attributes']['resource_group_name'], name: n['attributes']['name'] ) do
      its ('tags') { should include tags.each {|key,value| 
            } 
        }
      end
    end     
  }
}
azurermVirtualMachineModule=[]
azureparams['resources'].each {|n| puts n
puts n['type']
if n['type'] == "azurerm_virtual_machine"
  azurermVirtualMachineModule.push(n)
end
}
puts azurermVirtualMachineModule
azurermVirtualMachineModule.each{|n| puts n
  puts n['instances']
  instances = n['instances']
  instances.each {|n| puts n
    control "azurerm_Virtual_Machine" do                       
      impact 0.7                                
      title "Validate azurerm_Virtual_Machine"             
      desc "An optional description..."    
      describe azurerm_virtual_machine(resource_group: n['attributes']['resource_group_name'], name: n['attributes']['name'] ) do
          it { should exist }
          its ('id') {should eq n['attributes']['id']}
          its ('location') { should eq n['attributes']['location'] }
        end
      end

tags = n['attributes']['tags'] 
  control "azurerm_Virtual_Machine_tags" do                       
    impact 0.7                                
    title "Validate azurerm_Virtual_Machine tags"             
    desc "An optional description..."    
    describe azurerm_virtual_machine(resource_group: n['attributes']['resource_group_name'], name: n['attributes']['name'] ) do
        its ('tags') { should include tags.each {|key,value| 
            } 
        }
      end
    end    
  }
}
azurermLoadBalancer=[]
azureparams['resources'].each {|n| puts n
puts n['type']
if n['type'] == "azurerm_lb"
  azurermLoadBalancer.push(n)
end
}
azurermLoadBalancer.each{|n| puts n
  puts n['instances']
  instances = n['instances']
  instances.each {|n| puts n
    control "azurerm_LoadBalancer" do                       
      impact 0.7                                
      title "Validate azurerm_LoadBalancer"             
      desc "An optional description..."    
      describe azurerm_load_balancer(resource_group: n['attributes']['resource_group_name'], loadbalancer_name: n['attributes']['name']) do
        it { should exist }
        its ('id') {should eq n['attributes']['id']}
        its ('location') { should eq n['attributes']['location'] }
        end
      end   

  }
}
