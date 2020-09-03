$prefix = 'inholland-h-'
$suffix = '-' + (Get-Random -Minimum 1000 -Maximum 9999)

$resource_group_name = $prefix + 'rsgp' + $suffix
$appserviceplan_name = $prefix + 'fasp' + $suffix
$azure_function_name = $prefix + 'func' + $suffix
$storageaccount_name = $prefix + 'stor' + $suffix
# Storage account names cannot contain a dash
$storageaccount_name = $storageaccount_name -replace '-', ''

Write-Host "Deploying resources in $resource_group_name"

# Create a new resource-group
az group create -l westeurope -n $resource_group_name

# Deploy resources inside resource-group
az deployment group create --mode Incremental --resource-group $resource_group_name --template-file template-azure-function.json --parameters appService_name=$azure_function_name appServicePlan_name=$appserviceplan_name resourceGroup=$resource_group_name storageaccount_name=$storageaccount_name

#az deployment group create --resource-group tri-inholland --template-file azure-function.json --parameters @azure-function.env.parameters.json

