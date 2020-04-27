data "puppetapi" "example" {
  uri                = "https://onecloudapi.deloitte.com/cloudscript/20190215/api/provision"
  accountid          = "868978391936"
  resourcelocation   = "us-east-1"
  domain             = "us.deloitte.com"
  resourceidentifier = "i-0525daa2cddb73899"
  environment        = "NPD"
  providertype       = "aws"
  operatingsystem    = "windows"
  securitygroup      = "us"
  token              = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IkN0VHVoTUptRDVNN0RMZHpEMnYyeDNRS1NSWSIsImtpZCI6IkN0VHVoTUptRDVNN0RMZHpEMnYyeDNRS1NSWSJ9.eyJhdWQiOiI5ZjExZTZkYi03MTVkLTQ1YTctODg3ZS0wMWUwMGI5YmM5NjgiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC8zNmRhNDVmMS1kZDJjLTRkMWYtYWYxMy01YWJlNDZiOTk5MjEvIiwiaWF0IjoxNTg3NzE3NTg3LCJuYmYiOjE1ODc3MTc1ODcsImV4cCI6MTU4NzcyMTQ4NywiYWlvIjoiNDJkZ1lMRFZ1Sk1UcEhqY2I4ZU8yb3ViYzZkK0FnQT0iLCJhcHBpZCI6IjhhNjAwMDE3LWNlMjktNDVmYy05OTIxLTBlZDg1MjFhNGQ4MiIsImFwcGlkYWNyIjoiMSIsImlkcCI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzM2ZGE0NWYxLWRkMmMtNGQxZi1hZjEzLTVhYmU0NmI5OTkyMS8iLCJvaWQiOiIyNzA3NDg4ZC1hYjc1LTQzOTAtOTM5NC0wZDg5MzM0ODQzYTciLCJzdWIiOiIyNzA3NDg4ZC1hYjc1LTQzOTAtOTM5NC0wZDg5MzM0ODQzYTciLCJ0aWQiOiIzNmRhNDVmMS1kZDJjLTRkMWYtYWYxMy01YWJlNDZiOTk5MjEiLCJ1dGkiOiJxbEtDSG5YVWprS011eWMxYXJvVEFBIiwidmVyIjoiMS4wIn0.PJ3nixWmqT98UCYQRW8XZlSxBt9wHU7KraiGDpNYxtI4w-ipgYXYhc5SoyiR8ZWtCkczaaxUirFFmZ_6x4oTRcppz_wwMpWdfJzqqAjrcCegwaypznDC6z4pHfK3YQacNR8p3XH8apnOosumnFacURiu4d8UqO_YV2IDGOXRSNIMWGCM1XprLjwUTxO08HD_Tm7X6kz5WYs8fNzzIwfu96V_bq0dxG_wGKrEb_Vd2LIHqSSG1cRdkQpLthAuH5bBS52UHncT7TMvtoPCu6yLPcXZzjiL89iHZPGVQA6hkjFMJQMTs-gK2AuFJ3Y3SbH--0D8SucvbDmJ0sEyknNYwg"

}

output "test" {
  value = "${data.puppetapi.example.body}"
}
