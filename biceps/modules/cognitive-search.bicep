//////////////////////////////////////////////////////////////////////
//// Parameters
//////////////////////////////////////////////////////////////////////

// Parameters for New Resources
param location string = resourceGroup().location
param cognitiveSearchName string
param cognitiveSearchSku string

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
