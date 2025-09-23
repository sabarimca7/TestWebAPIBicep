param appName string
param location string = resourceGroup().location
param skuName string = 'P1v2'           // change as needed
param workerCount int = 1
param dotnetVersion string = 'DOTNETCORE|8.0' // check runtime string in Azure if needed
param enableStagingSlot bool = true

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${appName}-plan'
  location: location
  sku: {
    name: skuName
    capacity: workerCount
  }
  properties: {
    reserved: true
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${appName}-ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: dotnetVersion
        appSettings: [
          {
            name: 'ASPNETCORE_ENVIRONMENT'
            value: 'Production'
          },
          {
            name: 'WEBSITE_RUN_FROM_PACKAGE'
            value: '1'
          },
          {
            name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
            value: appInsights.properties.InstrumentationKey
          }
        ]
    }
  }
  dependsOn: [
    appServicePlan
    appInsights
  ]
}

resource stagingSlot 'Microsoft.Web/sites/slots@2022-03-01' = if (enableStagingSlot) {
  name: '${appName}/staging'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
  dependsOn: [
    webApp
  ]
}

output defaultHostname string = webApp.properties.defaultHostName
output instrumentationKey string = appInsights.properties.InstrumentationKey
output principalId string = webApp.identity.principalId
