#------------------------------------------using existing vnet--------------------------------------------------------------
data "azurerm_virtual_network" "del_vnet" {
  name                = var.vnet_name
  resource_group_name = var.vnet_resource_group
}

#------------------------------------------using existing subnets-------------------------------------------------------------------
data "azurerm_subnet" "del_subnet" {
  name = var.subnet_name
  #name                 = data.azurerm_virtual_network.del_vnet.subnets[0]
  resource_group_name  = data.azurerm_virtual_network.del_vnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.del_vnet.name

}

#------------------------------------------creating load balancer----------------------------------------------------------
resource "azurerm_lb" "del_lb" {
  name                = "${var.prefix}-lb"
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "Standard"
  frontend_ip_configuration {

    name      = var.frontend_name
    subnet_id = data.azurerm_subnet.del_subnet.id
  }
  tags = {
    "DCR" : "AZ-WEBFALB0001-0.0.2"
  }
}

resource "azurerm_lb_backend_address_pool" "del_bend_addr_pool" {
  resource_group_name = var.resource_group
  loadbalancer_id     = azurerm_lb.del_lb.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "del_lb_probe" {
  count               = length(var.lb_port)
  resource_group_name = var.resource_group
  loadbalancer_id     = azurerm_lb.del_lb.id
  name                = element(keys(var.lb_port), count.index)
  protocol            = element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 1)
  port                = element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 2)
  interval_in_seconds = var.lb_probe_interval
  number_of_probes    = var.lb_probe_unhealthy_threshold

}

resource "azurerm_lb_rule" "del_lb_rule" {
  count                          = length(var.lb_port)
  resource_group_name            = var.resource_group
  loadbalancer_id                = azurerm_lb.del_lb.id
  name                           = element(keys(var.lb_port), count.index)
  protocol                       = element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 1)
  frontend_port                  = element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 0)
  backend_port                   = element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 2)
  frontend_ip_configuration_name = var.frontend_name
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.del_bend_addr_pool.id
  idle_timeout_in_minutes        = 15
  probe_id                       = element(azurerm_lb_probe.del_lb_probe.*.id, count.index)
  depends_on                     = [azurerm_lb_probe.del_lb_probe]
}

#----------------------------------------------------------------Generate Server names---------------------------------------
data "external" "servernaming" {
  program = ["Powershell.exe", "${path.module}/Get_servers.ps1"]
  query = {
    numberServers = var.vm_count
    environment   = var.environment_sn
    system        = var.system_sn
    componentKey  = var.componentKey_sn
  }
}
# output "servernames" {
#   value = "${data.external.servernaming.result}"
# }

#-------------------------------------------------------Generate Token Here-----------------------------------------------------
resource "null_resource" "test-api1" {
  #count      = "${var.vm_count}"
  triggers = {
    values = "${data.external.servernaming.result[0]}"
  }
  provisioner "local-exec" {
    //get token using single payload
    command     = "${path.module}/Generate_token.ps1 -resource ${var.resource} -clientid ${var.client_id} -clientsecret ${var.client_secret}"
    interpreter = ["PowerShell", "-Command"]
  }
}

#--------------------------------------------------------local file and null resource here-----------------------------------
resource "local_file" "terraform_tf" {
  count    = var.vm_count
  content  = <<EOF
     {
     "AccountID":  "${var.subscription_id}",
     "ResourceLocation":  "${var.resource_group}",
     "Domain":  "${var.Domain}",
     "ResourceIdentifier":  "${data.external.servernaming.result[count.index]}",
     "Environment":  "${var.Environment_puppet}",
     "Provider":  "${var.Provider_name}",
     "OperatingSystem":  "${var.OperatingSystem}"
  }
     EOF
  filename = "${path.root}/temppayload${count.index}.json"

}
#------------------------------------------pool association, NIC and availability set--------------------------------------------
resource "azurerm_network_interface_backend_address_pool_association" "del_association_to_lb" {
  count                   = var.vm_count
  network_interface_id    = element(azurerm_network_interface.del_network_interface.*.id, count.index)
  ip_configuration_name   = "testconfiguration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.del_bend_addr_pool.id
}

resource "azurerm_network_interface" "del_network_interface" {
  count               = var.vm_count
  name                = "${data.external.servernaming.result[count.index]}-nic"
  location            = var.location
  resource_group_name = var.resource_group
  ip_configuration {
    name                          = "testconfiguration"
    subnet_id                     = data.azurerm_subnet.del_subnet.id
    private_ip_address_allocation = "Dynamic"
    # load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.del_bend_addr_pool.id}"]
  }
  tags = {
    "DCR" : "AZ-WEBFALB0001-0.0.2"
  }
}
resource "azurerm_availability_set" "del_availability_set" {
  name                         = "${var.prefix}-avset"
  location                     = var.location
  resource_group_name          = var.resource_group
  platform_fault_domain_count  = var.vm_count
  platform_update_domain_count = var.vm_count
  managed                      = true
  tags = {
    "DCR" : "AZ-WEBFALB0001-0.0.2"
  }
}
#------------------------------------------------Custom data Linux-----------------------------------------------------
data "null_data_source" "linux-values" {
  inputs = {
    data = <<-EOF
     #!/bin/bash
     mkdir -p /etc/puppetlabs/facter/facts.d
     echo ' {"elevated_groups": {"sudo_groups":${jsonencode(split(",", var.ad_sg_names))}}}' >/etc/puppetlabs/facter/facts.d/elevated_groups.json
     EOF
  }
}

# #-----------------------------------------Virtual machine Linux----------------------------------------------------------------------------------

