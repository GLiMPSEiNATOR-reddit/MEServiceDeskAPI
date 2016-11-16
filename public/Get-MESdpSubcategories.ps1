function Get-MESdpSubcategories{
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

    $ModuleURL = $ConnectionInfo.APIUri + "admin/subcategory/category/" + "$ParentId/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$ConnectionInfo.APIKey}
	$Subcategories = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$Subcategories = $Subcategories.API.response.operation.Details.record
    
    
    if($Subcategories -ne $null){

		foreach ($SubCat in $Subcategories){

            $objSubCat = New-Object pscustomobject -property @{
                ParentId = $ParentId
                Uri = $SubCat.URI
            } 

            $subcat.Parameter | ForEach-Object{Add-Member -InputObject $objSubCat -MemberType NoteProperty -Name $_.name -Value $_.value}
            $objSubCat | Add-ObjectDetail -TypeName ServiceDeskPlus.Admin.Subcategory
	    }
	}
}

}