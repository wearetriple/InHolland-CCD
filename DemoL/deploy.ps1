Add-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName "Azure for Students"

New-AzureRmResourceGroupDeployment -Name ExampleDeployment -ResourceGroupName Triple -TemplateFile "DeploymentTemplate.json" -Mode Complete