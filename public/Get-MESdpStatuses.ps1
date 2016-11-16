function Get-MESdpStatuses{
[cmdletbinding()]
param(
    [Parameter(Mandatory=$false)]
    [psobject]$ConnectionInfo = (Get-MeSdpConnectionInfo)
)
begin{
}
process{

    $ModuleURL = $ConnectionInfo.APIUri + "admin/status/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$ConnectionInfo.APIKey}
	$Statuses = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$Statuses = $Statuses.API.response.operation.Details.record

    foreach ($Status in $Statuses){

        $objStatus = New-Object pscustomobject -property @{
            Uri = $status.URI
        } 

        $status.Parameter | ForEach-Object{Add-Member -InputObject $objStatus -MemberType NoteProperty -Name $_.name -Value $_.value}
        $objStatus | Add-ObjectDetail -TypeName ServiceDeskPlus.Admin.Status
	}
}

}