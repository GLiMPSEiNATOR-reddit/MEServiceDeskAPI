function Set-MeSdpConnectionInfo{
[cmdletbinding()]
param(
    [Parameter(Mandatory=$true)]
	[string]$APIKey,
    [Parameter(Mandatory=$true)]
	[string]$MeAPIUri,
    [Parameter(Mandatory=$false)]
    [string]$Path = "$env:USERPROFILE\Documents\MeSdpConnectionInfo.xml"

)
begin{
}
process{

    $objConnectionInfo = New-Object pscustomobject -Property @{
        APIUri = $MeAPIUri
        APIKey = $APIKey
    }

    $objConnectionInfo | Add-ObjectDetail -TypeName ServiceDeskPlus.Admin.ConnectionInfo | Export-Clixml -Path $Path
}
end{
}
}


