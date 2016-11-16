function Get-MESdpUrgencies{
[cmdletbinding()]
param(
    [Parameter(Mandatory=$false)]
    [psobject]$ConnectionInfo = (Get-MeSdpConnectionInfo)
)
begin{
}
process{

    $ModuleURL = $ConnectionInfo.APIUri + "admin/urgency/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$ConnectionInfo.APIKey}
	$Urgencies = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$Urgencies = $Urgencies.API.response.operation.Details.record

    foreach ($Urgency in $Urgencies){

        $objUrgency = New-Object pscustomobject -property @{
            Uri = $Urgency.URI
        }

        $Urgency.Parameter | ForEach-Object{Add-Member -InputObject $objUrgency -MemberType NoteProperty -Name $_.name -Value $_.value}
        $objUrgency | Add-ObjectDetail -TypeName ServiceDeskPlus.Admin.Urgency
	}
}

}