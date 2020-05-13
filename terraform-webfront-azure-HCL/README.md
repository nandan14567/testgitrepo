# **Terraform Azure Webfront Recipe**

Terraform HCL templates to deploy Azure Webfront which consists of an application load balancer and registered Azure VMs behind this application load balancer

**These types of Resources are Used:**

[azurerm_lb](https://www.terraform.io/docs/providers/azurerm/r/lb.html) \
[azurerm_lb_backend_address_pool](https://www.terraform.io/docs/providers/azurerm/r/lb_backend_address_pool.html) \
[azurerm_lb_probe](https://www.terraform.io/docs/providers/azurerm/r/lb_probe.html) \
[azurerm_lb_rule](https://www.terraform.io/docs/providers/azurerm/r/lb_rule.html) \
[azurerm_network_interface](https://www.terraform.io/docs/providers/azurerm/r/network_interface.html) \
[azurerm_virtual_machine](https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html) \
[random_string](https://www.terraform.io/docs/providers/random/r/string.html) \
[random_password](https://www.terraform.io/docs/providers/random/r/password.html) \
[azurerm_availability_set](https://www.terraform.io/docs/providers/azurerm/r/availability_set.html) \
[azurerm_network_interface_backend_address_pool_association](https://www.terraform.io/docs/providers/azurerm/r/network_interface_backend_address_pool_association.html) \
[azurerm_virtual_machine_extension ](https://www.terraform.io/docs/providers/azurerm/r/virtual_machine_extension.html)


**These types of Data Sources are used:**

[azurerm_virtual_network](https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html) \
[azurerm_subnet](https://www.terraform.io/docs/providers/azurerm/r/subnet.html)\
[azurerm_shared_image](https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html)


## **Inputs** 

Note : *Examples are for reference only*

Name | Description | Type | Examples |
---------|---------|---------|---------
 recipe_name | (Required) Unique name for recipe to name resources | String | test-recipe
 subscription_id | (Required) Azure Valid Subscription id | String | 72da45f1-dd2c-4d1f-af13-5abe46
 tenant_id | (Required) Valid Azure tenant id  | String | 36da45f1-dd2c-4d1f-af13-5abe46
 client_id | (Required) Azure valid client id  | String | --
 client_secret | (Required) Azure valid client client secret | String | --
 resource | (Required) Valid Resource to generate token | String | 45hg-715d-45a7-887e-01sgsgsg
 location | (Required)  Azure location  where resources get deployed | String | East US
 resource_group (Existing) | (Required)  Container that holds related resources | String | AZRG-UE-ITS-001
 vnet_name (Existing) | (Required) Virtual Network name having deloitte on-prem connectivity | String | azeusnpnt01-Horizon
 vnet_resource_group (Existing) | (Required) Virtual Network resource group | String | AZRG-ITS-ITS-NPD
 subnet_name (Existing) | (Required) Valid Subnet Name under virtual network having on-prem connectivity | String | vmw-hcs-4596e56a-5776-4b0a
 environment_sn | (Required)  Environment name required to Server Naming API | String | USAZURETEST
 system_sn | (Required)  Application name required to call Server Naming API | String | MyApp
 componentkey_sn | (Required) Component key name reqired to call Server Naming API| String | WEB
 vm_count | (Required) Number of virtual machine to be depolyed | Number | 2
 operating_system | (Required) Valid Operating System Name | String | Windows/Linux
 custom_image/marketplace_image | (Required) Image details required for virtual machines | Map | "custom_image": {"image_name": "deloitte-windows2012","gallery_name": "Goldenimages","image_resource_group": "GoldenImageTestvg"}/"marketplace_image" : {"publisher" : "RedHat","offer": "RHEL","sku":"7-RAW"}
 frontend_name | (Required) Specifies the name of the frontend ip configuration. | String | SubnetIPAddress
 domain | (Required)  Valid domain required for puppet installation | String | us.deloitte.com
 environment_puppet | (Required) Valid Environment required for puppet installation | String | NPD
 ad_security_groups| (Required)  Active Directory security group required to access the created VMs | Map |  {"Administrators": ["US\\SG-US-868978391936-Admin","US\\SG-US-197151468794-Admin"]}/"ad_security_groups": {"sudo_groups": ["%sg-us-868978391936-admin","%sg-us-197151468794-admin"],"access_groups": ["sg-us-868978391936-admin","sg-us-197151468794-admin"]}

-----------------------------------------------------------------
