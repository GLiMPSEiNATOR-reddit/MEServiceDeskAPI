function Get-MESdpRequestFilters{
[cmdletbinding()]
param(
    [Parameter(Mandatory=$false)]
    [psobject]$ConnectionInfo = (Get-MeSdpConnectionInfo)
)
begin{
}
process{

    $ModuleURL = $ConnectionInfo.APIUri + "request/"
	$Params = @{OPERATION_NAME='GET_REQUEST_FILTERS';TECHNICIAN_KEY=$ConnectionInfo.APIKey}
	$RequestFilters = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$RequestFilters = $RequestFilters.operation.Details.Filters.Parameter

    foreach ($RequestFilter in $RequestFilters){

        $objRequestFilter = New-Object pscustomobject -property @{
            RequestFilter = $RequestFilter.Name 
            DisplayName = $RequestFilter.Value
        }

        $objRequestFilter | Add-ObjectDetail -TypeName ServiceDeskPlus.Admin.RequestFilter
	}
}

}