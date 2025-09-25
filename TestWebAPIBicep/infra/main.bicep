param location string = resourceGroup().location
param appName string
param sqlServerName string
param sqlDbName string
@secure()
param sqlAdminPassword string

// Deploy App Service
module appservice './modules/appservice.bicep' = {
  name: 'appserviceDeploy'
  params: {
    appName: appName
    location: location
  }
}

// Deploy SQL Database
module sql './modules/sql.bicep' = {
  name: 'sqlDeploy'
  params: {
    sqlServerName: sqlServerName
    sqlDbName: sqlDbName
    location: location
    administratorLoginPassword: sqlAdminPassword
  }
}

output appServiceUrl string = appservice.outputs.defaultHostname
output sqlServerFQDN string = sql.outputs.sqlServerFullyQualifiedDomainName
