param appName string
param location string = 'canadacentral'
param skuName string = 'F1'
param workerCount int = 1
param dotnetVersion string = 'v7.0'  // Windows runtime string

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${appName}-plan'
  location: location
  sku: {
    name: skuName
    capacity: workerCount
  }
  properties: {} // no reserved:true → Windows plan
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'app'  // not "app,linux"
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      netFrameworkVersion: dotnetVersion
    }
  }
  dependsOn: [
    appServicePlan
  ]
}

output defaultHostname string = webApp.properties.defaultHostName
