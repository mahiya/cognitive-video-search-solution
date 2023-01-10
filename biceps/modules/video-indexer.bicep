//////////////////////////////////////////////////////////////////////
//// Parameters
//////////////////////////////////////////////////////////////////////

// Parameters for Existing Resources
param storageAccountName string

// Parameters for New Resources
param location string = resourceGroup().location
param mediaServiceName string
param videoIndexerName string
param managedIdForMediaServiceName string = mediaServiceName
param managedIdForVideoIndexerName string = videoIndexerName

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

// Role Definition: Reader
resource roleStorageReader 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: storageAccount
  name: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}

// Role Definition: Contributor
resource roleMediaContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: mediaService
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}

//////////////////////////////////////////////////////////////////////
//// Definitions of New Resources
//////////////////////////////////////////////////////////////////////

// User Assigned Identity: Media Service
resource idMedia 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdForMediaServiceName
  location: location
}

// Role Assignment: Managed Id (Media Service) -> Storage: Storage Blob Data Contributor
resource assignBlobContributorToMedia 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(resourceGroup().id, idMedia.id, roleBlobContributor.id)
  properties: {
    roleDefinitionId: roleBlobContributor.id
    principalId: idMedia.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Role Assignment: Managed Id (Media Service) -> Storage: Reader
resource assignStorageReaderToMedia 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
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
resource idVideo 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdForVideoIndexerName
  location: location
}

// Role Assignment: Managed Id (Video Indexer) -> Media Service: Contributor
resource assignMediaContributorToVideo 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
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
  dependsOn: [ assignMediaContributorToVideo ]
}

//////////////////////////////////////////////////////////////////////
//// Outputs
//////////////////////////////////////////////////////////////////////

output videoIndexerAccountId string = videoIndexer.properties.accountId
output videoIndexerLocation string = videoIndexer.location
