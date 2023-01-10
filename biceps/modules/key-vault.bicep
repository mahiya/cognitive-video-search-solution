//////////////////////////////////////////////////////////////////////
//// Parameters
//////////////////////////////////////////////////////////////////////

// Parameters for Existing Resources
param cognitiveSearchName string

// Parameters for New Resources
param location string = resourceGroup().location
param keyVaultName string
param managedIdForFunctionName string
param cognitiveSearchApiKeySecretName string = 'cognitive-search-api-key'

//////////////////////////////////////////////////////////////////////
//// References to Existing Resources
//////////////////////////////////////////////////////////////////////

// Cognitive Search Service
resource cognitiveSearch 'Microsoft.Search/searchServices@2020-08-01' existing = {
  name: cognitiveSearchName
}

//////////////////////////////////////////////////////////////////////
//// Definitions of New Resources
//////////////////////////////////////////////////////////////////////

// User Assigned Identity -> Functions
resource idFunc 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdForFunctionName
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
  name: cognitiveSearchApiKeySecretName
  parent: keyVault
  properties: {
    value: listAdminKeys(cognitiveSearch.id, cognitiveSearch.apiVersion).primaryKey
  }
}

//////////////////////////////////////////////////////////////////////
//// Outputs
//////////////////////////////////////////////////////////////////////

output cognitiveSearchApiKeySecretName string = cognitiveSearchApiKeySecretName
