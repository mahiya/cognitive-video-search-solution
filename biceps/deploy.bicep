//////////////////////////////////////////////////////////////////////
//// Parameters
//////////////////////////////////////////////////////////////////////

param location string = resourceGroup().location
param resourceNamePostfix string = uniqueString(resourceGroup().id)
param storageAccountName string = 'str${resourceNamePostfix}'
param uploadedBlobContainerName string
param analyzedBlobContainerName string
param cognitiveSearchName string = 'cogs-${resourceNamePostfix}'
param cognitiveSearchSku string = 'standard'
param cognitiveServiceName string = 'cog-${resourceNamePostfix}'
param mediaServiceName string = 'ams${resourceNamePostfix}'
param videoIndexerName string = 'avam-${resourceNamePostfix}'
param managedIdForMediaServiceName string = 'id-${mediaServiceName}'
param managedIdForVideoIndexerName string = 'id-${videoIndexerName}'
param functionAppName string = 'func-${resourceNamePostfix}'
param appInsightsName string = 'appi-${resourceNamePostfix}'
param appServicePlanName string = 'plan-${resourceNamePostfix}'
param staticWebAppName string = 'stapp-${resourceNamePostfix}'
param staticWebAppLocation string = 'eastasia'
param staticWebAppSku string = 'Standard'
param logicAppName string = 'logic-${resourceNamePostfix}'
param logicAppConnectionName string = 'logic-conn-${resourceNamePostfix}'

//////////////////////////////////////////////////////////////////////
//// Modules
//////////////////////////////////////////////////////////////////////

module storage 'modules/storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    storageAccountName: storageAccountName
    blobContainerNames: [ uploadedBlobContainerName, analyzedBlobContainerName ]
  }
}

module cognitiveSearch 'modules/cognitive-search.bicep' = {
  name: 'cognitiveSearch'
  params: {
    storageAccountName: storageAccountName
    location: location
    cognitiveSearchName: cognitiveSearchName
    cognitiveSearchSku: cognitiveSearchSku
  }
  dependsOn: [ storage ]
}

module cognitiveService 'modules/cognitive-service.bicep' = {
  name: 'cognitiveService'
  params: {
    location: location
    cognitiveServiceName: cognitiveServiceName
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

module functionApp 'modules/functions.bicep' = {
  name: 'functionApp'
  params: {
    storageAccountName: storageAccountName
    blobContainerName: uploadedBlobContainerName
    videoIndexerName: videoIndexerName
    location: location
    appInsightsName: appInsightsName
    appServicePlanName: appServicePlanName
    functionAppName: functionAppName
  }
  dependsOn: [ storage, videoIndexer ]
}

module staticWebApp 'modules/static-webapps.bicep' = {
  name: 'staticWebApp'
  params: {
    functionAppName: functionAppName
    staticWebAppName: staticWebAppName
    staticWebAppLocation: staticWebAppLocation
    staticWebAppSku: staticWebAppSku
  }
  dependsOn: [ functionApp ]
}

module logicApp 'modules/logicapps.bicep' = {
  name: 'logicApp'
  params: {
    storageAccountName: storageAccountName
    videoIndexerName: videoIndexerName
    location: location
    logicAppName: logicAppName
    logicAppConnectionName: logicAppConnectionName
  }
  dependsOn: [ storage, videoIndexer ]
}

//////////////////////////////////////////////////////////////////////
//// Outputs
//////////////////////////////////////////////////////////////////////

output tenantId string = tenant().tenantId
output subscriptionId string = subscription().subscriptionId
output storageAccountName string = storageAccountName
output functionAppName string = functionAppName
output staticWebAppName string = staticWebAppName
output staticWebAppHostName string = staticWebApp.outputs.staticWebAppHostName
output cognitiveSearchName string = cognitiveSearchName
output cognitiveServiceName string = cognitiveServiceName
output videoIndexerResourceId string = videoIndexer.outputs.videoIndexerResourceId
output videoIndexerAccountId string = videoIndexer.outputs.videoIndexerAccountId
output videoIndexerLocation string = videoIndexer.outputs.videoIndexerLocation
output logicAppName string = logicAppName
output logicAppConnectionId string = logicApp.outputs.logicAppConnectionId
