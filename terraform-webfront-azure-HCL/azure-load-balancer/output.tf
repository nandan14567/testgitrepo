output "puppet_response" {
  value = lower(var.operating_system) == "windows" ? data.restapi.puppet_windows.*.body : data.restapi.puppet_linux.*.body
}


