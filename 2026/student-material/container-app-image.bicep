param location string = resourceGroup().location
param namePrefix string
param imageRepository string = 'api'
param imageTag string = 'latest'
param targetPort int = 8080

var appName = 'inh-ccd-lab2-app-${namePrefix}'
var acrName = 'inhccdlab2acr${namePrefix}'
var storageAccountName = 'inhccdlab2stg${namePrefix}'

var acrPullRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '7f951dda-4cdc-4111-ad74-9497458ca17e'
) // AcrPull

resource registry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acrName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

resource containerApp 'Microsoft.App/containerApps@2024-03-01' existing = {
  name: appName
}

var blobDataReaderRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
) // Storage Blob Data Reader

resource blobDataReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, containerApp.id, 'StorageBlobDataReader')
  scope: storageAccount
  properties: {
    roleDefinitionId: blobDataReaderRoleId
    principalId: containerApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource acrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(registry.id, containerApp.id, 'AcrPull')
  scope: registry
  properties: {
    roleDefinitionId: acrPullRoleId
    principalId: containerApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource containerAppUpdate 'Microsoft.App/containerApps@2024-03-01' = {
  name: appName
  location: location
  tags: resourceGroup().tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: containerApp.properties.managedEnvironmentId
    configuration: {
      ingress: {
        external: true
        targetPort: targetPort
        allowInsecure: false
      }
      registries: [
        {
          server: registry.properties.loginServer
          identity: 'system'
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'api'
          image: '${registry.properties.loginServer}/${imageRepository}:${imageTag}'
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
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 3
      }
    }
  }
  dependsOn: [
    acrPull
    blobDataReader
  ]
}

output fqdn string = containerAppUpdate.properties.configuration.ingress.fqdn
output image string = '${registry.properties.loginServer}/${imageRepository}:${imageTag}'
