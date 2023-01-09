param location string = resourceGroup().location
param resourceNamePostfix string = uniqueString(resourceGroup().id)
param storageAccountName string = 'str${resourceNamePostfix}'
param blobContainerName string
param mediaServiceName string = 'ams${resourceNamePostfix}'
param videoIndexerName string = 'avam-${resourceNamePostfix}'
param cognitiveSearchIndexName string
param cognitiveSearchName string = 'cogs-${resourceNamePostfix}'
param cognitiveSearchSku string = 'basic'
param keyVaultName string = 'kv-${resourceNamePostfix}'
param functionAppName string = 'func-${resourceNamePostfix}'
param appInsightsName string = 'appi-${resourceNamePostfix}'
param appServicePlanName string = 'plan-${resourceNamePostfix}'
param staticWebAppName string = 'stapp-${resourceNamePostfix}'
param staticWebAppLocation string = 'eastasia'
param staticWebAppSku string = 'Standard'

// Azure Storage
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// Azure Storage Blob Settings
resource storageBlob 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    cors: {
      corsRules: [
        {
          allowedHeaders: [
            '*'
          ]
          allowedMethods: [
            'PUT'
          ]
          allowedOrigins: [
            '*'
          ]
          exposedHeaders: [
            '*'
          ]
          maxAgeInSeconds: 3600
        }
      ]
    }
  }
}

// Azure Storage: Blob Container
resource storageBlobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: blobContainerName
  parent: storageBlob
}

// User Assigned Identity: Media Service
resource idMedia 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'id-ams-${resourceNamePostfix}'
  location: location
}

// Role Definition: Storage Blob Data Contributor
resource roleBlobContributor 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: storageAccount
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

// Role Assignment: Managed Id (Media Service) -> Storage: Storage Blob Data Contributor
resource assignBlobContributorToMedia 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: storageAccount
  name: guid(resourceGroup().id, idMedia.id, roleBlobContributor.id)
  properties: {
    roleDefinitionId: roleBlobContributor.id
    principalId: idMedia.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Role Definition: Reader
resource roleStorageReader 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: storageAccount
  name: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}

// Role Assignment: Managed Id (Media Service) -> Storage: Reader
resource assignStorageReaderToMedia 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: storageAccount
  name: guid(resourceGroup().id, idMedia.id, roleStorageReader.id)
  properties: {
    roleDefinitionId: roleStorageReader.id
    principalId: idMedia.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Azure Media Services
resource mediaService 'Microsoft.Media/mediaservices@2021-11-01' = {
  name: mediaServiceName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${idMedia.id}': {}
    }
  }
  properties: {
    storageAccounts: [
      {
        id: storageAccount.id
        type: 'Primary'
        identity: {
          userAssignedIdentity: idMedia.id
          useSystemAssignedIdentity: false
        }
      }
    ]
    storageAuthentication: 'ManagedIdentity'
  }
}

// User Assigned Identity: Video Indexer
resource idVideo 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'id-avam-${resourceNamePostfix}'
  location: location
}

// Role Definition: Contributor
resource roleMediaContributor 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: mediaService
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}

// Role Assignment: Managed Id (Video Indexer) -> Media Service: Contributor
resource assignMediaContributorToVideo 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: mediaService
  name: guid(resourceGroup().id, idVideo.id, roleMediaContributor.id)
  properties: {
    roleDefinitionId: roleMediaContributor.id
    principalId: idVideo.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Azure Video Indexer
resource videoIndexer 'Microsoft.VideoIndexer/accounts@2022-08-01' = {
  name: videoIndexerName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${idVideo.id}': {}
    }
  }
  properties: {
    mediaServices: {
      resourceId: mediaService.id
      userAssignedIdentity: idVideo.id
    }
  }
}

// Cognitive Search Service
resource cognitiveSearch 'Microsoft.Search/searchServices@2021-04-01-preview' = {
  name: cognitiveSearchName
  location: location
  sku: {
    name: cognitiveSearchSku
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hostingMode: 'default'
    publicNetworkAccess: 'enabled'
    partitionCount: 1
    replicaCount: 1
  }
}

// User Assigned Identity -> Functions
resource idFunc 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'id-func-${resourceNamePostfix}'
  location: location
}

// Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    publicNetworkAccess: 'Enabled'
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: [
      {
        tenantId: idFunc.properties.tenantId
        objectId: idFunc.properties.principalId
        permissions: {
          secrets: [
            'Get'
          ]
        }
      }
    ]
    tenantId: tenant().tenantId
  }
}

// Key Vault - Secret : Cognitive Search Admin API Key
resource secretCognitiveSearchApiKey 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'cognitive-search-api-key'
  parent: keyVault
  properties: {
    value: listAdminKeys(cognitiveSearch.id, cognitiveSearch.apiVersion).primaryKey
  }
}

// Azure Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
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

// Azure Function App (Workflow)
var functionExtentionVersion = '~4'
var functionsWorkerRuntime = 'dotnet'
resource functionAppWorkflow 'Microsoft.Web/sites@2022-03-01' = {
  name: '${functionAppName}-workflow'
  location: location
  kind: 'functionapp'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${idFunc.id}': {}
    }
  }
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlan.id
    clientAffinityEnabled: true
    keyVaultReferenceIdentity: idFunc.id
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
          name: 'MANAGED_IDENTITY_CLIENT_ID'
          value: idFunc.properties.clientId
        }
        {
          name: 'STORAGE_ACCOUNT_NAME'
          value: storageAccount.name
        }
        {
          name: 'STORAGE_CONTAINER_NAME'
          value: storageBlobContainer.name
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
        {
          name: 'COGNITIVE_SEARCH_NAME'
          value: cognitiveSearch.name
        }
        {
          name: 'COGNITIVE_SEARCH_INDEX_NAME'
          value: cognitiveSearchIndexName
        }
        {
          name: 'COGNITIVE_SEARCH_API_KEY'
          value: '@Microsoft.KeyVault(SecretUri=${secretCognitiveSearchApiKey.properties.secretUriWithVersion})'
        }
      ]
    }
  }
}

// Azure Function App (Web API)
resource functionAppWebApi 'Microsoft.Web/sites@2022-03-01' = {
  name: '${functionAppName}-webapi'
  location: location
  kind: 'functionapp'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${idFunc.id}': {}
    }
  }
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlan.id
    clientAffinityEnabled: true
    keyVaultReferenceIdentity: idFunc.id
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
          name: 'MANAGED_IDENTITY_CLIENT_ID'
          value: idFunc.properties.clientId
        }
        {
          name: 'STORAGE_ACCOUNT_NAME'
          value: storageAccount.name
        }
        {
          name: 'STORAGE_CONTAINER_NAME'
          value: storageBlobContainer.name
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
        {
          name: 'COGNITIVE_SEARCH_NAME'
          value: cognitiveSearch.name
        }
        {
          name: 'COGNITIVE_SEARCH_INDEX_NAME'
          value: cognitiveSearchIndexName
        }
        {
          name: 'COGNITIVE_SEARCH_API_KEY'
          value: '@Microsoft.KeyVault(SecretUri=${secretCognitiveSearchApiKey.properties.secretUriWithVersion})'
        }
      ]
    }
  }
}

// Role Assignment: Function App -> Storage (Storage Blob Data Contributor)
resource assignBlobContributorToFunction 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: storageAccount
  name: guid(resourceGroup().id, functionAppName, roleBlobContributor.id)
  properties: {
    roleDefinitionId: roleBlobContributor.id
    principalId: idFunc.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Role Definition: Contributor (Video Indexer)
resource roleVideoContributor 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: videoIndexer
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}

// Role Assignment: Function App -> Video Indexer (Contributor)
resource assignVideoContributorToFunc 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: videoIndexer
  name: guid(resourceGroup().id, functionAppName, roleVideoContributor.id)
  properties: {
    roleDefinitionId: roleVideoContributor.id
    principalId: idFunc.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

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
    functionAppRegion: functionAppWebApi.location
    functionAppResourceId: functionAppWebApi.id
  }
}

// Output:
output tenantId string = tenant().tenantId
output storageAccountName string = storageAccount.name
output functionAppForWorkflowName string = functionAppWorkflow.name
output functionAppForWebApiName string = functionAppWebApi.name
output staticWebAppName string = staticWebApp.name
output staticWebAppHostName string = staticWebApp.properties.defaultHostname
output cognitiveSearchName string = cognitiveSearch.name
output videoIndexerAccountId string = videoIndexer.properties.accountId
output videoIndexerLocation string = videoIndexer.location
