function Get-MESdpImpacts{
[cmdletbinding()]
param(
    [Parameter(Mandatory=$false)]
    [psobject]$ConnectionInfo = (Get-MeSdpConnectionInfo)
)
begin{
}
process{

    $ModuleURL = $ConnectionInfo.APIUri + "admin/impact/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$ConnectionInfo.APIKey}
	$Impacts = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$Impacts = $Impacts.API.response.operation.Details.record

    foreach ($Impact in $Impacts){

        $objImpact = New-Object pscustomobject -property @{
            Uri = $Impact.URI
        }

        $Impact.Parameter | ForEach-Object{Add-Member -InputObject $objImpact -MemberType NoteProperty -Name $_.name -Value $_.value}
        $objImpact | Add-ObjectDetail -TypeName ServiceDeskPlus.Api.Mode
	}
}

}