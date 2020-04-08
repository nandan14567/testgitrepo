# Creating application LB
resource "aws_lb" "del_load_balancer" {
  name               = var.lb_name
  load_balancer_type = "application"
  security_groups    = var.aws_lb_security_group
  subnets            = data.aws_subnet_ids.del_subnet_ids.ids
  internal           = true
  tags               = {
    DCR: "AWS-WEBFALB0002-0.0.1"
  }
}
#Getting subnets 
data "aws_subnet_ids" "del_subnet_ids" {
  vpc_id = var.vpc_id
}

#creating target group
resource "aws_lb_target_group" "del_target_group" {
  name     = lookup(var.target_group, "name", null)
  port     = lookup(var.target_group, "backend_port", null)
  protocol = lookup(var.target_group, "backend_protocol", null) != null ? upper(lookup(var.target_group, "backend_protocol")) : null
  vpc_id   = data.aws_subnet_ids.del_subnet_ids.vpc_id
  tags     = {
    DCR: "AWS-WEBFALB0002-0.0.1"
  }
}

#Listeners for LB
resource "aws_lb_listener" "del_frontend_http_tcp" {
  count             = true ? length(var.http_tcp_listeners) : 0
  load_balancer_arn = aws_lb.del_load_balancer.arn
  port              = var.http_tcp_listeners[count.index]["port"]
  protocol          = var.http_tcp_listeners[count.index]["protocol"]
  default_action {
    target_group_arn = aws_lb_target_group.del_target_group.arn
    type             = "forward"
  }
}

#Listeners for LB
resource "aws_lb_listener" "del_frontend_https" {
  count             = true ? length(var.https_listeners) : 0
  load_balancer_arn = aws_lb.del_load_balancer.arn
  port              = var.https_listeners[count.index]["port"]
  protocol          = lookup(var.https_listeners[count.index], "protocol", "HTTPS")
  certificate_arn   = var.https_listeners[count.index]["certificate_arn"]
  ssl_policy        = lookup(var.https_listeners[count.index], "ssl_policy", var.listener_ssl_policy_default)
  default_action {
    target_group_arn = aws_lb_target_group.del_target_group.arn
    type             = "forward"
  }
}

//Local File for Windows user Data
resource "local_file" "windows_userdata" {
  count = var.OperatingSystem=="windows"?var.ec2-count:0
  content    = <<-EOF
    <script>
     mkdir  C:\ProgramData\PuppetLabs\facter\facts.d 
     echo {"elevated_groups": {"Administrators":["us\\SG-US-868978391936-Admin","us\\SG-US-197151468794-Admin"]}} > C:\ProgramData\PuppetLabs\facter\facts.d\elevated_group.json
     wmic computersystem where name="%COMPUTERNAME%" call rename name="${var.instance_names[count.index]}"
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
    filename   = "${path.root}/user_data.txt"
}

// local file for linux_userdata
resource "local_file" "linux_userdata" {
  count = var.OperatingSystem=="linux"?var.ec2-count:0
  content    = <<-EOF
    #!/bin/bash
    mkdir -p /etc/puppetlabs/facter/facts.d
    echo {"elevated_groups": {"sudo_groups": ["%sg-us-197151468794-admin","%sg-us-868978391936-admin"],"access_groups": ["sg-us-197151468794-admin","sg-us-868978391936-admin"]}}>/etc/puppetlabs/facter/facts.d/elevated_groups.json
    echo "Hello, World" > index.html
    sudo apt update
    sudo apt install apache2 --assume-yes
    sudo hostnamectl set-hostname ${var.instance_names[count.index]}
    echo -e "127.0.0.1 ${var.instance_names[count.index]} localhost.localdomain localhost\n10.28.188.91 uspup-cm.us.deloitte.com" > /etc/hosts
    echo "perserve_hostname:true" >> /etc/cloud/cloud.cfg
    sudo a2enmod ssl
    sudo a2ensite default-ssl
    sudo /etc/init.d/apache2 restart
    reboot
    EOF
    filename   = "${path.root}/user_data.txt"
}

#EC2 Instances For LB
resource "aws_instance" "my-instance" {
  depends_on=[local_file.linux_userdata,local_file.windows_userdata]
  count                  = var.ec2-count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.ec2_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = var.instance_security_group
  iam_instance_profile   = var.instance_role
  tags                   = {
    DCR: "AWS-WEBFALB0002-0.0.1"
    Name = var.instance_names[count.index]
  }
  user_data = var.OperatingSystem == "windows" ? local_file.windows_userdata[count.index].content : local_file.linux_userdata[count.index].content
  }

#EC2 Instance Linking with Target Group
resource "aws_lb_target_group_attachment" "test" {
  count            = var.ec2-count
  target_group_arn = aws_lb_target_group.del_target_group.arn
  target_id        = aws_instance.my-instance[count.index].id
}

//Token Generation API 
resource "null_resource" "test-api1" {
  triggers = {
    values = "${aws_instance.my-instance[0].id}"
  }
  //this is to get token
  provisioner "local-exec" {
    command     = "./Generate_token.ps1 -resource ${var.resource} -clientid ${var.client_id} -clientsecret ${var.client_secret}"
    interpreter = ["PowerShell", "-Command"]
  }
}

//Puppet installation api Payload Creation
resource "local_file" "terraform_tf" {
  count      = var.ec2-count
  depends_on = ["aws_instance.my-instance", "aws_lb.del_load_balancer", "aws_lb_target_group.del_target_group", "aws_lb_listener.del_frontend_http_tcp", "aws_lb_listener.del_frontend_https"]
  content    = <<-EOF
  {
      "AccountID":  "${var.AccountID}",
      "ResourceLocation":  "${var.ResourceLocation}",
      "Domain":  "${var.Domain}",
      "ResourceIdentifier":"${aws_instance.my-instance[count.index].id}",
      "Environment":  "${var.Environment}",
      "Provider":  "${var.Provider}",
      "OperatingSystem":  "${var.OperatingSystem}",
      "SecurityGroup": "${var.SecurityGroup}"
  }
  EOF
  filename   = "${path.root}/temppayload${count.index}.json"
}

//puppet installation api
resource "null_resource" "test-api3" {
  count      = var.ec2-count
  depends_on = ["local_file.terraform_tf", "aws_instance.my-instance", "aws_lb.del_load_balancer", "aws_lb_target_group.del_target_group", "aws_lb_listener.del_frontend_http_tcp", "aws_lb_listener.del_frontend_https"]
  triggers = {
    values = "${aws_instance.my-instance[count.index].id}"
  }
  provisioner "local-exec" {
    command     = "Start-Sleep -s 300"
    interpreter = ["PowerShell", "-Command"]
  }
  provisioner "local-exec" {
    command = "curl --header 'Content-Type:application/json' --header @output_token_sn.txt  --request POST --data @temppayload${count.index}.json  https://onecloudapi.deloitte.com/cloudscript/20190215/api/provision"
  }
}