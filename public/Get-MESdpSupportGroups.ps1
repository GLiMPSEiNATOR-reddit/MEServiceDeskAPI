function Get-MESdpSupportGroups{
[cmdletbinding()]
param(
    [Parameter(Mandatory=$false)]
    [psobject]$ConnectionInfo = (Get-MeSdpConnectionInfo)
)
begin{
}
process{

    $ModuleURL = $ConnectionInfo.APIUri + "admin/supportgroup/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$ConnectionInfo.APIKey}
	$SupportGroups = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$SupportGroups = $SupportGroups.API.response.operation.Details.record

    foreach ($SupportGroup in $SupportGroups){

        $objSupportGroup = New-Object pscustomobject -property @{
            Uri = $SupportGroup.URI
        }

        $SupportGroup.Parameter | ForEach-Object{Add-Member -InputObject $objSupportGroup -MemberType NoteProperty -Name $_.name -Value $_.value}
        $objSupportGroup | Add-ObjectDetail -TypeName ServiceDeskPlus.Admin.SupportGroup
	}
}

}