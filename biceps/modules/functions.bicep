//////////////////////////////////////////////////////////////////////
//// Parameters
//////////////////////////////////////////////////////////////////////

// Parameters for Existing Resources
param storageAccountName string
param blobContainerName string
param videoIndexerName string

// Parameters for New Resources
param location string = resourceGroup().location
param functionAppName string
param appInsightsName string
param appServicePlanName string

//////////////////////////////////////////////////////////////////////
//// References to Existing Resources
//////////////////////////////////////////////////////////////////////

// Azure Storage
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

// Azure Video Indexer
resource videoIndexer 'Microsoft.VideoIndexer/accounts@2022-08-01' existing = {
  name: videoIndexerName
}

// Role Definition: Storage Blob Data Contributor
resource roleBlobContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: storageAccount
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

// Role Definition: Contributor (Video Indexer)
resource roleVideoContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: videoIndexer
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}

//////////////////////////////////////////////////////////////////////
//// Definitions of New Resources
//////////////////////////////////////////////////////////////////////

// Azure Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  tags: {
    // circular dependency means we can't reference functionApp directly  /subscriptions/<subscriptionId>/resourceGroups/<rg-name>/providers/Microsoft.Web/sites/<appName>"
    'hidden-link:/subscriptions/${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/sites/${functionAppName}': 'Resource'
  }
}

// Azure App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2020-10-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

// Azure Function App (Web API)
var functionExtentionVersion = '~4'
var functionsWorkerRuntime = 'dotnet'
resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlan.id
    clientAffinityEnabled: true
    siteConfig: {
      cors: {
        allowedOrigins: [
          '*' // Set host name of web site will be embedded the web chat
        ]
      }
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: functionExtentionVersion
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionsWorkerRuntime
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'STORAGE_ACCOUNT_NAME'
          value: storageAccount.name
        }
        {
          name: 'STORAGE_CONTAINER_NAME'
          value: blobContainerName
        }
        {
          name: 'VIDEO_INDEXER_RESOURCEID'
          value: videoIndexer.id
        }
        {
          name: 'VIDEO_INDEXER_LOCATION'
          value: videoIndexer.location
        }
        {
          name: 'VIDEO_INDEXER_ACCOUNTID'
          value: videoIndexer.properties.accountId
        }
      ]
    }
  }
}

// Role Assignment: Function App -> Storage (Storage Blob Data Contributor)
resource assignBlobContributorToFunction 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(resourceGroup().id, functionApp.name, roleBlobContributor.id)
  properties: {
    roleDefinitionId: roleBlobContributor.id
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Role Assignment: Function App -> Video Indexer (Contributor)
resource assignVideoContributorToFunc 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: videoIndexer
  name: guid(resourceGroup().id, functionApp.name, roleVideoContributor.id)
  properties: {
    roleDefinitionId: roleVideoContributor.id
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
