param location string = resourceGroup().location
param namePrefix string

var acrName = 'inhccdacr${namePrefix}' // 5–50 chars, lowercase alphanumeric only

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

output name string = containerRegistry.name
output loginServer string = containerRegistry.properties.loginServer
