Param(
    [Parameter(Mandatory = $True,
        HelpMessage = "Please supply a JSON parameter file.",
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True)]
    [string]$resource,
       
        
    [Parameter(Mandatory = $True,
        HelpMessage = "Please supply a client id",
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True)]
    [string]$clientid,
   

    [Parameter(Mandatory = $True,
        HelpMessage = "Please supply a client secret",
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True)]
    [string]$clientsecret
)

    $jsonobj = @{
        grant_type    = "client_credentials"
        resource      = "$resource"
        client_id     = "$clientid"
        client_secret = "$clientsecret"
    }

    $contentType = 'application/x-www-form-urlencoded' 

    $uri = 'https://login.microsoftonline.com/36da45f1-dd2c-4d1f-af13-5abe46b99921/oauth2/token'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $tokenReq = Invoke-WebRequest -Uri $uri -Method Post -Body $jsonobj -ContentType $contentType -UseBasicParsing
    $Gettoken = $tokenreq.content | Convertfrom-json
    $token = $Gettoken.access_token
    $text="Authorization:"+"$token"
    $text | out-file -encoding ASCII output_token_sn.txt

    

    