resource "azurerm_virtual_machine" "del_linux_virtual_machine" {
  count                 = var.OperatingSystem == "linux" ? var.vm_count : 0
  name                  = data.external.servernaming.result[count.index]
  location              = var.location
  resource_group_name   = var.resource_group
  availability_set_id   = azurerm_availability_set.del_availability_set.id
  network_interface_ids = ["${element(azurerm_network_interface.del_network_interface.*.id, count.index)}"]
  vm_size               = "Standard_D1_v2"

  # this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "${var.server_version}-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${data.external.servernaming.result[count.index]}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    os_type           = "Linux"

  }

  os_profile {
    computer_name  = data.external.servernaming.result[count.index]
    admin_username = var.admin_user
    admin_password = var.admin_password
    custom_data=base64encode(data.null_data_source.linux-values.outputs["data"])
  }

  tags = {
    "DCR" : "AZ-WEBFALB0001-0.0.2"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
  //this is to call puppet installation API
  provisioner "local-exec" {
    command = "curl --header 'Content-Type:application/json' --header @output_token_sn.txt  --request POST --data @temppayload${count.index}.json  https://onecloudapi.deloitte.com/cloudscript/20190215/api/provision"
  }
}

#-------------------------------------------Custom data windows-----------------------------------------------------------------------
data "null_data_source" "values" {
  inputs = {
    data = <<EOF
  if( -Not (Test-Path -Path 'C:\\ProgramData\\PuppetLabs\\facter\\facts.d' ) )
  {
    New-Item -ItemType directory -Path 'C:\\ProgramData\\PuppetLabs\\facter\\facts.d'
  }
  Write-Output '{
 "elevated_groups": {
 "Administrators":  
   ${jsonencode(split(",", var.ad_sg_names))}
 }
}' >C:\\ProgramData\\PuppetLabs\\facter\\facts.d\\elevated_groups.json

     EOF
  }
}

locals {
  command_windows = {
    script = "${compact(concat(split("\n", data.null_data_source.values.outputs["data"])))}"
  }
}
# #-----------------------------------------Virtual machine windows--------------------------------------------------------------------
resource "azurerm_virtual_machine" "del_virtual_machine" {
  count                 = var.OperatingSystem == "windows" ? var.vm_count : 0
  name                  = data.external.servernaming.result[count.index]
  location              = var.location
  resource_group_name   = var.resource_group
  availability_set_id   = azurerm_availability_set.del_availability_set.id
  network_interface_ids = ["${element(azurerm_network_interface.del_network_interface.*.id, count.index)}"]
  vm_size               = "Standard_D1_v2"


  # this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "${var.server_version}-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${data.external.servernaming.result[count.index]}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    os_type           = "Windows"

  }

  os_profile {
    computer_name  = data.external.servernaming.result[count.index]
    admin_username = var.admin_user
    admin_password = var.admin_password

  }

  tags = {
    "DCR" : "AZ-WEBFALB0001-0.0.2"
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }
}


resource "azurerm_virtual_machine_extension" "windows" {
  count                = var.OperatingSystem == "windows" ? var.vm_count : 0
  name                 = "${data.external.servernaming.result[count.index]}run-commands"
  virtual_machine_id   = azurerm_virtual_machine.del_virtual_machine[count.index].id
  publisher            = "Microsoft.CPlat.Core"
  type                 = "RunCommandWindows"
  type_handler_version = "1.1"
  auto_upgrade_minor_version = true
  settings             = jsonencode(local.command_windows)
}

#-----------------------------------puppet api call for windows machines-----------------------------------------
resource "null_resource" "call-puppet-windows" {
  count      = var.OperatingSystem == "windows" ? var.vm_count : 0
  depends_on = [azurerm_virtual_machine.del_virtual_machine,azurerm_virtual_machine_extension.windows]
  triggers = {
    values = azurerm_virtual_machine_extension.windows[count.index].id
  }
   //this is to call puppet installation API
  provisioner "local-exec" {
    command = "curl --header 'Content-Type:application/json' --header @output_token_sn.txt  --request POST --data @temppayload${count.index}.json  https://onecloudapi.deloitte.com/cloudscript/20190215/api/provision"
  }
}
 
# ##########################################################
## Install IIS on VM
##########################################################

# resource "azurerm_virtual_machine_extension" "iis" {
#   count                = "${var.vm_count}"
#   name                 = "install-iis"
#   resource_group_name  = "${var.resource_group_name}"
#   location             = "${var.location}"
#   virtual_machine_name = "${element(azurerm_virtual_machine.main.*.name, count.index)}"
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScriptExtension"
#   type_handler_version = "1.9"

#   settings = <<SETTINGS
#     { 
#       "commandToExecute": "powershell Add-WindowsFeature Web-Asp-Net45;Add-WindowsFeature NET-Framework-45-Core;Add-WindowsFeature Web-Net-Ext45;Add-WindowsFeature Web-ISAPI-Ext;Add-WindowsFeature Web-ISAPI-Filter;Add-WindowsFeature Web-Mgmt-Console;Add-WindowsFeature Web-Scripting-Tools;Add-WindowsFeature Search-Service;Add-WindowsFeature Web-Filtering;Add-WindowsFeature Web-Basic-Auth;Add-WindowsFeature Web-Windows-Auth;Add-WindowsFeature Web-Default-Doc;Add-WindowsFeature Web-Http-Errors;Add-WindowsFeature Web-Static-Content;"
#     } 
# SETTINGS
# }

#---------------------------------------------------------------------------------------------------------------------------------------------------

