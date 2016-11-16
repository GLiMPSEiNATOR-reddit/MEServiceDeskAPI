function Get-MESdpRequesters{
[cmdletbinding()]
param(
    [Parameter(Mandatory=$false)]
    [psobject]$ConnectionInfo = (Get-MeSdpConnectionInfo),
    [Parameter(Mandatory=$false)]
    [string]$LoginName,
    [Parameter(Mandatory=$false)]
    [string]$DomainName,
    [Parameter(Mandatory=$false)]
    [string]$Department,
    [Parameter(Mandatory=$false)]
    [string]$SiteName,
    [Parameter(Mandatory=$false)]
    [string]$ContactNumber,
    [Parameter(Mandatory=$false)]
    [string]$EmployeeId,
    [Parameter(Mandatory=$false)]
    [string]$Name,
    [Parameter(Mandatory=$false)]
    [string]$Email,
    [Parameter(Mandatory=$false)]
    [string]$JobTitle,
    [Parameter(Mandatory=$false)]
    [string]$Noofrows
)
begin{
}
process{
$GetRequestersXML = @"
	<Details>
		<parameter>
            <name>loginname</name>
            <value>$LoginName</value>
        </parameter>
        <parameter>
            <name>domainname</name>
            <value>$DomainName</value>
        </parameter>
        <parameter>
            <name>department</name>
            <value>$Department</value>
        </parameter>
        <parameter>
            <name>sitename</name>
            <value>$SiteName</value>
        </parameter>
        <parameter>
            <name>contactnumber</name>
            <value>$ContactNumber</value>
        </parameter>
        <parameter>
            <name>employeeid</name>
            <value>$EmployeeId</value>
        </parameter>
        <parameter>
            <name>name</name>
            <value>$Name</value>
        </parameter>
        <parameter>
            <name>email</name>
            <value>$email</value>
        </parameter>
        <parameter>
            <name>jobtitle</name>
            <value>$JobTitle</value>
        </parameter>
        <parameter>
            <name>noofrows</name>
            <value>$Noofrows</value>
        </parameter>
	</Details>
"@
    $ModuleURL = $ConnectionInfo.APIUri + "requester/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$ConnectionInfo.APIKey;INPUT_DATA=$GetRequestersXML}
	$Requesters = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$Requesters = $Requesters.API.response.operation.Details.record

    foreach ($Requester in $Requesters){

        $objRequester = New-Object pscustomobject -property @{
            Uri = $Requester.URI
        }

        $Requester.Parameter | ForEach-Object{Add-Member -InputObject $objRequester -MemberType NoteProperty -Name $_.name -Value $_.value}
        $objRequester | Add-ObjectDetail -TypeName ServiceDeskPlus.Requester
	}
}

}