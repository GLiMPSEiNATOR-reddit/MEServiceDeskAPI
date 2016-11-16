function Get-MESdpRequestTemplates{
[cmdletbinding()]
param(
    [Parameter(Mandatory=$false)]
    [psobject]$ConnectionInfo = (Get-MeSdpConnectionInfo)
)
begin{
}
process{

    $ModuleURL = $ConnectionInfo.APIUri + "admin/request_template/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$ConnectionInfo.APIKey}
	$RequestTemplates = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$RequestTemplates = $RequestTemplates.API.response.operation.Details.record

    foreach ($RequestTemplate in $RequestTemplates){

        $objRequestTemplate = New-Object pscustomobject -property @{
            Uri = $RequestTemplate.URI
        }

        $RequestTemplate.Parameter | ForEach-Object{Add-Member -InputObject $objRequestTemplate -MemberType NoteProperty -Name $_.name -Value $_.value}
        $objRequestTemplate | Add-ObjectDetail -TypeName ServiceDeskPlus.Admin.RequestTemplate
	}
}

}