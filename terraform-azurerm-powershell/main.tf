resource "null_resource" "test-api1" {
provisioner "local-exec" {
   
   command="./Azure_Resource_Creation_ps/Azure_Standard_Load_Balancer_with_an_IaaS_Web_Application.ps1 -FileName ${var.payload_filename} -clientid ${var.client_id} -clientsecret ${var.client_secret} -LBTemplatePath './Azure_Resource_Creation_ps'"
   interpreter = ["PowerShell", "-Command"]
   }

}