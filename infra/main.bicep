param appName string
param location string = 'canadacentral'   // matches your manual plan
param skuName string = 'F1'              // Free plan
param workerCount int = 1
param dotnetVersion string = 'DOTNETCORE|7.0' // safer for free tier
param enableStagingSlot bool = false     // staging not supported in F1

// App Service Plan (Free Tier)
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${appName}-plan'
  location: location
  sku: {
    name: skuName
    capacity: workerCount
  }
  properties: {
    reserved: true // Linux
  }
}

// Application Insights (Free version still available)
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${appName}-ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

// Web App
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
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
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

// No staging slot here because F1 doesn’t support it

output defaultHostname string = webApp.properties.defaultHostName
output instrumentationKey string = appInsights.properties.InstrumentationKey
output principalId string = webApp.identity.principalId
