param sqlServerName string
param sqlDbName string
param location string = resourceGroup().location
param administratorLogin string = 'sqladminuser'
@secure()
param administratorLoginPassword string
param skuName string = 'Free' // change to 'Basic' if Free not supported in region

resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  name: '${sqlServerName}/${sqlDbName}'
  location: location
  sku: {
    name: skuName
    tier: 'Free'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
  dependsOn: [
    sqlServer
  ]
}

resource allowAzureFirewall 'Microsoft.Sql/servers/firewallRules@2022-02-01-preview' = {
  name: '${sqlServerName}/AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
  dependsOn: [
    sqlServer
  ]
}

output sqlServerFullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
output sqlDatabaseName string = sqlDatabase.name
