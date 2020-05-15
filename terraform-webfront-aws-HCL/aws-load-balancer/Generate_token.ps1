$jsonpayload = [Console]::In.ReadLine()
$json = ConvertFrom-Json $jsonpayload

# Access JSON values 
$resource = $json.resource
$clientid = $json.clientid
$clientsecret = $json.clientsecret

$jsonobj = @{
        grant_type    = "client_credentials"
        resource      = "$resource"
        client_id     = "$clientid"
        client_secret = "$clientsecret"
}
$contentType = 'application/x-www-form-urlencoded' 
$uri = 'https://login.microsoftonline.com/36da45f1-dd2c-4d1f-af13-5abe46b99921/oauth2/token'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$tokenReq = Invoke-WebRequest -Uri $uri -Method Post -Body $jsonobj -ContentType $contentType
$Gettoken = $tokenreq.content | Convertfrom-json
$token = $Gettoken.access_token
$text="Authorization:"+"$token"
$dict = @{}
$dict.Add(0,$text)
$object = [PSCustomObject]$dict
$test=$object | ConvertTo-Json
Write-Output $test
    
    


