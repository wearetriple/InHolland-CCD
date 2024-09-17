$ErrorActionPreference = "Stop"

$prefix = 'inholland-h-'

$randIdFile = ".randId"
if (Test-Path $randIdFile) 
{
  $randId = Get-Content $randIdFile -Raw 
} else {
  $randId = Get-Random -Minimum 1000 -Maximum 9999
  $randId | Out-File $randIdFile
}

$resource_group_name = $prefix + $randId + '-rsgp'
$base_resources_name = $prefix + $randId

Write-Host "Creating artifact..."

# Create zip of files
$artifact = "artifact.zip"
if (Test-Path $artifact) 
{
  Remove-Item $artifact
}

Compress-Archive -Path * -DestinationPath $artifact

Write-Host "Creating resources in $resource_group_name"

# Create a new resource-group
az group create -l westeurope -n $resource_group_name

# Deploy resources inside resource-group
az deployment group create --mode Incremental --resource-group $resource_group_name --template-file deployment-templates\template.json --parameters name=$base_resources_name

Write-Host "Deploying artifact"

az webapp config appsettings set --resource-group $resource_group_name --name ($prefix + $randId + '-app') --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true
az webapp deploy --resource-group $resource_group_name --name ($prefix + $randId + '-app') --src-path $artifact

Write-Host "https://" + ($prefix + $randId + '-app') + ".azurewebsites.net/"