function Get-MESdpItems{
[cmdletbinding()]
param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [int]$ParentId,
    [Parameter(Mandatory=$false)]
    [psobject]$ConnectionInfo = (Get-MeSdpConnectionInfo)
)
begin{
}
process{

    $ModuleURL = $ConnectionInfo.APIUri + "admin/item/subcategory/" + "$ParentId/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$ConnectionInfo.APIKey}
	$Items = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$Items = $Items.API.response.operation.Details.record
    
    if($Items -ne $null){

        foreach ($item in $Items){

            $objItem = New-Object pscustomobject -property @{
                ParentId = $ParentId
                Uri = $item.URI
            } 

            $item.Parameter | ForEach-Object{Add-Member -InputObject $objItem -MemberType NoteProperty -Name $_.name -Value $_.value}
            $objItem | Add-ObjectDetail -TypeName ServiceDeskPlus.Admin.Item
	    }
	}
}

}