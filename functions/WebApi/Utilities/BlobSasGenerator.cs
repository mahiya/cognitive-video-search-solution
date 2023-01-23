using Azure.Storage.Blobs;
using Azure.Storage.Sas;
using System;
using System.Threading.Tasks;

namespace VideoSearchSolution
{
    public class BlobSasGenerator
    {
        readonly BlobServiceClient _blobServiceClient;
        readonly string _containerName;

        public BlobSasGenerator(BlobServiceClient blobServiceClient, string containerName)
        {
            _blobServiceClient = blobServiceClient;
            _containerName = containerName;
        }

        public async Task<bool> BlobExistsAsync(string blobName)
        {
            var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);
            var blobClient = containerClient.GetBlobClient(blobName);
            return await blobClient.ExistsAsync();
        }

        public async Task<string> GetUrlWithSasAsync(string blobName, BlobSasPermissions permission, DateTime expiresOn)
        {
            var delegationKey = (await _blobServiceClient.GetUserDelegationKeyAsync(DateTime.UtcNow, expiresOn)).Value;
            var builder = new BlobSasBuilder
            {
                BlobContainerName = _containerName,
                BlobName = blobName,
                Resource = "b",
                StartsOn = DateTime.UtcNow,
                ExpiresOn = expiresOn,
            };
            builder.SetPermissions(permission);
            var sasToken = builder.ToSasQueryParameters(delegationKey, _blobServiceClient.AccountName);
            var urlWithSas = $"{_blobServiceClient.Uri}{_containerName}/{blobName}?{sasToken}";
            return urlWithSas;
        }
    }
}
