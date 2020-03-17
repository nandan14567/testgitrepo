data "azurerm_virtual_network" "del_vnet" {
  name                = "${var.vnet_name}"
  resource_group_name = "${var.vnet_resource_group}"
}

data "azurerm_subnet" "del_subnet" {

  name                 = "${data.azurerm_virtual_network.del_vnet.subnets[0]}"
  resource_group_name  = "${data.azurerm_virtual_network.del_vnet.resource_group_name}"
  virtual_network_name = "${data.azurerm_virtual_network.del_vnet.name}"

}

resource "azurerm_lb" "del_lb" {
  name                = "${var.prefix}-lb"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"
  sku                 = "Standard"
  tags                = "${var.res_tags}"
  frontend_ip_configuration {

    name      = "${var.frontend_name}"
    subnet_id = "${data.azurerm_subnet.del_subnet.id}"
  }

}

resource "azurerm_lb_backend_address_pool" "del_bend_addr_pool" {
  resource_group_name = "${var.resource_group}"
  loadbalancer_id     = "${azurerm_lb.del_lb.id}"
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "del_lb_probe" {
  count               = "${length(var.lb_port)}"
  resource_group_name = "${var.resource_group}"
  loadbalancer_id     = "${azurerm_lb.del_lb.id}"
  name                = "${element(keys(var.lb_port), count.index)}"
  protocol            = "${element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 1)}"
  port                = "${element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 2)}"
  interval_in_seconds = "${var.lb_probe_interval}"
  number_of_probes    = "${var.lb_probe_unhealthy_threshold}"
}

resource "azurerm_lb_rule" "del_lb_rule" {
  count                          = "${length(var.lb_port)}"
  resource_group_name            = "${var.resource_group}"
  loadbalancer_id                = "${azurerm_lb.del_lb.id}"
  name                           = "${element(keys(var.lb_port), count.index)}"
  protocol                       = "${element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 1)}"
  frontend_port                  = "${element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 0)}"
  backend_port                   = "${element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 2)}"
  frontend_ip_configuration_name = "${var.frontend_name}"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.del_bend_addr_pool.id}"
  idle_timeout_in_minutes        = 15
  probe_id                       = "${element(azurerm_lb_probe.del_lb_probe.*.id, count.index)}"
  depends_on                     = ["azurerm_lb_probe.del_lb_probe"]
}

#----------------------------------------------------------------Generate Server names---------------------------------------
data "external" "servernaming" {
  program = ["sh", "${path.module}/Get_servers.sh"]
  query = {
    numberServers = "${var.vm_count}"
    environment   = "${var.environment_sn}"
    system        = "${var.system_sn}"
    componentKey  = "${var.componentKey_sn}"
  }
}
output "servernames" {
  value = jsondecode(base64decode(data.external.servernaming.result["base64_encoded"])).servers
}

#-------------------------------------------------------Generate Token Here----------------------------------
resource "null_resource" "test-api1" {
  #count      = "${var.vm_count}"
  triggers = {
    values = jsondecode(base64decode(data.external.servernaming.result["base64_encoded"])).servers[0]
  }
  provisioner "local-exec" {
   //get token using single payload
      command="./Generate_token.ps1 -resource ${var.resource} -clientid ${var.client_id} -clientsecret ${var.client_secret}"
      interpreter = ["PowerShell", "-Command"]
   }
}

#--------------------------------------------------------local file and null resource here-----------------------------------
 resource "local_file" "terraform_tf" {
   count="${var.vm_count}"
   content = <<EOF
     {
     "AccountID":  "${var.subscription_id}",
     "ResourceLocation":  "${var.resource_group}",
     "Domain":  "${var.Domain}",
     "ResourceIdentifier":  "${azurerm_virtual_machine.del_virtual_machine[count.index].name}",
     "Environment":  "${var.Environment_puppet}",
     "Provider":  "${var.Provider_name}",
     "OperatingSystem":  "${var.OperatingSystem}"
  }
     EOF
 filename = "${path.root}/temppayload${count.index}.json"

 }

