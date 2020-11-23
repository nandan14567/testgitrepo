##########################################################
## Get Server Names
##########################################################
data "restapi" "servernaming" {
  uri          = "https://onecloudapi.deloitte.com/servernaming/20190215/ServerNaming"
  method       = "POST"
  request_body = <<EOF
  {
    "environment":"awste",
    "system":"test123",
    "vmAllocationRequest":[
        {  "componentKey":"WEB",
           "numberServers":2
        }
      ]
  }
EOF
  request_headers = {
    Content-Type = "application/json"
  }
}

# Data Token Generation API 
data "restapi" "tokenapi" {
  uri          = "https://login.microsoftonline.com/36da45f1-dd2c-4d1f-af13-5abe46b99921/oauth2/token"
  method       = "POST"
  request_body = <<-EOF
  {
    
  }
  EOF
  request_headers = {
    Content-Type = "Application/x-www-form-Urlencoded"
  }
}
data "restapi" "ip_validation" {
  uri    = "https://automation2.deloitte.com/dev/network/f5-cloud/v1/validateIP?ip_address=192.168.2.250&cidr_block=192.168.0.0/16"
  method = "GET"
  request_headers = {
    x-api-key     = "3555FS472D9IAalke4Ynt1P3JNzhD4661Yw4KWB5"
    Content-Type  = "application/json"
    Authorization = "Bearer ${jsondecode(data.restapi.tokenapi.body).access_token}"
  }
}

output "servernaming" {
  value = jsondecode(data.restapi.servernaming.body).components[0].servers.*
}
output "ipvalidtn" {
  value = data.restapi.ip_validation.body
}

# data"restapi""email"{
# uri          = "https://az-use-dmo-bot-aam-01.azure-api.net/notification/20190515/sendEmail"
# method       = "POST"
# request_body = <<EOF
#  {
#     "subject":  "AWS-MSSQLinstancecreatedsuccessfully",
#     "bodyText":  "HiDatabaseTeam, MSSQLinstancecreatedsuccessfullyinAWS ",
#     "fromEmail":  "admin@onecloud.deloitte.com",
#     "toEmails":  [
#                      "arshads@cirruslabs.io"
#                  ]
# }
# EOF
# request_headers = {
# Content-Type  = "text/xml"
# Authorization = jsondecode(data.restapi.tokenapi.body).access_token
#   }
# }
# output "token" {
#   value = jsondecode(data.restapi.tokenapi.body).access_token
# }

# output"Done"{
# value = data.restapi.email.body
# }
