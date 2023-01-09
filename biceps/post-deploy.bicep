param location string = resourceGroup().location
param storageAccountName string
param blobContainerName string
param functionAppName string
param functionName string
param resourceNamePostfix string = uniqueString(resourceGroup().id)
param systemTopicName string = 'evgt-${resourceNamePostfix}'
param eventSubscriptionName string = 'evgs-${resourceNamePostfix}'
param subjectEndsWith string = '.mp4'

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
      endpointType: 'AzureFunction'
      properties: {
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 64
        resourceId: resourceId('Microsoft.Web/sites/functions', functionAppName, functionName)
      }
    }
    filter: {
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
      ]
      subjectBeginsWith: '/blobServices/default/containers/${blobContainerName}'
      subjectEndsWith: subjectEndsWith
    }
  }
}
