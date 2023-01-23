using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using System.Linq;
using System.Threading.Tasks;

namespace VideoSearchSolution
{
    class ListVideos
    {
        readonly VideoIndexerClient _videoIndexerClient;

        public ListVideos(VideoIndexerClient videoIndexerClient)
        {
            _videoIndexerClient = videoIndexerClient;
        }

        [FunctionName(nameof(ListVideos))]
        public async Task<IActionResult> RunAsync(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "videos")] HttpRequest req)
        {
            var videos = await _videoIndexerClient.ListVideosAsync();
            return new OkObjectResult(videos.Select(v => new
            {
                v.Id,
                v.Name,
                v.State,
                v.ProcessingProgress,
                v.Created,
                v.DurationInSeconds,
            }));
        }
    }
}
