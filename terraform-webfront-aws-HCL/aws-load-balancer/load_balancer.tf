#Creating security group for load balancer
module "alb_security_group" {
  source              = "./security-group"
  security_group_name = "${var.recipe_name}-alb_security_group"
  tcp_ports           = ["443"]
  cidrs               = var.recipe_cidrs
  vpc_id              = var.vpc_id
}

# Creating application LB
resource "aws_lb" "del_load_balancer" {
  name               = "${var.recipe_name}-ALB"
  load_balancer_type = "application"
  security_groups    = [module.alb_security_group.Security_Group_Id]
  subnets            = data.aws_subnet_ids.del_subnet_ids.ids
  internal           = true
  tags               = {
    DCR: "AWS-WEBFALB0001-0.0.2"
  }
}

# Getting subnets 
data "aws_subnet_ids" "del_subnet_ids" {
  vpc_id = var.vpc_id
}

# Target group
resource "aws_lb_target_group" "del_target_group" {
  name     = "${var.recipe_name}-tgroup"
  port     = "443"
  protocol = "HTTPS"
  vpc_id   = var.vpc_id
  tags     = {
    DCR: "AWS-WEBFALB0001-0.0.2"
  }
}

# Listeners for LB
resource "aws_lb_listener" "del_frontend_https" {
  load_balancer_arn = aws_lb.del_load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn
  ssl_policy        = var.ssl_policy
  default_action {
    target_group_arn = aws_lb_target_group.del_target_group.arn
    type             = "forward"
  }
}

#  Data null for linux_userdata
data "null_data_source" "userdata_linux" {
  count = var.operatingsystem=="linux"?var.instance_count:0
   inputs    = {
    linux_userdata=<<-EOF
    #!/bin/bash
    mkdir -p /etc/puppetlabs/facter/facts.d
    echo ' {"elevated_groups": {"sudo_groups":${jsonencode(var.securitygroup_administrators)}}}' >/etc/puppetlabs/facter/facts.d/elevated_groups.json
    echo "Hello, World" > index.html
    sudo apt update
    sudo apt install apache2 --assume-yes
    sudo hostnamectl set-hostname ${data.external.servernaming.result[count.index]}
    echo -e "127.0.0.1 ${data.external.servernaming.result[count.index]} localhost.localdomain localhost\n10.28.188.91 uspup-cm.us.deloitte.com" > /etc/hosts
    echo "perserve_hostname:true" >> /etc/cloud/cloud.cfg
    sudo a2enmod ssl
    sudo a2ensite default-ssl
    sudo /etc/init.d/apache2 restart
    reboot
    EOF
   }
}

#Data null for windows userdata
data "null_data_source" "userdata_windows" {
  count = var.operatingsystem=="windows"?var.instance_count:0
  inputs = {
    windows_userdata=<<-EOF
    <script>
     mkdir  C:\ProgramData\PuppetLabs\facter\facts.d 
     echo {"elevated_groups": {"Administrators":${jsonencode(var.securitygroup_administrators)}}} > C:\ProgramData\PuppetLabs\facter\facts.d\elevated_group.json
     wmic computersystem where name="%COMPUTERNAME%" call rename name="${data.external.servernaming.result[count.index]}"
    </script>
    <powershell> 
      Start-Transcript; 
      # Install IIS
      Import-Module ServerManager; 
      Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName 'IIS-WebServerRole', 'IIS-WebServer', 'IIS-ManagementConsole';
      # Configure Bindings to :443
      New-WebBinding -Name "Default Web Site" -IP "*" -Port 443 -Protocol https -SslFlags 0;
      $newCert = New-SelfSignedCertificate -DnsName localhost -CertStoreLocation cert:\LocalMachine\My; 
      $SslBinding = Get-WebBinding -Name "Default Web Site" -Protocol "https";
      $SslBinding.AddSslCertificate($newCert.GetCertHashString(), "my"); 
      Get-WebBinding -Port 80 -Name "Default Web Site" | Remove-WebBinding;
      Restart-Computer
    </powershell>
    EOF
  }
}

#Calling Servernaming API
data "external" "servernaming" {
  program = ["Powershell.exe", "${path.module}/Get_servers.ps1"]
  query = {
    numberServers = var.instance_count
    environment   = var.environment_servernaming
    system        = var.system_servernaming
    componentKey  = var.componentKey_servernaming
  }
}

#Creating security group for ec2 instances
module "instance_security_group" {
  source              = "./security-group"
  security_group_name = "${var.recipe_name}-ec2_security_group"
  tcp_ports           = var.instance_ports
  cidrs               = var.recipe_cidrs
  vpc_id              = var.vpc_id
}

# EC2 Instances For LB
resource "aws_instance" "aws-instance" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.instance_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [module.instance_security_group.Security_Group_Id]
  iam_instance_profile   = var.instance_role
  tags                   = {
    DCR: "AWS-WEBFALB0001-0.0.1"
    Name = data.external.servernaming.result[count.index]
  }
  user_data = var.operatingsystem == "windows" ? data.null_data_source.userdata_windows[count.index].outputs["windows_userdata"] : data.null_data_source.userdata_linux[count.index].outputs["linux_userdata"]
}

# EC2 Instance Linking with Target Group
resource "aws_lb_target_group_attachment" "test" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.del_target_group.arn
  target_id        = aws_instance.aws-instance[count.index].id
}

//Token Generation API 
resource "null_resource" "test-api1" {
  triggers = {
    values = "${aws_instance.aws-instance[0].id}"
  }
  //this is to get token
  provisioner "local-exec" {
    command     = "${path.module}/Generate_token.ps1 -resource ${var.resource_token} -clientid ${var.client_id} -clientsecret ${var.client_secret}"
    interpreter = ["PowerShell", "-Command"]
  }
}

//Puppet installation api Payload Creation
resource "local_file" "terraform_tf" {
  count      = var.instance_count
  content    = <<-EOF
  {
        "AccountID":  "${var.accountid_puppet}",
        "ResourceLocation":  "${var.region}",
        "Domain":  "${var.domain_puppet}",
        "ResourceIdentifier":"${aws_instance.aws-instance[count.index].id}",
        "Environment": "${var.environment_puppet}",
        "Provider":  "aws",
        "OperatingSystem": "${var.operatingsystem}"
  }
  EOF
  filename   = "${path.root}/temppayload${count.index}.json"
}

//puppet installation api
resource "null_resource" "test-api3" {
  count      = var.instance_count
  depends_on = [aws_instance.aws-instance,aws_lb.del_load_balancer]
  triggers = {
    values = "${aws_instance.aws-instance[count.index].id}"
  }
  provisioner "local-exec" {
    command     = "Start-Sleep -s 250"
    interpreter = ["PowerShell", "-Command"]
  }
  provisioner "local-exec" {
    command = "curl --header 'Content-Type:application/json' --header @output_token_sn.txt  --request POST --data @temppayload${count.index}.json  https://onecloudapi.deloitte.com/cloudscript/20190215/api/provision"
  }
}