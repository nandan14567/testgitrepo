
$jsonpayload = [Console]::In.ReadLine()

# Convert to JSON
$json = ConvertFrom-Json $jsonpayload

# Access JSON values 
$environment = $json.environment
$system =$json.system
$componentKey = $json.componentkey
$numberServers = $json.numberServers
# $environment = "US-Test"
# $system ="Testing"
# $componentKey = "WEB"
# $numberServers = 2
$jsonobj = [ordered]@{
    environment="$environment" 
    system="$system"
    vmAllocationRequest=@(
            @{"componentKey"="$componentKey"; "numberServers"=$numberServers}
        )
     }
$payload = $jsonobj | ConvertTo-Json -Depth 99

$uri = 'https://onecloudapi.deloitte.com/servernaming/20190215/ServerNaming'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    #[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
$result = Invoke-WebRequest -Uri $uri -Method POST -Body $payload -ContentType "text/json" -UseBasicParsing
$ABC = $result.Content | convertfrom-json
$output = $ABC.components 
$dict = @{}
for($i = 0; $i -lt $output.servers.Count; $i++){ 
    $dict.Add($i,$output.servers[$i])
}
$object = [PSCustomObject]$dict
$test=$object | ConvertTo-Json
# $EncodedText =[Convert]::ToBase64String($output)
# $output1=$output | ConvertTo-Json
#  $jsonobj1 = @{
#         grant_type    = "client_credentials"
#         resource      = "test"
#     }@
Write-Output $test