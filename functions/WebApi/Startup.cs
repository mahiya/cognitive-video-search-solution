using Azure.Identity;
using Azure.Storage.Blobs;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System;
using VideoSearchSolution.Common;

[assembly: FunctionsStartup(typeof(VideoSearchSolution.WebApi.Startup))]

namespace VideoSearchSolution.WebApi
{
    class Startup : FunctionsStartup
    {
        public IConfiguration Configuration { get; }

        public Startup()
        {
            var config = new ConfigurationBuilder()
                .AddEnvironmentVariables()
                .AddJsonFile("local.settings.json", true);
            Configuration = config.Build();
        }

        public override void Configure(IFunctionsHostBuilder builder)
        {
            var configuration = new FunctionConfiguration(Configuration);

            var options = new DefaultAzureCredentialOptions();
            if (!string.IsNullOrEmpty(configuration.ManagedIdentityClientId))
                options.ManagedIdentityClientId = configuration.ManagedIdentityClientId;
            var credential = new DefaultAzureCredential(options);

            // BlobSasGenerator
            builder.Services.AddSingleton(provider =>
            {
                var serviceUri = new Uri($"https://{configuration.StorageAccountName}.blob.core.windows.net");
                var blobServiceClient = new BlobServiceClient(serviceUri, credential);
                var blobSasGenerator = new BlobSasGenerator(blobServiceClient, configuration.StorageContainerName);
                return blobSasGenerator;
            });

            // VideoIndexerClient
            builder.Services.AddSingleton(provider =>
            {
                var videoIndexerSettings = new VideoIndexerClientSettings
                {
                    Credential = credential,
                    VideoIndexerAccountId = configuration.VideoIndexerAccountId,
                    VideoIndexerLocation = configuration.VideoIndexerLocation,
                    VideoIndexerResourceId = configuration.VideoIndexerResourceId
                };
                var videoIndexerClient = new VideoIndexerClient(videoIndexerSettings);
                return videoIndexerClient;
            });

            // Configuration
            builder.Services.AddSingleton(provider => configuration);
        }
    }
}
