//////////////////////////////////////////////////////////////////////
//// Parameters
//////////////////////////////////////////////////////////////////////

// Parameters for Existing Resources
param storageAccountName string

// Parameters for New Resources
param location string = resourceGroup().location
param cognitiveSearchName string
param cognitiveSearchSku string

//////////////////////////////////////////////////////////////////////
//// References to Existing Resources
//////////////////////////////////////////////////////////////////////

// Azure Storage
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

// Role Definition: Storage Blob Data Contributor
resource roleBlobContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: storageAccount
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

//////////////////////////////////////////////////////////////////////
//// Definitions of New Resources
//////////////////////////////////////////////////////////////////////

// Cognitive Search Service
resource cognitiveSearch 'Microsoft.Search/searchServices@2020-08-01' = {
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

// Role Assignment: Function App -> Storage (Storage Blob Data Contributor)
resource assignBlobContributorToFunction 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(resourceGroup().id, cognitiveSearch.name, roleBlobContributor.id)
  properties: {
    roleDefinitionId: roleBlobContributor.id
    principalId: cognitiveSearch.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
