output "puppet_response" {
  value = [data.restapi.puppet.*.body]
}