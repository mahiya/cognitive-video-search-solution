//////////////////////////////////////////////////////////////////////
//// Parameters
//////////////////////////////////////////////////////////////////////

param location string = resourceGroup().location
param resourceNamePostfix string = uniqueString(resourceGroup().id)
param storageAccountName string = 'str${resourceNamePostfix}'
param blobContainerName string
param cognitiveSearchIndexName string
param cognitiveSearchName string = 'cogs-${resourceNamePostfix}'
param cognitiveSearchSku string = 'standard'
param mediaServiceName string = 'ams${resourceNamePostfix}'
param videoIndexerName string = 'avam-${resourceNamePostfix}'
param managedIdForMediaServiceName string = 'id-${mediaServiceName}'
param managedIdForVideoIndexerName string = 'id-${videoIndexerName}'
param keyVaultName string = 'kv-${resourceNamePostfix}'
param functionAppName string = 'func-${resourceNamePostfix}'
var functionAppForWorkflowName = '${functionAppName}-workflow'
var functionAppForWebApiName = '${functionAppName}-webapi'
param managedIdForFunctionName string = 'id-${functionAppName}'
param appInsightsName string = 'appi-${resourceNamePostfix}'
param appServicePlanName string = 'plan-${resourceNamePostfix}'
param staticWebAppName string = 'stapp-${resourceNamePostfix}'
param staticWebAppLocation string = 'eastasia'
param staticWebAppSku string = 'Standard'

//////////////////////////////////////////////////////////////////////
//// Modules
//////////////////////////////////////////////////////////////////////

module storage 'modules/storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    storageAccountName: storageAccountName
    blobContainerName: blobContainerName
  }
}

module cognitiveSearch 'modules/cognitive-search.bicep' = {
  name: 'cognitiveSearch'
  params: {
    location: location
    cognitiveSearchName: cognitiveSearchName
    cognitiveSearchSku: cognitiveSearchSku
  }
}

module videoIndexer 'modules/video-indexer.bicep' = {
  name: 'videoIndexer'
  params: {
    storageAccountName: storageAccountName
    location: location
    mediaServiceName: mediaServiceName
    videoIndexerName: videoIndexerName
    managedIdForMediaServiceName: managedIdForMediaServiceName
    managedIdForVideoIndexerName: managedIdForVideoIndexerName
  }
  dependsOn: [ storage ]
}

module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVault'
  params: {
    cognitiveSearchName: cognitiveSearchName
    location: location
    keyVaultName: keyVaultName
    managedIdForFunctionName: managedIdForFunctionName
  }
  dependsOn: [ cognitiveSearch ]
}

module functionApp 'modules/functions.bicep' = {
  name: 'functionApp'
  params: {
    storageAccountName: storageAccountName
    blobContainerName: blobContainerName
    videoIndexerName: videoIndexerName
    cognitiveSearchName: cognitiveSearchName
    cognitiveSearchIndexName: cognitiveSearchIndexName
    keyVaultName: keyVaultName
    cognitiveSearchApiKeySecretName: keyVault.outputs.cognitiveSearchApiKeySecretName
    location: location
    functionAppForWorkflowName: functionAppForWorkflowName
    functionAppForWebApiName: functionAppForWebApiName
    appInsightsName: appInsightsName
    appServicePlanName: appServicePlanName
    managedIdForFunctionName: managedIdForFunctionName
  }
  dependsOn: [ storage, cognitiveSearch, videoIndexer, keyVault ]
}

module staticWebApp 'modules/static-web-apps.bicep' = {
  name: 'staticWebApp'
  params: {
    functionAppName: functionAppForWebApiName
    staticWebAppName: staticWebAppName
    staticWebAppLocation: staticWebAppLocation
    staticWebAppSku: staticWebAppSku
  }
  dependsOn: [ functionApp ]
}

//////////////////////////////////////////////////////////////////////
//// Outputs
//////////////////////////////////////////////////////////////////////

output tenantId string = tenant().tenantId
output storageAccountName string = storageAccountName
output functionAppForWorkflowName string = functionAppForWorkflowName
output functionAppForWebApiName string = functionAppForWebApiName
output staticWebAppName string = staticWebAppName
output staticWebAppHostName string = staticWebApp.outputs.staticWebAppHostName
output cognitiveSearchName string = cognitiveSearchName
output videoIndexerAccountId string = videoIndexer.outputs.videoIndexerAccountId
output videoIndexerLocation string = videoIndexer.outputs.videoIndexerLocation
