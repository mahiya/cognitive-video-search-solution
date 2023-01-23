using Microsoft.Extensions.Configuration;

namespace VideoSearchSolution
{
    public class FunctionConfiguration
    {
        public readonly string ManagedIdentityClientId;
        public readonly string StorageAccountName;
        public readonly string StorageContainerName;
        public readonly string VideoIndexerResourceId;
        public readonly string VideoIndexerLocation;
        public readonly string VideoIndexerAccountId;

        public FunctionConfiguration(IConfiguration config)
        {
            ManagedIdentityClientId = config["MANAGED_IDENTITY_CLIENT_ID"];
            StorageAccountName = config["STORAGE_ACCOUNT_NAME"];
            StorageContainerName = config["STORAGE_CONTAINER_NAME"];
            VideoIndexerResourceId = config["VIDEO_INDEXER_RESOURCEID"];
            VideoIndexerLocation = config["VIDEO_INDEXER_LOCATION"];
            VideoIndexerAccountId = config["VIDEO_INDEXER_ACCOUNTID"];
        }
    }
}
