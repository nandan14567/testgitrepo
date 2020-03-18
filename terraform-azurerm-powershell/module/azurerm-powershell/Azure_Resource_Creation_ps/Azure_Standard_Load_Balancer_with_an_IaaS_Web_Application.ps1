#######################################################################################
##
##  Deloitte Cloud Recipe : Azure Standard Load Balancer wiht IaaS Web Application.
##
##  DCR Identifier: WEBFELB0001-0.0.1
##
##  Initial Release Date: 8/22/2019
##
##  Authors:
##  --------
##  Venkat Goud
##  Roger A. Dahlman
##
########################################################################################


#This script uses a JSON input file to supply information to create the Receipe

Param(
    [Parameter(Mandatory = $True,
        HelpMessage = "Please supply a JSON parameter file.",
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True)]
    [string]$FileName,
       
        
    [Parameter(Mandatory = $True,
        HelpMessage = "Please supply a client id",
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True)]
    [string]$clientid,
   

    [Parameter(Mandatory = $True,
        HelpMessage = "Please supply a client secret",
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True)]
    [string]$clientsecret,
    [Parameter(Mandatory = $True,
        HelpMessage = "Please supply a Internal LBTemplate path.",
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True)]
    [string]$LBTemplatePath,
    
    [switch]$force = $false 
)


<#function used to generate the token to connect to Azure Environment

1. Service principle is mandatory to call the API's and to select the subscription where deployment is to be deployed.

		"grant_type": "client_credentials",
		"resource": "https://management.core.windows.net",https://management.core.windows.net
		"client_id": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
		"client_secret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

#>

Function Generate_Token {
    $key = get-content -Raw $FileName | ConvertFrom-Json 
    $key1 = $key.token

    $jsonobj = @{

        grant_type    = $key1.grant_type
        resource      = $key1.resource
        client_id     = "$clientid"
        client_secret = "$clientsecret"
    }

    $contentType = 'application/x-www-form-urlencoded' 

    $uri = 'https://login.microsoftonline.com/36da45f1-dd2c-4d1f-af13-5abe46b99921/oauth2/token'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $tokenreq = Invoke-WebRequest -Uri $uri -Method Post -Body $jsonobj -ContentType $contentType -UseBasicParsing
    $Gettoken = $tokenreq.content | Convertfrom-json
    $token = $Gettoken.access_token
    return $token

}

Function Servernaming_API {

    $naming = get-content -Raw $FileName | convertfrom-json
    $naming1 = $naming.servernaming | Convertto-Json

    $uri = 'https://onecloudapi.deloitte.com/servernaming/20190215/ServerNaming'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    #[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

    $result = Invoke-WebRequest -Uri $uri -Method POST -Body $naming1 -ContentType "text/json" -Headers @{Authorization = "Bearer $token" } -UseBasicParsing
    $ABC = $result.Content | convertfrom-json
    $output = $ABC.components.servers

    return $output
}

#Function VM_provisioning used to create the Internal Load Balancer, Avaibilityset and the number of VM's

Function VM_Provisioning {

    $vmName = $output[0].Substring(0, $output[0].Length - 1)
    write-host $vmName

    $paramFile = Get-Content $FileName | ConvertFrom-Json 
    $paramFile.ILB.parameters.vmNamePrefix=$output
   # $paramFile.ILB.parameters.vmNamePrefix = $paramFile.ILB.parameters.vmNamePrefix + "-" + $vmName
    $paramFile | ConvertTo-Json #| Set-Content $FileName
    $LB = $paramFile.ILB.parameters | ConvertTo-Json 
    $LB1 = $LB | ConvertFrom-Json


    $param = @{ }
    $items = $LB1 | Get-Member -MemberType NoteProperty | % {
        $param.($_.name) = $LB1.($_.name)
    }
    $RG = $paramFile.cloudscript.ResourceLocation
    $SUBID = $paramFile.cloudscript.AccountID
    $ACID = $clientid

    Login-AzAccount -SubscriptionId $SUBID -AccessToken $token -AccountId $ACID

    #$ILBFile = Join-Path -Path "C:\Temp" -ChildPath "\InternalLBTemplate1.json"
    $ILBFile = join-path -path $LBTemplatePath -ChildPath "\InternalLBTemplate.json"

    New-AzResourceGroupDeployment -ResourceGroupName $RG -TemplateFile $ILBFile -TemplateParameterObject $param

}


#function cloudscript will make sure that puppet installation and joining of the Domain


Function Cloud_ScriptAPI {


    $paramFile = Get-Content $FileName | ConvertFrom-Json 
    $paramFile.token.resource = "9f11e6db-715d-45a7-887e-01e00b9bc968"
    $paramFile | ConvertTo-Json | Set-Content $FileName

    $token1 = Generate_Token
    [System.Collections.ArrayList]$vmid = @()

    $paramFile = Get-Content $FileName | ConvertFrom-Json 

    foreach ($server in $output) {

        Start-sleep 20;

        $json1 = get-content -Raw $FileName | ConvertFrom-Json
        $cscriptData = $json1.cloudscript
        $cscriptData.ResourceIdentifier = $paramFile.ILB.parameters.vmNamePrefix + "-" + $server
        $cs = $cscriptData | Convertto-json 

        Write-Host $cs

        $uri = 'https://onecloudapi.deloitte.com/cloudscript/20190215/api/provision'
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        #[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        $result1 = Invoke-WebRequest -Uri $uri -Method POST -Body $cs -ContentType "text/json" -Headers @{Authorization = "Bearer $token1" } -UseBasicParsing
        write-host $result1.Content

        $vmid.Add($result1)


    }
    return $vmid
}

Function Send_Email {


    $paramFile = Get-Content $FileName | ConvertFrom-Json 
    $paramFile.token.resource = "9f11e6db-715d-45a7-887e-01e00b9bc968"
    $paramFile | ConvertTo-Json | Set-Content $FileName

    $token2 = Generate_Token


    $paramFile = Get-Content $FileName | ConvertFrom-Json 
    $to = $paramFile.sendemail.toEmails
    $tempmail = @()
    foreach ($id in $to) {
        $tempmail += $id
    }
    $to = $tempmail

    $Email = @{

        fromEmail = "admin@onecloud.deloitte.com"
        toEmails  = $to
        subject   = "Cloud script VMID Status"
        bodyText  = "$vmid"
 
    }

    $send = $Email | Convertto-Json 
    $uri = 'https://az-use-dmo-bot-aam-01.azure-api.net/notification/20190515/sendEmail'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    #[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
    $result2 = Invoke-WebRequest -Uri $uri -Method POST -Body $send -ContentType "text/json" -Headers @{Authorization = "Bearer $token2" } -UseBasicParsing


}
$token = Generate_Token
$output = Servernaming_API
VM_Provisioning
$vmid = Cloud_ScriptAPI
Send_Email






