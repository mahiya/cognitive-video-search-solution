//////////////////////////////////////////////////////////////////////
//// Parameters
//////////////////////////////////////////////////////////////////////

// Parameters for Existing Resources
param storageAccountName string
param videoIndexerName string

// Parameters for New Resources
param location string = resourceGroup().location
param logicAppName string
param logicAppConnectionName string

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

// Role Definition: Contributor (Video Indexer)
resource roleVideoContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: videoIndexer
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}

//////////////////////////////////////////////////////////////////////
//// Definitions of New Resources
//////////////////////////////////////////////////////////////////////

// Azure Logic Apps
resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
    }
  }
}

// Azure Logic Apps: API Connection - Blob Storage
resource logicAppConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: logicAppConnectionName
  location: location
  properties: {
    api: {
      id: '${subscription().id}/providers/Microsoft.Web/locations/${logicApp.location}/managedApis/azureblob'
    }
    displayName: storageAccount.name
    parameterValues: {
      accountName: storageAccount.name
      accessKey: listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value
    }
  }
}

// Role Assignment: Logic Apps -> Video Indexer (Contributor)
resource assignVideoContributorToFunc 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: videoIndexer
  name: guid(resourceGroup().id, logicApp.name, roleVideoContributor.id)
  properties: {
    roleDefinitionId: roleVideoContributor.id
    principalId: logicApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

//////////////////////////////////////////////////////////////////////
//// Outputs
//////////////////////////////////////////////////////////////////////

output logicAppConnectionId string = logicAppConnection.id
