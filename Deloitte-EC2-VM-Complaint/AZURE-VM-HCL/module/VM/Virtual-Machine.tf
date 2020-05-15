#----------------------------------Random Admin username and password Generation----------------------------------------------
resource "random_string" "username" {
  length  = 10
  special = false
  upper   = false
  number  = false
}
resource "random_password" "password" {
  length  = 18
  special = true
}

#------------------------------------------using existing vnet----------------------------------------------------------------------
data "azurerm_virtual_network" "del_vnet" {
  name                = var.vnet_name
  resource_group_name = var.vnet_resource_group
}

#------------------------------------------using existing subnets-------------------------------------------------------------------
data "azurerm_subnet" "del_subnet" {
  name = var.subnet_name
  resource_group_name  = data.azurerm_virtual_network.del_vnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.del_vnet.name
}

#-------------------------------------------using custom images---------------------------------------------------
data "azurerm_shared_image" "existing" {
  count               = var.custom_image["image_name"] != null ? 1 : 0
  name                = lookup(var.custom_image, "image_name", null)
  gallery_name        = lookup(var.custom_image, "gallery_name", null)
  resource_group_name = lookup(var.custom_image, "image_resource_group", null)
}


#-------------------------------------------------------Generate Token Here-----------------------------------------------------
data "restapi" "tokenapi" {
  uri          = "https://login.microsoftonline.com/36da45f1-dd2c-4d1f-af13-5abe46b99921/oauth2/token"
  method       = "POST"
  request_body = <<-EOF
  {
     "grant_type":"client_credentials",
     "resource":"${var.resource}",
     "client_id":"${var.client_id}",
     "client_secret":"${var.client_secret}"
  }
  EOF
  request_headers = {
    Content-Type = "application/x-www-form-urlencoded"
  }
}

#----------------------------------------------------------------Generate Server names---------------------------------------
data "restapi" "servernaming" {
  uri          = "https://onecloudapi.deloitte.com/servernaming/20190215/ServerNaming"
  method       = "POST"
  request_body = jsonencode(var.servernaming_payload)
  request_headers = {
    Content-Type = "application/json"
  }
}

#------------------------------------------ Network Interface Card--------------------------------------------


resource "azurerm_network_interface" "del_network_interface" {
  count               = var.vm_count
  name                = "${jsondecode(data.restapi.servernaming.body).components[0].servers[count.index]}-nic"
  location            = var.location
  resource_group_name = var.resource_group
  ip_configuration {
    name                          = "IP-Configuration"
    subnet_id                     = data.azurerm_subnet.del_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    "DCR" : "AZ-WEBFVM0004-0.0.1"
  }
}

#-----------------------------------------------Virtual machine Linux----------------------------------------------------------------------------------

