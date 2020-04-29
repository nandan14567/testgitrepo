#Creating security group for load balancer
module "alb_security_group" {
  source              = "../security-group"
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
    DCR: "AWS-WEBFALB0002-0.0.1"
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
  vpc_id   = data.aws_subnet_ids.del_subnet_ids.vpc_id
  tags     = {
    DCR: "AWS-WEBFALB0002-0.0.1"
  }
}

# Listeners for LB
resource "aws_lb_listener" "del_frontend_https" {
  load_balancer_arn = aws_lb.del_load_balancer.arn
  port              = 443
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
    echo '{"elevated_groups": {"sudo_groups":${jsonencode(var.securitygroup_administrators)}}}' >/etc/puppetlabs/facter/facts.d/elevated_groups.json
    echo "Hello, World" > index.html
    sudo apt update
    sudo apt install apache2 --assume-yes
    sudo hostnamectl set-hostname ${jsondecode(data.restapi.servernaming.body).components[0].servers[count.index]}
    echo -e "127.0.0.1 ${jsondecode(data.restapi.servernaming.body).components[0].servers[count.index]} localhost.localdomain localhost\n10.28.188.91 uspup-cm.us.deloitte.com" > /etc/hosts
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
     wmic computersystem where name="%COMPUTERNAME%" call rename name="${jsondecode(data.restapi.servernaming.body).components[0].servers[count.index]}"
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
data "restapi" "servernaming"{
  uri = "https://onecloudapi.deloitte.com/servernaming/20190215/ServerNaming"
  method= "POST"
  request_body=jsonencode(var.servernaming)
  request_headers = {
    Content-Type = "application/json"
  }
}

#Creating security group for ec2 instances
module "instance_security_group" {
  source              = "../security-group"
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
    DCR: "AWS-WEBFALB0002-0.0.1"
    Name = jsondecode(data.restapi.servernaming.body).components[0].servers[count.index]
  }
  user_data = var.operatingsystem == "windows" ? data.null_data_source.userdata_windows[count.index].outputs["windows_userdata"] : data.null_data_source.userdata_linux[count.index].outputs["linux_userdata"]
}

# EC2 Instance Linking with Target Group
resource "aws_lb_target_group_attachment" "test" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.del_target_group.arn
  target_id        = aws_instance.aws-instance[count.index].id
}

//Data Token Generation API 
data "restapi" "tokenapi"{
  uri = "https://login.microsoftonline.com/36da45f1-dd2c-4d1f-af13-5abe46b99921/oauth2/token"
  method= "POST"
  request_body=<<-EOF
  {
     "grant_type":"client_credentials",
     "resource":"${var.resource_token}",
     "client_id":"${var.client_id}",
     "client_secret":"${var.client_secret}"
  }
  EOF
   request_headers = {
     Content-Type = "Application/x-www-form-Urlencoded"
   }
}

// Waiting to get instance in ready state beore calling puppet api
resource "null_resource" "wait_before_puppet_api_call" {
  depends_on = [aws_instance.aws-instance,aws_lb.del_load_balancer]
  provisioner "local-exec" {
    command     = "Start-Sleep -s 250"
    interpreter = ["PowerShell", "-Command"]
  }
}
//Data puppet installation api
data "restapi" "puppet" {
  count      = var.instance_count
  depends_on = [null_resource.wait_before_puppet_api_call]
  uri = "https://onecloudapi.deloitte.com/cloudscript/20190215/api/provision"
  method= "POST"
  request_body=<<-EOF
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
  request_headers = {
    Authorization =jsondecode(data.restapi.tokenapi.body).access_token
    Content-Type = "application/json"
  }
}
output "puppet_response" {
  value = [data.restapi.puppet.*.body]
}
