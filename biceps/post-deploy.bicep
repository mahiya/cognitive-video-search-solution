//////////////////////////////////////////////////////////////////////
//// Parameters
//////////////////////////////////////////////////////////////////////

// Parameters for Existing Resources
param storageAccountName string
param blobContainerName string
param logicAppName string
param logicAppTriggerName string

// Parameters for New Resources
param location string = resourceGroup().location
param resourceNamePostfix string = uniqueString(resourceGroup().id)
param systemTopicName string = 'evgt-${resourceNamePostfix}'
param eventSubscriptionName string = 'evgs-${resourceNamePostfix}'
param subjectEndsWith string = '.mp4'

//////////////////////////////////////////////////////////////////////
//// Modules
//////////////////////////////////////////////////////////////////////

module eventGrid 'modules/event-grid.bicep' = {
  name: 'eventGrid'
  params: {
    storageAccountName: storageAccountName
    blobContainerName: blobContainerName
    logicAppName: logicAppName
    logicAppTriggerName: logicAppTriggerName
    location: location
    systemTopicName: systemTopicName
    eventSubscriptionName: eventSubscriptionName
    subjectEndsWith: subjectEndsWith
  }
}
