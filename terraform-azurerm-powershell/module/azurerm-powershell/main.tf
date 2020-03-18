
#--------------------------------------------------------local file here to create json payload file-----------------------------------
 resource "local_file" "del_localfile" {
   content = <<EOF
     {
    "token":  {
                  "grant_type":  "client_credentials",
                  "resource":  "https://management.core.windows.net"
              },
    "servernaming":  {
                         "environment":  "${var.environment_sn}",
                         "system":  "${var.system_sn}",
                         "vmAllocationRequest":  [
                            {
                                "componentKey": "${var.componentKey_sn}",
                                "numberServers": "${var.vm_count}"
                            }
                                                 ]
                     },
    "cloudscript":  {
                        "AccountID":  "${var.subscription_id}",
                        "ResourceLocation":  "${var.resource_group_name}",
                        "Domain":  "${var.domain}",
                        "ResourceIdentifier":  "",
                        "Environment":  "${var.environment_puppet}",
                        "Provider":  "${var.provider_name}",
                        "OperatingSystem":  "${var.operating_system}"
                    },
    "sendemail":  {
                      "toEmails":  [
                                       
                                       "${var.toemail_ids}"
                                   ]
                  },
    "ILB":  {
                "$schema":  "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
                "contentVersion":  "1.0.0.0",
                "parameters":  {
                                   "adminUsername":  "${var.admin_username}",
                                   "adminPassword":  "${var.admin_password}",
                                   "vmNamePrefix":  "${var.vmname_prefix}",
                                   "virtualNetworkName":  "${var.vnet_id}",
                                   "LoadBalancerprivateIPAddress":  "${var.lb_private_ipaddress}",
                                   "AVSetUpdateDomainCount":  ${var.avset_updatedomaincount},
                                   "AVSetFaultDomainCount":  ${var.avset_faultdomaincount},
                                   "numberOfInstances":  ${var.vm_count}
                               }
            }
}

     EOF
 filename = "${path.root}/Azure_Standard_Load_Balancer_with_an_IaaS_Web_Application.json"

 }

#-------------------------------------------Running powershell script using arm template--------------------
resource "null_resource" "call_ps" {
depends_on = ["local_file.del_localfile"]
provisioner "local-exec" {

   command="./module/azurerm-powershell/Azure_Resource_Creation_ps/Azure_Standard_Load_Balancer_with_an_IaaS_Web_Application.ps1 -FileName Azure_Standard_Load_Balancer_with_an_IaaS_Web_Application.json -clientid ${var.client_id} -clientsecret ${var.client_secret} -LBTemplatePath './Azure_Resource_Creation_ps'"
   interpreter = ["PowerShell", "-Command"]
   }

}