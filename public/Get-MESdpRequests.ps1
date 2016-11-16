function Get-MESdpRequests{
[cmdletbinding()]
param(
	[Parameter(Mandatory=$False)]
	[string]$ReqID,
	[Parameter(Mandatory=$False)]
	[ValidateScript({ Get-MESdpRequestFilters | select -ExpandProperty RequestFilter })]
	[string]$RequestFilter = 'All_Requests',
	[Parameter(Mandatory=$False, ParameterSetName='limit')]
	[int]$LowerLimit = 0,
	[Parameter(Mandatory=$False, ParameterSetName='limit')]
	[int]$UpperLimit = 100,
    [Parameter(Mandatory=$false)]
    [psobject]$ConnectionInfo = (Get-MeSdpConnectionInfo)
)
begin{
}
process{
$GetReqsXML = @"
	<Details>
		<parameter>
		<name>from</name>
		<value>$LowerLimit</value>
		</parameter>
		<parameter>
		<name>limit</name>
		<value>$UpperLimit</value>
		</parameter>
		<parameter>
		<name>filterby</name>
		<value>$RequestFilter</value>
		</parameter>
	</Details>
"@
    $ModuleURL = $ConnectionInfo.APIUri + "request/"
    $Params = @{OPERATION_NAME='GET_REQUESTS';TECHNICIAN_KEY=$ConnectionInfo.APIKey;INPUT_DATA=$GetReqsXML}
	$Requests = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
    $Requests = $Requests.API.response.operation.Details.record
    
	foreach ($Request in $Requests){

        $objRequest = New-Object pscustomobject -property @{
            Uri = $Request.URI
        } 

        $Request.Parameter | ForEach-Object{Add-Member -InputObject $objRequest -MemberType NoteProperty -Name $_.name -Value $_.value}
        $objRequest | Add-ObjectDetail -TypeName ServiceDeskPlus.Request
	}
	
}

}