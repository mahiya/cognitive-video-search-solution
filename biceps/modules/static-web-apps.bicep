//////////////////////////////////////////////////////////////////////
//// Parameters
//////////////////////////////////////////////////////////////////////

// Parameters for Existing Resources
param functionAppName string

// Parameters for New Resources
param staticWebAppName string
param staticWebAppLocation string
param staticWebAppSku string

//////////////////////////////////////////////////////////////////////
//// References to Existing Resources
//////////////////////////////////////////////////////////////////////

resource functionApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: functionAppName
}

//////////////////////////////////////////////////////////////////////
//// Definitions of New Resources
//////////////////////////////////////////////////////////////////////

// Azure Static Web Apps
resource staticWebApp 'Microsoft.Web/staticSites@2022-03-01' = {
  name: staticWebAppName
  location: staticWebAppLocation
  sku: {
    name: staticWebAppSku
    tier: staticWebAppSku
  }
  properties: {
    provider: 'SwaCli'
    allowConfigFileUpdates: true
    stagingEnvironmentPolicy: 'Enabled'
    enterpriseGradeCdnStatus: 'Disabled'
  }
}

// Azure Static Web Apps: Bring Your Own Functions
resource userProvidedFunctionApps 'Microsoft.Web/staticSites/userProvidedFunctionApps@2022-03-01' = {
  name: '${staticWebApp.name}_backend'
  parent: staticWebApp
  properties: {
    functionAppRegion: functionApp.location
    functionAppResourceId: functionApp.id
  }
}

//////////////////////////////////////////////////////////////////////
//// Outputs
//////////////////////////////////////////////////////////////////////

output staticWebAppHostName string = staticWebApp.properties.defaultHostname
