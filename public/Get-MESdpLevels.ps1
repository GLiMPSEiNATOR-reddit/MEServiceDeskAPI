function Get-MESdpLevels{
[cmdletbinding()]
param(
    [Parameter(Mandatory=$false)]
    [psobject]$ConnectionInfo = (Get-MeSdpConnectionInfo)
)
begin{
}
process{

    $ModuleURL = $ConnectionInfo.APIUri + "admin/level/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$ConnectionInfo.APIKey}
	$Levels = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$Levels = $Levels.API.response.operation.Details.record

    foreach ($Level in $Levels){

        $objLevel = New-Object pscustomobject -property @{
            Uri = $Level.URI
        } 

        $Level.Parameter | ForEach-Object{Add-Member -InputObject $objLevel -MemberType NoteProperty -Name $_.name -Value $_.value}
        $objLevel | Add-ObjectDetail -TypeName ServiceDeskPlus.Admin.Level
	}
}

}