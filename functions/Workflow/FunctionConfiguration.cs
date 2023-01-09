using Microsoft.Extensions.Configuration;

namespace VideoSearchSolution.Workflow
{
    public class FunctionConfiguration
    {
        public readonly string ManagedIdentityClientId;
        public readonly string StorageAccountName;
        public readonly string StorageContainerName;
        public readonly string VideoIndexerResourceId;
        public readonly string VideoIndexerLocation;
        public readonly string VideoIndexerAccountId;
        public readonly string CognitiveSearchName;
        public readonly string CognitiveSearchIndexName;
        public readonly string CognitiveSearchApiKey;
        public readonly int MonitoringPoolingIntervalSec;
        public readonly int MaximamMonitoringSec;
        public readonly int IndexBatchSize;

        public FunctionConfiguration(IConfiguration config)
        {
            ManagedIdentityClientId = config["MANAGED_IDENTITY_CLIENT_ID"];
            StorageAccountName = config["STORAGE_ACCOUNT_NAME"];
            StorageContainerName = config["STORAGE_CONTAINER_NAME"];
            VideoIndexerResourceId = config["VIDEO_INDEXER_RESOURCEID"];
            VideoIndexerLocation = config["VIDEO_INDEXER_LOCATION"];
            VideoIndexerAccountId = config["VIDEO_INDEXER_ACCOUNTID"];
            CognitiveSearchName = config["COGNITIVE_SEARCH_NAME"];
            CognitiveSearchIndexName = config["COGNITIVE_SEARCH_INDEX_NAME"];
            CognitiveSearchApiKey = config["COGNITIVE_SEARCH_API_KEY"];
            MonitoringPoolingIntervalSec = GetIntConfigurationValue(config, "MONITORING_POOLING_INTERVAL_SEC", 15);
            MaximamMonitoringSec = GetIntConfigurationValue(config, "MAXIMUM_MONITORING_SEC", 60 * 30);
            IndexBatchSize = GetIntConfigurationValue(config, "INDEX_BATCH_SIZE", 1000);
        }

        int GetIntConfigurationValue(IConfiguration config, string key, int defaultValue)
        {
            var str = config[key] ?? "";
            int result;
            if (!int.TryParse(str, out result)) return defaultValue;
            return result;
        }
    }
}
