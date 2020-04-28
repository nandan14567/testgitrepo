output "puppet_response" {
  value = var.operating_system == "windows" ? data.restapi.puppet_windows.*.body : data.restapi.puppet_linux.*.body
}


