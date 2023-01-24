//////////////////////////////////////////////////////////////////////
//// Parameters
//////////////////////////////////////////////////////////////////////

// Parameters for New Resources
param location string = resourceGroup().location
param storageAccountName string
param blobContainerNames array

//////////////////////////////////////////////////////////////////////
//// Definitions of New Resources
//////////////////////////////////////////////////////////////////////

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
resource storageBlobContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = [for blobContainerName in blobContainerNames: {
  name: blobContainerName
  parent: storageBlob
}]
