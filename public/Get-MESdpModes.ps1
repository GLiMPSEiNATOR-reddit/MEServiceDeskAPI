function Get-MESdpModes{
[cmdletbinding()]
param(
    [Parameter(Mandatory=$false)]
    [psobject]$ConnectionInfo = (Get-MeSdpConnectionInfo)
)
begin{
}
process{

    $ModuleURL = $ConnectionInfo.APIUri + "admin/mode/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$ConnectionInfo.APIKey}
	$Modes = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$Modes = $Modes.API.response.operation.Details.record

    foreach ($Mode in $Modes){

        $objMode = New-Object pscustomobject -property @{
            Uri = $Mode.URI
        }

        $Mode.Parameter | ForEach-Object{Add-Member -InputObject $objMode -MemberType NoteProperty -Name $_.name -Value $_.value}
        $objMode | Add-ObjectDetail -TypeName ServiceDeskPlus.Admin.Mode
	}
}

}