
$jsonpayload = [Console]::In.ReadLine()
$json = ConvertFrom-Json $jsonpayload

# Access JSON values 
$environment = $json.environment
$system =$json.system
$componentKey = $json.componentkey
$numberServers = $json.numberServers

#Creating Request Payload
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
Function Generate_Servernames {
$result = Invoke-WebRequest -Uri $uri -Method POST -Body $payload -ContentType "text/json" -UseBasicParsing
If ($result.RawContentLength  -lt 180)  {
  $result=Generate_Servernames
}
return $result
}
$myservers=Generate_Servernames
$ABC = $myservers.Content | convertfrom-json
$output = $ABC.components 
$dict = @{}
for($i = 0; $i -lt $output.servers.Count; $i++){
if ($output.servers.Count -eq 1){
    $dict.Add($i,$output.servers)
    }
    Else {
    $dict.Add($i,$output.servers[$i])
    }
}
$object = [PSCustomObject]$dict
$test=$object | ConvertTo-Json
Write-Output $test