resource "azurerm_virtual_machine" "del_linux_virtual_machine" {
  count                 = var.operating_system == "linux" ? var.vm_count : 0
  name                  = jsondecode(data.restapi.servernaming.body).components[0].servers[count.index]
  location              = var.location
  resource_group_name   = var.resource_group
  network_interface_ids = ["${element(azurerm_network_interface.del_network_interface.*.id, count.index)}"]
  vm_size               = "Standard_D1_v2"

  # delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  # using azure marketplace image and custom image based on user input
  storage_image_reference {
    publisher = lookup(var.marketplace_image, "publisher", null)
    offer     = lookup(var.marketplace_image, "offer", null)
    sku       = lookup(var.marketplace_image, "sku", null)
    version   = "latest"
    id        = var.custom_image["image_name"] != null ? data.azurerm_shared_image.existing[0].id : null
  }

  storage_os_disk {
    name              = "${jsondecode(data.restapi.servernaming.body).components[0].servers[count.index]}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    os_type           = "Linux"
  }

  os_profile {
    computer_name  = jsondecode(data.restapi.servernaming.body).components[0].servers[count.index]
    admin_username = random_string.username.result
    admin_password = random_password.password.result
    custom_data    = base64encode(data.null_data_source.linux-values.outputs["data"])
  }

  tags = {
    "DCR" : "AZ-WEBFVM0004-0.0.1"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

#------------------------------------------------Custom data Linux-----------------------------------------------------
data "null_data_source" "linux-values" {
  inputs = {
    data = <<-EOF
     #!/bin/bash
     mkdir -p /etc/puppetlabs/facter/facts.d
     echo ' {"elevated_groups": {"sudo_groups":${jsonencode(var.ad_sg_names)}}}' >/etc/puppetlabs/facter/facts.d/elevated_groups.json
     EOF
  }
}


# #-----------------------------------------Virtual machine windows--------------------------------------------------------------------
resource "azurerm_virtual_machine" "del_virtual_machine" {
  count                 = var.operating_system == "windows" ? var.vm_count : 0
  name                  = jsondecode(data.restapi.servernaming.body).components[0].servers[count.index]
  location              = var.location
  resource_group_name   = var.resource_group
  network_interface_ids = ["${element(azurerm_network_interface.del_network_interface.*.id, count.index)}"]
  vm_size               = "Standard_D1_v2"


  # delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  #using azure marketplace image and custom image based on user input
  storage_image_reference {
    publisher = lookup(var.marketplace_image, "publisher", null)
    offer     = lookup(var.marketplace_image, "offer", null)
    sku       = lookup(var.marketplace_image, "sku", null)
    version   = "latest"
    id        = var.custom_image["image_name"] != null ? data.azurerm_shared_image.existing[0].id : null
  }

  storage_os_disk {
    name              = "${jsondecode(data.restapi.servernaming.body).components[0].servers[count.index]}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    os_type           = "Windows"
  }

  os_profile {
    computer_name  = jsondecode(data.restapi.servernaming.body).components[0].servers[count.index]
    admin_username = random_string.username.result
    admin_password = random_password.password.result
  }

  tags = {
    "DCR" : "AZ-WEBFVM0004-0.0.1"
  }

  os_profile_windows_config {
    provision_vm_agent = true
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
   ${jsonencode(var.ad_sg_names)}
 }
}'| out-file -encoding ASCII C:\\ProgramData\\PuppetLabs\\facter\\facts.d\\elevated_groups.json
     EOF
  }
}

locals {
  command_windows = {
    script = "${compact(concat(split("\n", data.null_data_source.values.outputs["data"])))}"
  }
}


resource "azurerm_virtual_machine_extension" "windows" {
  count                      = var.operating_system == "windows" ? var.vm_count : 0
  name                       = "${jsondecode(data.restapi.servernaming.body).components[0].servers[count.index]}run-commands"
  virtual_machine_id         = azurerm_virtual_machine.del_virtual_machine[count.index].id
  publisher                  = "Microsoft.CPlat.Core"
  type                       = "RunCommandWindows"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = true
  settings                   = jsonencode(local.command_windows)
}

#---------------------------------------puppet api call for windows--------------------------------------------
data "restapi" "puppet_windows" {
  depends_on   = [azurerm_virtual_machine.del_virtual_machine, azurerm_virtual_machine_extension.windows]
  count        = var.operating_system == "windows" ? var.vm_count : 0
  uri          = "https://onecloudapi.deloitte.com/cloudscript/20190215/api/provision"
  method       = "POST"
  request_body = <<-EOF
  {
        "AccountID":  "${var.subscription_id}",
        "ResourceLocation":  "${var.resource_group}",
        "Domain":  "${var.domain}",
        "ResourceIdentifier":"${jsondecode(data.restapi.servernaming.body).components[0].servers[count.index]}",
        "Environment": "${var.environment_puppet}",
        "Provider":  "azure",
        "OperatingSystem":  "${var.operating_system}"
  }
  EOF
  request_headers = {
    Authorization = jsondecode(data.restapi.tokenapi.body).access_token
    Content-Type  = "application/json"
  }
}

#---------------------------------------puppet api call for linux--------------------------------------------
data "restapi" "puppet_linux" {
  depends_on   = [azurerm_virtual_machine.del_linux_virtual_machine]
  count        = var.operating_system == "linux" ? var.vm_count : 0
  uri          = "https://onecloudapi.deloitte.com/cloudscript/20190215/api/provision"
  method       = "POST"
  request_body = <<-EOF
  {
        "AccountID":  "${var.subscription_id}",
        "ResourceLocation":  "${var.resource_group}",
        "Domain":  "${var.domain}",
        "ResourceIdentifier":"${jsondecode(data.restapi.servernaming.body).components[0].servers[count.index]}",
        "Environment": "${var.environment_puppet}",
        "Provider":  "azure",
        "OperatingSystem":  "${var.operating_system}"
  }
  EOF
  request_headers = {
    Authorization = jsondecode(data.restapi.tokenapi.body).access_token
    Content-Type  = "application/json"
  }
}

