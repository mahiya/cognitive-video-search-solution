using Azure.Messaging.EventGrid;
using Azure.Storage.Sas;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using Microsoft.Azure.WebJobs.Extensions.EventGrid;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Threading.Tasks;
using VideoSearchSolution.Common;

namespace VideoSearchSolution.Workflow
{
    /// <summary>
    /// Azure Storage Blob にアップロードされたビデオファイルを Video Indexer API に送信する関数
    /// </summary>
    class ProcessUploadedData
    {
        readonly VideoIndexerClient _indexerClient;
        readonly BlobSasGenerator _sasGenerator;

        public ProcessUploadedData(BlobSasGenerator sasGenerator, VideoIndexerClient indexerClient)
        {
            _sasGenerator = sasGenerator;
            _indexerClient = indexerClient;
        }

        [FunctionName(nameof(ProcessUploadedData))]
        public async Task RunAsync([EventGridTrigger] EventGridEvent e, [DurableClient] IDurableOrchestrationClient starter, ILogger log)
        {
            // アップロードされた Blob 情報を取得する
            var url = new Uri(JObject.Parse(e.Data.ToString())["url"].ToString());
            var storageAccountName = url.Host.Replace(".blob.core.windows.net", string.Empty);
            var containerName = url.LocalPath.Split("/")[1];
            var blobName = url.LocalPath.Replace($"/{containerName}/", "");

            // Video Indexer API が使用するための Blob の SAS + URL を生成する
            var videoUrl = await _sasGenerator.GetUrlWithSasAsync(blobName, BlobSasPermissions.Read, DateTime.UtcNow.AddMinutes(10));

            // Video Indexer へ文字起こしリクエストを送る
            var videoId = await _indexerClient.UploadVideoAsync(videoUrl);

            // リクエストした文字起こしのURLを入力として、後続のモニタージョブを起動する
            var functionInput = new FunctionInput
            {
                StorageAccountName = storageAccountName,
                ContainerName = containerName,
                BlobName = blobName,
                VideoId = videoId
            };
            await starter.StartNewAsync(nameof(MonitorProcess), input: functionInput);
        }
    }
}