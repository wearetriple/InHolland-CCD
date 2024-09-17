param prefix string
param serviceTag string
param environment string
param regionTag string

param tags object = {}
param location string = resourceGroup().location

param appInsightsRetention int = 30

param numberOfWorkers int = 1

var resourcePrefix = '${prefix}-${serviceTag}-${environment}-${regionTag}'
var appInsightsName = '${resourcePrefix}-AI-1'
var storageAccountName = replace(toLower('${resourcePrefix}-SA-1'), '-', '')
var functionAppName = '${resourcePrefix}-FA-1'
var serverFarmName = '${resourcePrefix}-ASP-1'

// Storage account

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  kind: 'StorageV2'
  location: location
  tags: tags
  name: storageAccountName
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
  }
}

// App insights

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  kind: 'web'
  location: location
  tags: tags
  name: appInsightsName
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
    RetentionInDays: appInsightsRetention
  }
}

// App service plan

resource serverFarm 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: serverFarmName
  location: location
  tags: tags
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}

// Function app

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'functionapp'
  properties: {
    enabled: true
    serverFarmId: resourceId('Microsoft.Web/serverfarms', serverFarm.name)
    siteConfig: {
      autoHealEnabled: true
      autoHealRules: {
        triggers: {
          privateBytesInKB: 0
          statusCodes: [
            {
              status: 500
              subStatus: 0
              win32Status: 0
              count: 25
              timeInterval: '00:05:00'
            }
          ]
        }
        actions: {
          actionType: 'Recycle'
          minProcessExecutionTime: '00:01:00'
        }
      }
      numberOfWorkers: numberOfWorkers
    }
    clientAffinityEnabled: false
    httpsOnly: true
    containerSize: 1536
    redundancyMode: 'None'
  }

  resource functionAppConfig 'config@2021-03-01' = {
    name: 'appsettings'
    properties: {
      // function app settings
      'AzureWebJobsStorage': 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccount.name), '2021-08-01').keys[0].value};EndpointSuffix=core.windows.net'
      'FUNCTIONS_EXTENSION_VERSION': '~4'
      'FUNCTIONS_WORKER_RUNTIME': 'dotnet'
      'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING': 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccount.name), '2019-04-01').keys[0].value};EndpointSuffix=core.windows.net'
      'WEBSITE_CONTENTSHARE': replace(toLower(functionApp.name), '-', '')
      // ai settings
      'APPINSIGHTS_INSTRUMENTATIONKEY': reference('Microsoft.Insights/components/${appInsights.name}', '2015-05-01').InstrumentationKey
      'ApplicationInsightsAgent_EXTENSION_VERSION': '~2'
      'InstrumentationEngine_EXTENSION_VERSION': '~1'
    }
  }
}
