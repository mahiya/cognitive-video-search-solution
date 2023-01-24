//////////////////////////////////////////////////////////////////////
//// Parameters
//////////////////////////////////////////////////////////////////////

// Parameters for New Resources
param location string = resourceGroup().location
param cognitiveServiceName string
param cognitiveServiceNameSku string = 'S0'

//////////////////////////////////////////////////////////////////////
//// References to Existing Resources
//////////////////////////////////////////////////////////////////////

// Cognitive Service
resource cognitiveService 'Microsoft.CognitiveServices/accounts@2021-10-01' = {
  name: cognitiveServiceName
  location: location
  sku: {
    name: cognitiveServiceNameSku
  }
  kind: 'CognitiveServices'
  properties: {}
}
