param location string = resourceGroup().location

var prefix = 'ccd2024'
var servicePlanName = '${prefix}sp'
var serverFarmName = '${prefix}sf'
var webApplicationName = '${prefix}wa'
var functionAppName = '${prefix}fa'
var storageAccountName = '${prefix}sta'
var dbServerName = '${prefix}dbs'
var dbName = '${prefix}db'
var cosmosDbAccountName = '${prefix}cda'
var cosmosDbDatabaseName = '${prefix}cdb'
var cosmosDbContainer = '${prefix}cdc'

resource servicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: servicePlanName
  location: location
  tags: resourceGroup().tags
  sku: {
    name: 'B1'
    size: 'B1'
  }
  properties: {
    perSiteScaling: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
}

resource webApplication 'Microsoft.Web/sites@2022-03-01' = {
  name: webApplicationName
  location: location
  tags: resourceGroup().tags
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: [
    servicePlan
  ]
  properties: {
    enabled: true
    serverFarmId: resourceId('Microsoft.Web/serverfarms', servicePlanName)
    reserved: false
    isXenon: false
    hyperV: false
    siteConfig: {
      use32BitWorkerProcess: false
      minTlsVersion: '1.2'
      netFrameworkVersion: 'v8.0'
      alwaysOn: true
      webSocketsEnabled: true
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: true
    clientCertEnabled: false
    hostNamesDisabled: false
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
  }
}

resource serverFarm 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: serverFarmName
  location: location
  tags: resourceGroup().tags
  sku: {
    tier: 'Consumption'
    name: 'Y1'
  }
  kind: 'elastic'
}

var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: location
  tags: resourceGroup().tags
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'functionapp'
  properties: {
    enabled: true
    serverFarmId: serverFarm.id
    siteConfig: {
      netFrameworkVersion: 'v8.0'
      minTlsVersion: '1.2'
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
      scmIpSecurityRestrictionsUseMain: false
      scmMinTlsVersion: '1.2'
      loadBalancing: 'PerSiteRoundRobin'
      http20Enabled: true
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
        FUNCTIONS_EXTENSION_VERSION: '~4'
        FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'
        WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED: '1'
        AzureWebJobsStorage: storageAccountConnectionString
        WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: storageAccountConnectionString
        WEBSITE_CONTENTSHARE: toLower(functionAppName)
      }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: resourceGroup().tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    accessTier: 'Hot'
    publicNetworkAccess: 'Enabled'
  }
}

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: dbServerName
  location: location
  tags: resourceGroup().tags
  properties: {
    administratorLogin: uniqueString(dbServerName, subscription().subscriptionId)
    administratorLoginPassword: guid(dbName, subscription().subscriptionId) // never do this -- this is only valid for creating demo resources that are deleted after they have been created
    minimalTlsVersion: '1.2'
    restrictOutboundNetworkAccess: 'Enabled'
  }

  resource sqlDB 'databases' = {
    name: dbName
    location: location
    sku: {
      name: 'S1'
      tier: 'Standard'
      capacity: 20
    }
  }

  resource tripleOfficeFirewallRule 'firewallRules' = {
    name: 'tripleOfficeFirewallRule'
    properties: {
      startIpAddress: '37.203.216.8'
      endIpAddress: '37.203.216.8'
    }
  }
  
  resource azureResourcesFirewallRule 'firewallRules' = {
    name: 'azureResourcesFirewallRule'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '0.0.0.0'
    }
  }
}

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: cosmosDbAccountName
  location: location
  tags: resourceGroup().tags
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    enableMultipleWriteLocations: true
    disableLocalAuth: false
    locations: [{
      locationName: location
      failoverPriority: 0
    }]
    capacity: {
      totalThroughputLimit: 401
    }
    minimalTlsVersion: 'Tls12'
  }

  resource cosmosDatabase 'sqlDatabases' = {
    name: cosmosDbDatabaseName
    properties: {
      resource: {
        id: cosmosDbDatabaseName
      }
      options: {
        throughput: 400
      }
    }

    resource container 'containers' = {
      name: cosmosDbContainer
      properties: {
        resource: {
          id: cosmosDbContainer
          defaultTtl: -1
          partitionKey: {
            kind: 'Hash'
            paths: [
              '/_partitionKey'
            ]
            version: 1
          }
        }
      }
    }
  }
}
