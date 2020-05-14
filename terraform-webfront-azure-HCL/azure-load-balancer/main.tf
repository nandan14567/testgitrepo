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
  name                 = var.subnet_name
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

#------------------------------------------creating load balancer----------------------------------------------------------
resource "azurerm_lb" "del_lb" {
  name                = "${var.recipe_name}-lb"
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "Standard"
  frontend_ip_configuration {
    name      = var.frontend_name
    subnet_id = data.azurerm_subnet.del_subnet.id
  }
  tags = {
    "DCR" : "AZ-WEBFALB0001-0.0.1"
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

#-------------------------------------------------------Generate Token Here-----------------------------------------------------
data "external" "token" {
  program = ["Powershell.exe", "${path.module}/Generate_token.ps1"]
  query = {
    resource     = var.resource
    clientid     = var.client_id
    clientsecret = var.client_secret
  }
}

#-------------------------------------------------------Generate Server names---------------------------------------
data "external" "servernaming" {
  program = ["Powershell.exe", "${path.module}/Get_servers.ps1"]
  query = {
    numberServers = var.vm_count
    environment   = var.environment_sn
    system        = var.system_sn
    componentKey  = var.componentkey_sn
  }
}

#------------------------------------------null data source to generate puppet payload----------------------------------------
data "null_data_source" "payload_file" {
  count = var.vm_count
  inputs = {
    AccountID          = "${var.subscription_id}"
    ResourceLocation   = "${var.resource_group}"
    Domain             = "${var.domain}"
    ResourceIdentifier = "${data.external.servernaming.result[count.index]}"
    Environment        = "${var.environment_puppet}"
    Provider           = "azure"
    OperatingSystem    = "${var.operating_system}"
  }
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
    "DCR" : "AZ-WEBFALB0001-0.0.1"
  }
}

resource "azurerm_availability_set" "del_availability_set" {
  name                         = "${var.recipe_name}-avset"
  location                     = var.location
  resource_group_name          = var.resource_group
  platform_fault_domain_count  = var.vm_count
  platform_update_domain_count = var.vm_count
  managed                      = true
  tags = {
    "DCR" : "AZ-WEBFALB0001-0.0.1"
  }
}

#------------------------------------------------Custom data Linux-----------------------------------------------------
# data "null_data_source" "linux-values" {
#   inputs = {
#     data = <<-EOF
#      #!/bin/bash
#      mkdir -p /etc/puppetlabs/facter/facts.d
#      echo ' {"elevated_groups": {"sudo_groups":${jsonencode(var.ad_security_groups)}}}' >/etc/puppetlabs/facter/facts.d/elevated_groups.json
#      EOF
#   }
# }

# #-----------------------------------------Virtual machine Linux----------------------------------------------------------------------------------

resource "azurerm_virtual_machine" "del_linux_virtual_machine" {
  count                 = lower(var.operating_system) == "linux" ? var.vm_count : 0
  name                  = data.external.servernaming.result[count.index]
  location              = var.location
  resource_group_name   = var.resource_group
  availability_set_id   = azurerm_availability_set.del_availability_set.id
  network_interface_ids = ["${element(azurerm_network_interface.del_network_interface.*.id, count.index)}"]
  vm_size               = "Standard_D1_v2"

  # to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # to delete the data disks automatically when deleting the VM
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
    name              = "${data.external.servernaming.result[count.index]}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    os_type           = "Linux"
  }
  os_profile {
    computer_name  = data.external.servernaming.result[count.index]
    admin_username = random_string.username.result
    admin_password = random_password.password.result
    #custom_data    = base64encode(data.null_data_source.linux-values.outputs["data"])
  }

  tags = {
    "DCR" : "AZ-WEBFALB0001-0.0.1"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  connection {
    type     = "ssh"
    host     = azurerm_network_interface.del_network_interface[count.index].private_ip_address
    user     = random_string.username.result
    password = random_password.password.result
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${random_password.password.result}' | sudo -S mkdir -p /etc/puppetlabs/facter/facts.d",
      "sudo touch /etc/puppetlabs/facter/facts.d/elevated_groups.json",
      "sudo chmod 777 /etc/puppetlabs/facter/facts.d/elevated_groups.json",
      "echo '{\"elevated_groups\":${jsonencode(var.ad_security_groups)}}' >/etc/puppetlabs/facter/facts.d/elevated_groups.json",
      # "exit 0",
    ]
  }
  //this is to call puppet installation API
  provisioner "local-exec" {
    command     = "Invoke-WebRequest \"https://onecloudapi.deloitte.com/cloudscript/20190215/api/provision\" -Headers @{\"Authorization\" = \"Bearer ${data.external.token.result[0]}\"} -ContentType \"application/json\" -Body '${jsonencode(data.null_data_source.payload_file[count.index].outputs)}' -Method POST"
    interpreter = ["PowerShell", "-Command"]
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
 "elevated_groups": ${jsonencode(var.ad_security_groups)}
}'| out-file -encoding ASCII C:\\ProgramData\\PuppetLabs\\facter\\facts.d\\elevated_groups.json
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
  count                 = lower(var.operating_system) == "windows" ? var.vm_count : 0
  name                  = data.external.servernaming.result[count.index]
  location              = var.location
  resource_group_name   = var.resource_group
  availability_set_id   = azurerm_availability_set.del_availability_set.id
  network_interface_ids = ["${element(azurerm_network_interface.del_network_interface.*.id, count.index)}"]
  vm_size               = "Standard_D1_v2"

  # to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # to delete the data disks automatically when deleting the VM
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
    name              = "${data.external.servernaming.result[count.index]}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    os_type           = "Windows"
  }
  os_profile {
    computer_name  = data.external.servernaming.result[count.index]
    admin_username = random_string.username.result
    admin_password = random_password.password.result
  }
  tags = {
    "DCR" : "AZ-WEBFALB0001-0.0.1"
  }
  os_profile_windows_config {
    provision_vm_agent = true
  }
}

resource "azurerm_virtual_machine_extension" "windows" {
  count                      = lower(var.operating_system) == "windows" ? var.vm_count : 0
  name                       = "${data.external.servernaming.result[count.index]}run-commands"
  virtual_machine_id         = azurerm_virtual_machine.del_virtual_machine[count.index].id
  publisher                  = "Microsoft.CPlat.Core"
  type                       = "RunCommandWindows"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = true
  settings                   = jsonencode(local.command_windows)
}

#-----------------------------------puppet api call for windows machines-----------------------------------------
resource "null_resource" "call-puppet-windows" {
  count      = lower(var.operating_system) == "windows" ? var.vm_count : 0
  depends_on = [azurerm_virtual_machine.del_virtual_machine, azurerm_virtual_machine_extension.windows]
  triggers = {
    values = azurerm_virtual_machine_extension.windows[count.index].id
  }
  //this is to call puppet installation API
  provisioner "local-exec" {
    command     = "Invoke-WebRequest \"https://onecloudapi.deloitte.com/cloudscript/20190215/api/provision\" -Headers @{\"Authorization\" = \"Bearer ${data.external.token.result[0]}\"} -ContentType \"application/json\" -Body '${jsonencode(data.null_data_source.payload_file[count.index].outputs)}' -Method POST"
    interpreter = ["PowerShell", "-Command"]
  }
}
