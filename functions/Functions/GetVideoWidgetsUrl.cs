using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using System.Threading.Tasks;

namespace VideoSearchSolution
{
    /// <summary>
    /// Azure Video Indexer ビデオファイルにアクセスするためのトークンを発行する Web API
    /// </summary>
    class GetVideoWidgetsUrl
    {
        readonly VideoIndexerClient _indexerClient;
        readonly string _videoIndexerAccountId;
        readonly string _videoIndexerLocation;

        public GetVideoWidgetsUrl(VideoIndexerClient indexerClient, FunctionConfiguration config)
        {
            _indexerClient = indexerClient;
            _videoIndexerAccountId = config.VideoIndexerAccountId;
            _videoIndexerLocation = config.VideoIndexerLocation;
        }

        [FunctionName(nameof(GetVideoWidgetsUrl))]
        public async Task<IActionResult> RunAsync(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "videos/{videoId}/widgets")] HttpRequest req,
            string videoId)
        {
            // 指定したビデオIDのアクセストークンを発行する
            var videoAccessToken = await _indexerClient.GenerateVideoAccessTokenAsync(videoId);

            // ビデオと分析ウィジットのURLを返す
            return new OkObjectResult(new
            {
                videoWidgetsUrl = $"https://www.videoindexer.ai/embed/player/{_videoIndexerAccountId}/{videoId}/?accessToken={videoAccessToken}&locale=ja&location={_videoIndexerLocation}&autoplay=true",
                insightsWidgetsUrl = $"https://www.videoindexer.ai/embed/insights/{_videoIndexerAccountId}/{videoId}/?accessToken={videoAccessToken}&locale=ja&location={_videoIndexerLocation}&tab=timeline"
            });
        }
    }
}
