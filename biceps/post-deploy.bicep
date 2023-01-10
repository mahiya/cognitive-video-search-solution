//////////////////////////////////////////////////////////////////////
//// Parameters
//////////////////////////////////////////////////////////////////////

param location string = resourceGroup().location
param storageAccountName string
param blobContainerName string
param functionAppName string
param functionName string
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
    functionAppName: functionAppName
    functionName: functionName
    location: location
    systemTopicName: systemTopicName
    eventSubscriptionName: eventSubscriptionName
    subjectEndsWith: subjectEndsWith
  }
}
