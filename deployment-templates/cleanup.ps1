param (
    [Parameter(Mandatory=$true)]
	$resourceGroup
)

Write-Host "Removing resourceGroup: $resourceGroup"

az deployment group create --mode Complete --resource-group $resourceGroup --template-file template-cleanup.json
