function Get-MESdpCategories{
[cmdletbinding()]
param(
    [Parameter(Mandatory=$false)]
    [psobject]$ConnectionInfo = (Get-MeSdpConnectionInfo)
)
begin{
}
process{
    $ModuleURL = $ConnectionInfo.APIUri + "admin/category/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$ConnectionInfo.APIKey}
	$Categories = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$Categories = $Categories.API.Response.Operation.Details.Record
	    
    #Insert ID/Name pairs
	foreach ($Cat in $Categories){

        $objCat = New-Object pscustomobject -property @{
            Uri = $cat.URI
        } 

        $cat.Parameter | ForEach-Object{Add-Member -InputObject $objCat -MemberType NoteProperty -Name $_.name -Value $_.value}
        $objCat | Add-ObjectDetail -TypeName ServiceDeskPlus.Admin.Category
	}
}
}
