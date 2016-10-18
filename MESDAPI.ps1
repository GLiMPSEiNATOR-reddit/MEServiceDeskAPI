If (Test-Path -Path .\key.txt)
{
	$MEBaseURL = @(Get-Content -Path .\key.txt)[0]
	$MEAPIKey = @(Get-Content -Path .\key.txt)[1]
}
else {
	Write-Error -Message 'You need your ME SD URL and API key in key.txt, one per line.'
}

$CategoryHash = @{}
$StatusHash = @{}
$LevelHash = @{}
$ModeHash = @{}
$ImpactHash = @{}
$UrgencyHash = @{}
$PriorityHash = @{}
$RequestTemplateHash = @{}
$SupportGroupHash = @{}
$RequestFilterHash = @{}

function Get-MECategories
{
	If ($CategoryHash.Count -eq 0)
	{  	
		$ModuleURL = $MEBaseURL + "admin/category/"
		$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$MEAPIKey}
		[xml]$Categories = (Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
		#Insert ID/Name pairs with a hashtable for the subcategories
		$Categories.API.response.operation.Details.record | Foreach {$CategoryHash[$_.parameter.value[0]] = @($_.parameter.value[1], @{})}
	
		Foreach ($CatKey in $CategoryHash.Keys)
		{
			#Insert Subcategories into the Category hashtable keyed on the parent Category ID
			$CategoryHash[$CatKey][1] = Get-MESubcategories -CatKey $CatKey
		}
	}
	else
	{
		#Variable not populated
		$CategoryHash = Get-MECategories
	}

	return $CategoryHash
}


function Get-MESubcategories
{
	Param(
	[Parameter(Mandatory=$True)]
	[string]$CatKey
	)

	$ModuleURL = $MEBaseURL + "admin/subcategory/category/" + "$CatKey/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$MEAPIKey}
	$Subcategories = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$Subcategories = $Subcategories.API.response.operation.Details.record

	$SubCategoryHash = @{}
	If ($Subcategories -ne $null)
	{
		$Subcategories | Foreach {$SubCategoryHash[$_.parameter.value[0]] = @($_.parameter.value[1], @{})}
		
		Foreach ($SubCatKey in $SubCategoryHash.Keys)
		{
			$SubCategoryHash[$SubCatKey][1] = Get-MEItems -SubCatKey $SubCatKey
		}
	}
	
	return $SubCategoryHash
}

function Get-MEItems
{
	Param(
	[Parameter(Mandatory=$True)]
	[string]$SubCatKey
	)

	$ModuleURL = $MEBaseURL + "admin/item/subcategory/" + "$SubCatKey/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$MEAPIKey}
	$Items = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$Items = $Items.API.response.operation.Details.record
	
	$ItemHash = @{}
	If ($Items -ne $null)
	{
		$Items | Foreach {$ItemHash[$_.parameter.value[0]] = $_.parameter.value[1]}
	}

	return $ItemHash
}

function Get-MEStatuses
{
	$ModuleURL = $MEBaseURL + "admin/status/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$MEAPIKey}
	$Statuses = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$Statuses = $Statuses.API.response.operation.Details.record

	$Statuses | Foreach {$StatusHash[$_.parameter.value[0]] = $_.parameter.value[1]}
	
	
	return $StatusHash
}

function Get-MELevels
{
	$ModuleURL = $MEBaseURL + "admin/level/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$MEAPIKey}
	$Levels = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$Levels.API.response.operation.Details.record | Foreach {$LevelHash[$_.parameter.value[0]] = $_.parameter.value[1]}
	$ModuleURL = ''
	return $LevelHash
}

function Get-MEModes
{
	$ModuleURL = $MEBaseURL + "admin/mode/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$MEAPIKey}
	$Modes = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$Modes.API.response.operation.Details.record | Foreach {$ModeHash[$_.parameter.value[0]] = $_.parameter.value[1]}
	$ModuleURL = ''
	return $ModeHash
}

function Get-MEImpacts
{
	$ModuleURL = $MEBaseURL + "admin/impact/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$MEAPIKey}
	$Impacts = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$Impacts.API.response.operation.Details.record | Foreach {$ImpactHash[$_.parameter.value[0]] = $_.parameter.value[1]}
	$ModuleURL = ''
	return $ImpactHash
}

function Get-MEUrgencies
{
	$ModuleURL = $MEBaseURL + "admin/urgency/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$MEAPIKey}
	$Urgencies = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$Urgencies.API.response.operation.Details.record | Foreach {$UrgencyHash[$_.parameter.value[0]] = $_.parameter.value[1]}
	$ModuleURL = ''
	return $UrgencyHash
}

