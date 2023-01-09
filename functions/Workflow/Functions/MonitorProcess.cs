using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Threading.Tasks;
using VideoSearchSolution.Common;

namespace VideoSearchSolution.Workflow
{
    /// <summary>
    /// Video Indexer での文字起こし処理が完了するまで待機するための関数
    /// </summary>
    class MonitorProcess
    {
        readonly VideoIndexerClient _indexerClient;
        readonly int _pollingIntervalSec;
        readonly int _maximamMonitoringSec;

        public MonitorProcess(FunctionConfiguration config, VideoIndexerClient indexerClient)
        {
            _indexerClient = indexerClient;
            _pollingIntervalSec = config.MonitoringPoolingIntervalSec;
            _maximamMonitoringSec = config.MaximamMonitoringSec;
        }

        [FunctionName(nameof(MonitorProcess))]
        public async Task RunAsync([OrchestrationTrigger] IDurableOrchestrationContext context, ILogger logger)
        {
            // 関数への入力を取得する
            var input = context.GetInput<FunctionInput>();

            // 監視期限を設定する
            var expiryTime = context.CurrentUtcDateTime.AddSeconds(_maximamMonitoringSec);

            while (context.CurrentUtcDateTime < expiryTime)
            {
                // 監視対象の処理が完了しているかを確認する
                var completed = CheckProcessIsCompleted(input.VideoId, logger);
                if (completed)
                {
                    await context.CallActivityAsync(nameof(IndexProcessResult), input);
                    break;
                }

                // 監視対象の処理が完了していない場合、一定時間待機後に再度チェック処理を行う
                var nextCheck = context.CurrentUtcDateTime.AddSeconds(_pollingIntervalSec);
                await context.CreateTimer(nextCheck, CancellationToken.None);
            }

            // 監視の期限切れ
            logger.LogInformation("Monitor expired.");
        }

        /// <summary>
        /// 監視するプロセスが完了しているかを確認する (trueを返した場合、プロセスが完了している)
        /// </summary>
        bool CheckProcessIsCompleted(string videoId, ILogger logger)
        {
            // Video Indexer API を呼び出して、文字起こし処理が完了しているかを確認する
            var videoIndex = _indexerClient.GetVideoIndexAsync(videoId).Result;
            if (videoIndex.State == "Processed")
                return true;
            if (videoIndex.State == "Failed" || videoIndex.State == "Quarantined")
                throw new Exception($"Video processing state is {videoIndex.State}");
            return false;
        }
    }
}
