using Azure;
using Azure.Search.Documents.Indexes;
using Azure.Search.Documents.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using VideoSearchSolution.Common;

namespace VideoSearchSolution.Workflow
{
    /// <summary>
    /// Speech Service API での文字起こし結果を Cognitive Search へ登録する関数
    /// </summary>
    class IndexProcessResult
    {
        readonly VideoIndexerClient _indexerClient;
        readonly SearchIndexClient _indexClient;
        readonly string _indexName;
        readonly int _indexBatchSize;

        public IndexProcessResult(FunctionConfiguration config, VideoIndexerClient indexerClient)
        {
            _indexerClient = indexerClient;

            var endpoint = new Uri($"https://{config.CognitiveSearchName}.search.windows.net");
            var credentials = new AzureKeyCredential(config.CognitiveSearchApiKey);
            _indexClient = new SearchIndexClient(endpoint, credentials);
            _indexName = config.CognitiveSearchIndexName;
            _indexBatchSize = config.IndexBatchSize;
        }

        [FunctionName(nameof(IndexProcessResult))]
        public async Task RunAsync([ActivityTrigger] FunctionInput input, ILogger logger)
        {
            // Azure Video Indexer での文字起こし結果を取得する
            var result = await _indexerClient.GetVideoArtifactAsync(input.VideoId);

            // 文字起こし結果をインデックスに格納するフォーマットに変換する
            var phrases = result.RecognizedPhrases.Select((p, i) => new Phrase
            {
                account = input.StorageAccountName,
                container = input.ContainerName,
                blob = input.BlobName,
                videoId = input.VideoId,
                index = i,
                phrase = p.NBest.OrderByDescending(n => n.Confidence).First().Display,
                offset = p.OffsetInTicks / 10000000,
            });

            // Cognitive Search のインデックスに文字起こし結果を登録する
            await IndexDocumentsAsync(phrases);
        }

        /// <summary>
        /// Cognitive Search のインデックスに指定したドキュメントを登録する
        /// </summary>
        async Task IndexDocumentsAsync<T>(IEnumerable<T> docs)
        {
            var chunks = docs.Chunk(_indexBatchSize);
            var searchClient = _indexClient.GetSearchClient(_indexName);
            foreach (var (chunk, i) in chunks.Select((c, i) => (c, i)))
            {
                var batch = IndexDocumentsBatch.Create(chunk.Select(phrase => IndexDocumentsAction.Upload(phrase)).ToArray());
                await searchClient.IndexDocumentsAsync(batch);
            }
        }
    }
}
