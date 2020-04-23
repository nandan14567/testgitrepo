data "servernamingapi" "example" {
  uri = "https://onecloudapi.deloitte.com/servernaming/20190215/ServerNaming"
  environment= "USANSPRD"
	system="pprd"
  componentkey="WEB"
  numberservers=2
  
}

output "test" {
    value="${data.servernamingapi.example.body}"
}