function Get-MEPriorities
{
	$ModuleURL = $MEBaseURL + "admin/priority/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$MEAPIKey}
	$Priorities = [xml](Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$Priorities.API.response.operation.Details.record | Foreach {$PriorityHash[$_.parameter.value[0]] = $_.parameter.value[1]}
	$ModuleURL = ''
	return $PriorityHash
}

function Get-MERequestTemplates
{
	$ModuleURL = $MEBaseURL + "admin/request_template/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$MEAPIKey}
	[xml]$RequestTemplates = (Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$RequestTemplates.API.response.operation.Details.record | Foreach {$RequestTemplateHash[$_.parameter.value[0]] = $_.parameter.value[1]}
	$ModuleURL = ''
	return $RequestTemplateHash
}

<# 
#We don't seem to have this data populated.
function Get-MESupportGroups 
{
	$SupportGroupXML = @"
	<?xml version="1.0" encoding="UTF-8"?>
	<operation name="GET_ALL">
	<Details>
	<siteName></siteName>
	</Details>
	</operation>
"@
	$ModuleURL = $MEBaseURL + "admin/supportgroup/"
	$Params = @{OPERATION_NAME='GET_ALL';TECHNICIAN_KEY=$MEAPIKey;INPUT_DATA=$SupportGroupXML}
	$SupportGroups = (Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$SupportGroups.operation.Details.Filters.parameter | Foreach {$SupportGroupHash[$_.Name] = $_.Value}

	return $SupportGroupHash
}
#>

function Get-MERequestFilters
{
	$ModuleURL = $MEBaseURL + "request/"
	$Params = @{OPERATION_NAME='GET_REQUEST_FILTERS';TECHNICIAN_KEY=$MEAPIKey}
	[xml]$RequestFilters = (Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$RequestFilters.operation.Details.Filters.parameter | Foreach {$RequestFilterHash[$_.Name] = $_.Value}
	$ModuleURL = ''
	return $ReqFilterHash
}

function Get-MERequests
{
	Param(
	[Parameter(Mandatory=$False)]
	[string]$ReqID,
	[Parameter(Mandatory=$False)]
	[ValidateScript({ Get-MERequestFilters })]
	[string]$RequestFilter = 'All_Requests',
	[Parameter(Mandatory=$False, ParameterSetName='limit')]
	[int]$LowerLimit = 0,
	[Parameter(Mandatory=$False, ParameterSetName='limit')]
	[int]$UpperLimit = 100
	)

	$GetReqsXML = @"
	<Details>
	<parameter>
	<name>from</name>
	<value>$LowerLimit</value>
	</parameter>
	<parameter>
	<name>limit</name>
	<value>$UpperLimit</value>
	</parameter>
	<parameter>
	<name>filterby</name>
	<value>$RequestFilter</value>
	</parameter>
	</Details>
"@

	$ModuleURL = $MEBaseURL + "request/"
	$Params = @{OPERATION_NAME='GET_REQUESTS';TECHNICIAN_KEY=$MEAPIKey;INPUT_DATA=$GetReqsXML}
	(Invoke-WebRequest -Method Post -Uri $ModuleURL -Body $Params).Content
	$ModuleURL = ''

}

function New-METicket
{
	Param(
	[Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$True)]
	[string]$Requester,
	[Parameter(Position=1,Mandatory=$True,ValueFromPipeline=$True)]
	[string]$Subject,
	[Parameter(Position=2,Mandatory=$True,ValueFromPipeline=$True)]
	[string]$Description,
	[Parameter(Position=3,Mandatory=$True,ValueFromPipeline=$True)]
	[string]$Group,
	[Parameter(Position=4,Mandatory=$True,ValueFromPipeline=$True)]
	[string]$Priority,
	[Parameter(Position=5,Mandatory=$True,ValueFromPipeline=$True)]
	[string]$Status,
	[Parameter(Position=6,Mandatory=$True,ValueFromPipeline=$True)]
	[string]$Service
	)

	$NewTicketXML = @"
	<Operation>
	<Details>
	<requester>$Requester</requester>
	<subject>$Subject</subject>
	<description>$Description</description>
	<requesttemplate>Default Request</requesttemplate>
	<group>$Group</group>
	<priority>$Priority</priority>
	<status>$Status</status>
	<service>$Service</service>
	</Details>
	</Operation>
"@
	$ModuleURL = $MEBaseURL + "request/"
	$Params = @{OPERATION_NAME='ADD_REQUEST';TECHNICIAN_KEY=$MEAPIKey;INPUT_DATA=$NewTicketXML}
	(Invoke-RestMethod -Method Post -Uri $ModuleURL -Body $Params).operation.result
	$ModuleURL = ''
}

Get-MECategories