# #-----------------------------------------Virtual machine----------------------------------------------------------------------------------
 resource "azurerm_virtual_machine" "del_virtual_machine" {
   name                  = "${jsondecode(base64decode(data.external.servernaming.result["base64_encoded"])).servers[count.index]}"
   location              = "${var.location}"
   resource_group_name   = "${var.resource_group}"
   availability_set_id   = "${azurerm_availability_set.del_availability_set.id}"
   network_interface_ids = ["${element(azurerm_network_interface.del_network_interface.*.id, count.index)}"]
   vm_size               = "Standard_D1_v2"
   count                 = "${var.vm_count}"
  
   # Uncomment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true

   # Uncomment this line to delete the data disks automatically when deleting the VM
   delete_data_disks_on_termination = true

 storage_image_reference {
     publisher = "MicrosoftWindowsServer"
     offer     = "WindowsServer"
     sku       = "${var.server_version}-Datacenter"
     version   = "latest"
   }

   storage_os_disk {
     name              = "${jsondecode(base64decode(data.external.servernaming.result["base64_encoded"])).servers[count.index]}-disk"
     caching           = "ReadWrite"
     create_option     = "FromImage"
     managed_disk_type = "Standard_LRS"
     os_type           = "Windows"

  }

   # storage_image_reference {
   #   publisher = "MicrosoftWindowsDesktop"
   #   offer     = "Windows-10"
   #   sku       = "rs4-pro"
   #   version   = "latest"
   # }
 

   os_profile {
     computer_name  = "${jsondecode(base64decode(data.external.servernaming.result["base64_encoded"])).servers[count.index]}"
     admin_username = "${var.admin_user}"
     admin_password = "${var.admin_password}"
   }

   tags = "${var.res_tags}"

   os_profile_windows_config {
     provision_vm_agent = true
   }
     //this is to call puppet installation API
   provisioner "local-exec" {
   command="curl --header 'Content-Type:application/json' --header @output_token_sn.txt  --request POST --data @temppayload${count.index}.json  https://onecloudapi.deloitte.com/cloudscript/20190215/api/provision"
   }
 }

 resource "azurerm_network_interface" "del_network_interface" {
   count               = "${var.vm_count}"
   name                = "${jsondecode(base64decode(data.external.servernaming.result["base64_encoded"])).servers[count.index]}-nic"
   location            = "${var.location}"
   resource_group_name = "${var.resource_group}"
   ip_configuration {
     name                                    = "testconfiguration"
     subnet_id                               = "${data.azurerm_subnet.del_subnet.id}"
     private_ip_address_allocation           = "Dynamic"
     # load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.del_bend_addr_pool.id}"]
   }
   tags                = "${var.res_tags}"
 }

 resource "azurerm_network_interface_backend_address_pool_association" "del_association_to_lb" {
 count = "${var.vm_count}"
 network_interface_id = "${element(azurerm_network_interface.del_network_interface.*.id, count.index)}"
 ip_configuration_name = "testconfiguration"
 backend_address_pool_id = "${azurerm_lb_backend_address_pool.del_bend_addr_pool.id}"
 }

 resource "azurerm_availability_set" "del_availability_set" {
   name                         = "${var.prefix}-avset"
   location                     = "${var.location}"
   resource_group_name          = "${var.resource_group}"
   platform_fault_domain_count  = "${var.vm_count}"
   platform_update_domain_count = "${var.vm_count}"
   managed                      = true
 }


# #------------------------------------------------------------------------------------------

# # resource "azurerm_lb_nat_rule" "del_lb_nat_rule" {
# #   count                          = "${length(var.remote_port)}"
# #   resource_group_name            = "${var.resource_group}"
# #   loadbalancer_id                = "${azurerm_lb.del_lb.id}"
# #   name                           = "VM-${count.index}"
# #   protocol                       = "tcp"
# #   frontend_port                  = "5000${count.index + 1}"
# #   backend_port                   = "${element(var.remote_port["${element(keys(var.remote_port), count.index)}"], 1)}"
# #   frontend_ip_configuration_name = "${var.frontend_name}"
# # }

# ##########################################################
# ## Install IIS on VM
# ##########################################################

# # resource "azurerm_virtual_machine_extension" "iis" {
# #   count                = "${var.vm_count}"
# #   name                 = "install-iis"
# #   resource_group_name  = "${var.resource_group_name}"
# #   location             = "${var.location}"
# #   virtual_machine_name = "${element(azurerm_virtual_machine.main.*.name, count.index)}"
# #   publisher            = "Microsoft.Compute"
# #   type                 = "CustomScriptExtension"
# #   type_handler_version = "1.9"

# #   settings = <<SETTINGS
# #     { 
# #       "commandToExecute": "powershell Add-WindowsFeature Web-Asp-Net45;Add-WindowsFeature NET-Framework-45-Core;Add-WindowsFeature Web-Net-Ext45;Add-WindowsFeature Web-ISAPI-Ext;Add-WindowsFeature Web-ISAPI-Filter;Add-WindowsFeature Web-Mgmt-Console;Add-WindowsFeature Web-Scripting-Tools;Add-WindowsFeature Search-Service;Add-WindowsFeature Web-Filtering;Add-WindowsFeature Web-Basic-Auth;Add-WindowsFeature Web-Windows-Auth;Add-WindowsFeature Web-Default-Doc;Add-WindowsFeature Web-Http-Errors;Add-WindowsFeature Web-Static-Content;"
# #     } 
# # SETTINGS
# # }

#--------------------------------------------------------------------------------------------------------------------
# resource "null_resource" "test-api1" {
#   //this is to get token single payload
# provisioner "local-exec" {
#    //get token using single payload
#    #command="set /p=Authorization: <nul >${var.file_outputtoken_sn} | waitfor SomethingThatIsNeverHappening /t 15 2>NUL |curl --header 'Content-Type:application/x-www-form-urlencoded'  --request POST --data @${var.file_tokenpayload}  https://login.microsoftonline.com/36da45f1-dd2c-4d1f-af13-5abe46b99921/oauth2/token | jq -r .access_token >>${var.file_outputtoken_sn}"
#    command="./Generate_token.ps1 -FileName ${var.payload_filename} -clientid ${var.client_id} -clientsecret ${var.client_secret}"
#    interpreter = ["PowerShell", "-Command"]
#    }
# }
