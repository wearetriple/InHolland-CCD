param location string = resourceGroup().location
param namePrefix string

var acrName = 'inhccdlab2acr${namePrefix}' // 5–50 chars, lowercase alphanumeric only
var identityName = 'inh-ccd-lab2-id-${namePrefix}'

resource acrPullRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull
  scope: subscription()
}

resource pullIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
  tags: resourceGroup().tags
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  tags: resourceGroup().tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

resource acrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, pullIdentity.id, 'AcrPull')
  scope: containerRegistry
  properties: {
    roleDefinitionId: acrPullRole.id
    principalId: pullIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

output name string = containerRegistry.name
output loginServer string = containerRegistry.properties.loginServer
output pullIdentityId string = pullIdentity.id
