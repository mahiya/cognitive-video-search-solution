//////////////////////////////////////////////////////////////////////
//// Parameters
//////////////////////////////////////////////////////////////////////

// Parameters for Existing Resources
param storageAccountName string
param blobContainerName string
param logicAppName string

// Parameters for New Resources
param location string = resourceGroup().location
param systemTopicName string
param eventSubscriptionName string
param logicAppTriggerName string
param subjectEndsWith string

//////////////////////////////////////////////////////////////////////
//// References to Existing Resources
//////////////////////////////////////////////////////////////////////

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' existing = {
  name: logicAppName
}

//////////////////////////////////////////////////////////////////////
//// Definitions of New Resources
//////////////////////////////////////////////////////////////////////

// EventGrid: Topic
resource systemTopic 'Microsoft.EventGrid/systemTopics@2021-12-01' = {
  name: systemTopicName
  location: location
  properties: {
    source: resourceId('Microsoft.Storage/storageAccounts', storageAccountName)
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}

// EventGrid: Subscription
resource eventSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2021-12-01' = {
  parent: systemTopic
  name: eventSubscriptionName
  properties: {
    destination: {
      endpointType: 'WebHook'
      properties: {
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 64
        endpointUrl: listCallbackUrl('${resourceId('Microsoft.Logic/workflows/', logicApp.name)}/triggers/${logicAppTriggerName}', '2016-06-01').value
      }
    }
    filter: {
      includedEventTypes: [ 'Microsoft.Storage.BlobCreated' ]
      subjectBeginsWith: '/blobServices/default/containers/${blobContainerName}'
      subjectEndsWith: subjectEndsWith
    }
  }
}
