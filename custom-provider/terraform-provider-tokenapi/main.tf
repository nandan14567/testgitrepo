data "tokenapi" "example" {
  uri = "https://login.microsoftonline.com/36da45f1-dd2c-4d1f-af13-5abe46b99921/oauth2/token"
  client_id= "8a600017-ce29-45fc-9921-0ed8521a4d82"
	client_secret="D:D_b1dr]@0qXfrfr7AioWMaDO2ohluV"
  grant_type="client_credentials"
  resource="9f11e6db-715d-45a7-887e-01e00b9bc968"
}

output "test" {
    value="${data.tokenapi.example.body}"
}