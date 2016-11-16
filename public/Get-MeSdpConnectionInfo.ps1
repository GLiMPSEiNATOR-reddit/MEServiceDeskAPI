function Get-MeSdpConnectionInfo{
[cmdletbinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Path = "$env:USERPROFILE\Documents\MeSdpConnectionInfo.xml"
)
begin{
    
}
process{

    if(!$script:MeSdpConnectionInfo){
        if(Test-Path $Path){
            Import-Clixml -Path $Path
            Write-Verbose "Connection Info received from xml file"

        }else{
            Write-Error "Manage Engine Service Desk Plus Connection Info configuration not found. Please run the Set-MeSdpConnectionInfo cmdlet to store your URI and API key." 
        }
    }else{
        Write-Verbose "Connection Info received from variable"
        $script:MeSdpConnectionInfo

    }
}
end{
}
}