##########################################################
## Send Email to DB TEam
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
     "grant_type":"client_credentials",
     "resource":"9f11e6db-715d-45a7-887e-01e00b9bc968",
     "client_id":"8a600017-ce29-45fc-9921-0ed8521a4d82",
     "client_secret":"D:D_b1dr]@0qXfrfr7AioWMaDO2ohluV"
  }
  EOF
  request_headers = {
    Content-Type = "Application/x-www-form-Urlencoded"
  }
}

data"restapi""email"{
uri          = "https://az-use-dmo-bot-aam-01.azure-api.net/notification/20190515/sendEmail"
method       = "POST"
request_body = <<EOF
 {
    "subject":  "AWS-MSSQLinstancecreatedsuccessfully",
    "bodyText":  "HiDatabaseTeam, MSSQLinstancecreatedsuccessfullyinAWS ",
    "fromEmail":  "admin@onecloud.deloitte.com",
    "toEmails":  [
                     "arshads@cirruslabs.io"
                 ]
}
EOF
request_headers = {
Content-Type  = "text/xml"
Authorization = jsondecode(data.restapi.tokenapi.body).access_token
  }
}
# output "token" {
#   value = jsondecode(data.restapi.tokenapi.body).access_token
# }

output"Done"{
value = data.restapi.email.body
}

output "servernaming" {
  value = jsondecode(data.restapi.servernaming.body).components[0].servers.*
}
