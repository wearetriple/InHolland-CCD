param location string = resourceGroup().location
param namePrefix string

var environmentName = 'inh-ccd-lab2-env-${namePrefix}'
var appName = 'inh-ccd-lab2-app-${namePrefix}'
var logAnalyticsName = 'inh-ccd-lab2-law-${namePrefix}'
var storageAccountName = 'inhccdlab2stg${namePrefix}' // 3–24 chars, lowercase alphanumeric only

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  tags: resourceGroup().tags
  properties: {
    sku: { name: 'PerGB2018' }
  }
}

resource managedEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: environmentName
  location: location
  tags: resourceGroup().tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: appName
  location: location
  tags: resourceGroup().tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: managedEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
        allowInsecure: false
      }
    }
    template: {
      containers: [
        {
          name: 'api'
          image: 'mcr.microsoft.com/k8se/quickstart:latest'
          env: [
            {
              name: 'STORAGE_ACCOUNT_NAME'
              value: storageAccountName
            }
            {
              name: 'BLOB_CONTAINER_NAME'
              value: 'images'
            }
          ]
          resources: {
            cpu: any('0.5')
            memory: '1.0Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 2
      }
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
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

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

resource imagesContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'images'
  properties: {
    publicAccess: 'None'
  }
}

var blobDataReaderRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
) // Storage Blob Data Reader (includes user-delegation SAS)

resource blobDataReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, containerApp.id, 'StorageBlobDataReader')
  scope: storageAccount
  properties: {
    roleDefinitionId: blobDataReaderRoleId
    principalId: containerApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
output storageAccountName string = storageAccount.name
