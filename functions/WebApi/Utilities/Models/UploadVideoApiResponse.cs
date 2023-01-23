using Newtonsoft.Json;
using System;

namespace VideoSearchSolution
{
    public class UploadVideoApiResponse
    {
#nullable disable warnings
        [JsonProperty("accountId")]
        public string AccountId { get; set; }

        [JsonProperty("id")]
        public string Id { get; set; }

        [JsonProperty("partition")]
        public string Partition { get; set; }

        [JsonProperty("externalId")]
        public object ExternalId { get; set; }

        [JsonProperty("metadata")]
        public object Metadata { get; set; }

        [JsonProperty("name")]
        public string Name { get; set; }

        [JsonProperty("description")]
        public string Description { get; set; }

        [JsonProperty("created")]
        public DateTime Created { get; set; }

        [JsonProperty("lastModified")]
        public DateTime LastModified { get; set; }

        [JsonProperty("lastIndexed")]
        public DateTime LastIndexed { get; set; }

        [JsonProperty("privacyMode")]
        public string PrivacyMode { get; set; }

        [JsonProperty("userName")]
        public string UserName { get; set; }

        [JsonProperty("isOwned")]
        public bool IsOwned { get; set; }

        [JsonProperty("isBase")]
        public bool IsBase { get; set; }

        [JsonProperty("hasSourceVideoFile")]
        public bool HasSourceVideoFile { get; set; }

        [JsonProperty("state")]
        public string State { get; set; }

        [JsonProperty("moderationState")]
        public string ModerationState { get; set; }

        [JsonProperty("reviewState")]
        public string ReviewState { get; set; }

        [JsonProperty("processingProgress")]
        public string ProcessingProgress { get; set; }

        [JsonProperty("durationInSeconds")]
        public int DurationInSeconds { get; set; }

        [JsonProperty("thumbnailVideoId")]
        public string ThumbnailVideoId { get; set; }

        [JsonProperty("thumbnailId")]
        public string ThumbnailId { get; set; }

        [JsonProperty("searchMatches")]
        public object[] SearchMatches { get; set; }

        [JsonProperty("indexingPreset")]
        public string IndexingPreset { get; set; }

        [JsonProperty("streamingPreset")]
        public string StreamingPreset { get; set; }

        [JsonProperty("sourceLanguage")]
        public string SourceLanguage { get; set; }

        [JsonProperty("sourceLanguages")]
        public string[] SourceLanguages { get; set; }

        [JsonProperty("personModelId")]
        public string PersonModelId { get; set; }
    }
}