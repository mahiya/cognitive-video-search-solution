using Newtonsoft.Json;
using System;

namespace VideoSearchSolution
{
    public class VideoIndex
    {
#nullable disable warnings
        [JsonProperty("partition")]
        public string Partition { get; set; }

        [JsonProperty("description")]
        public string Description { get; set; }

        [JsonProperty("privacyMode")]
        public string PrivacyMode { get; set; }

        [JsonProperty("state")]
        public string State { get; set; }

        [JsonProperty("accountId")]
        public string AccountId { get; set; }

        [JsonProperty("id")]
        public string Id { get; set; }

        [JsonProperty("name")]
        public string Name { get; set; }

        [JsonProperty("userName")]
        public string UserName { get; set; }

        [JsonProperty("created")]
        public DateTime Created { get; set; }

        [JsonProperty("isOwned")]
        public bool IsOwned { get; set; }

        [JsonProperty("isEditable")]
        public bool IsEditable { get; set; }

        [JsonProperty("isBase")]
        public bool IsBase { get; set; }

        [JsonProperty("durationInSeconds")]
        public int DurationInSeconds { get; set; }

        [JsonProperty("duration")]
        public string Duration { get; set; }

        [JsonProperty("summarizedInsights")]
        public SummarizedInsights SummarizedInsightsValue { get; set; }

        [JsonProperty("videos")]
        public Video[] Videos { get; set; }

        [JsonProperty("videosRanges")]
        public VideosRange[] VideosRanges { get; set; }

        public class SummarizedInsights
        {
            [JsonProperty("name")]
            public string Name { get; set; }

            [JsonProperty("id")]
            public string Id { get; set; }

            [JsonProperty("privacyMode")]
            public string PrivacyMode { get; set; }

            [JsonProperty("duration")]
            public Duration DurationValue { get; set; }

            [JsonProperty("thumbnailVideoId")]
            public string ThumbnailVideoOd { get; set; }

            [JsonProperty("thumbnailId")]
            public string ThumbnailOd { get; set; }

            [JsonProperty("faces")]
            public Face[] Faces { get; set; }

            [JsonProperty("keywords")]
            public object[] Keywords { get; set; }

            [JsonProperty("sentiments")]
            public Sentiment[] Sentiments { get; set; }

            [JsonProperty("emotions")]
            public object[] Emotions { get; set; }

            [JsonProperty("audioEffects")]
            public AudioEffect[] AudioEffects { get; set; }

            [JsonProperty("labels")]
            public Label[] Labels { get; set; }

            [JsonProperty("framePatterns")]
            public object[] FramePatterns { get; set; }

            [JsonProperty("brands")]
            public object[] Brands { get; set; }

            [JsonProperty("namedLocations")]
            public object[] NamedLocations { get; set; }

            [JsonProperty("namedPeople")]
            public NamedPeople[] NamedPeopleValue { get; set; }

            [JsonProperty("statistics")]
            public Statistics StatisticsValue { get; set; }

            [JsonProperty("topics")]
            public Topic[] Topics { get; set; }


            public class Duration
            {
                [JsonProperty("time")]
                public string Time { get; set; }

                [JsonProperty("seconds")]
                public int Seconds { get; set; }
            }

            public class Face
            {
                [JsonProperty("videoId")]
                public string VideoId { get; set; }

                [JsonProperty("confidence")]
                public int Confidence { get; set; }

                [JsonProperty("description")]
                public object Description { get; set; }

                [JsonProperty("title")]
                public object Title { get; set; }

                [JsonProperty("thumbnailId")]
                public string ThumbnailId { get; set; }

                [JsonProperty("seenDuration")]
                public float SeenDuration { get; set; }

                [JsonProperty("seenDurationRatio")]
                public float SeenDurationRatio { get; set; }

                [JsonProperty("id")]
                public int Id { get; set; }

                [JsonProperty("name")]
                public string Name { get; set; }

                [JsonProperty("appearances")]
                public Appearance[] Appearances { get; set; }

                public class Appearance
                {
                    [JsonProperty("startTime")]
                    public string StartTime { get; set; }

                    [JsonProperty("endTime")]
                    public string EndTime { get; set; }

                    [JsonProperty("startSeconds")]
                    public float StartSeconds { get; set; }

                    [JsonProperty("endSeconds")]
                    public int EndSeconds { get; set; }
                }
            }

            public class Sentiment
            {
                [JsonProperty("sentimentKey")]
                public string SentimentKey { get; set; }

                [JsonProperty("seenDurationRatio")]
                public float SeenDurationRatio { get; set; }

                [JsonProperty("appearances")]
                public Appearance[] Appearances { get; set; }

                public class Appearance
                {
                    [JsonProperty("startTime")]
                    public string StartTime { get; set; }

                    [JsonProperty("endTime")]
                    public string EndTime { get; set; }

                    [JsonProperty("startSeconds")]
                    public int StartSeconds { get; set; }

                    [JsonProperty("endSeconds")]
                    public int EndSeconds { get; set; }
                }
            }

            public class AudioEffect
            {
                [JsonProperty("audioEffectKey")]
                public string AudioEffectKey { get; set; }

                [JsonProperty("seenDurationRatio")]
                public float SeenDurationRatio { get; set; }

                [JsonProperty("seenDuration")]
                public int SeenDuration { get; set; }

                [JsonProperty("appearances")]
                public Appearance[] Appearances { get; set; }

                public class Appearance
                {
                    [JsonProperty("confidence")]
                    public int Confidence { get; set; }

                    [JsonProperty("startTime")]
                    public string StartTime { get; set; }

                    [JsonProperty("endTime")]
                    public string EndTime { get; set; }

                    [JsonProperty("startSeconds")]
                    public int StartSeconds { get; set; }

                    [JsonProperty("endSeconds")]
                    public int EndSeconds { get; set; }
                }
            }

            public class Label
            {
                [JsonProperty("id")]
                public int Id { get; set; }

                [JsonProperty("name")]
                public string Name { get; set; }

                [JsonProperty("appearances")]
                public Appearance[] Appearances { get; set; }

                public class Appearance
                {
                    [JsonProperty("confidence")]
                    public float Confidence { get; set; }

                    [JsonProperty("startTime")]
                    public string StartTime { get; set; }

                    [JsonProperty("endTime")]
                    public string EndTime { get; set; }

                    [JsonProperty("startSeconds")]
                    public float StartSeconds { get; set; }

                    [JsonProperty("endSeconds")]
                    public float EndSeconds { get; set; }
                }
            }

            public class NamedPeople
            {
                [JsonProperty("referenceId")]
                public string ReferenceId { get; set; }

                [JsonProperty("referenceUrl")]
                public string ReferenceUrl { get; set; }

                [JsonProperty("confidence")]
                public float Confidence { get; set; }

                [JsonProperty("description")]
                public object Description { get; set; }

                [JsonProperty("seenDuration")]
                public float Seenduration { get; set; }

                [JsonProperty("id")]
                public int Id { get; set; }

                [JsonProperty("name")]
                public string Name { get; set; }

                [JsonProperty("appearances")]
                public Appearance[] Appearances { get; set; }

                public class Appearance
                {
                    [JsonProperty("startTime")]
                    public string StartTime { get; set; }

                    [JsonProperty("endTime")]
                    public string EndTime { get; set; }

                    [JsonProperty("startSeconds")]
                    public float StartSeconds { get; set; }

                    [JsonProperty("endSeconds")]
                    public float EndSeconds { get; set; }
                }

            }

            public class Statistics
            {
                [JsonProperty("correspondenceCount")]
                public int CorrespondenceCount { get; set; }

                [JsonProperty("speakerTalkToListenRatio")]
                public SpeakerTalkTolLstenRatio SpeakerTalkTolLstenRatioValue { get; set; }

                [JsonProperty("speakerLongestMonolog")]
                public SpeakerLongestMonolog SpeakerLongestMonologValue { get; set; }

                [JsonProperty("speakerNumberOfFragments")]
                public SpeakerNumberOfFragments SpeakerNumberOfFragmentsValue { get; set; }

                [JsonProperty("speakerWordCount")]
                public SpeakerWordCount SpeakerWordCountValue { get; set; }

                public class SpeakerTalkTolLstenRatio
                {
                    [JsonProperty("_1")]
                    public int _1 { get; set; }
                }

                public class SpeakerLongestMonolog
                {
                    [JsonProperty("_1")]
                    public int _1 { get; set; }
                }

                public class SpeakerNumberOfFragments
                {
                    [JsonProperty("_1")]
                    public int _1 { get; set; }
                }

                public class SpeakerWordCount
                {
                    [JsonProperty("_1")]
                    public int _1 { get; set; }
                }
            }

            public class Topic
            {
                [JsonProperty("referenceUrl")]
                public object ReferenceIrl { get; set; }

                [JsonProperty("iptcName")]
                public object IptcName { get; set; }

                [JsonProperty("iabName")]
                public string IabName { get; set; }

                [JsonProperty("confidence")]
                public float Confidence { get; set; }

                [JsonProperty("id")]
                public int Id { get; set; }

                [JsonProperty("name")]
                public string Name { get; set; }

                [JsonProperty("appearances")]
                public Appearance[] Appearances { get; set; }

                public class Appearance
                {
                    [JsonProperty("startTime")]
                    public string StartTime { get; set; }

                    [JsonProperty("endTime")]
                    public string EndTime { get; set; }

                    [JsonProperty("startSeconds")]
                    public int StartSeconds { get; set; }

                    [JsonProperty("endSeconds")]
                    public int EndSeconds { get; set; }
                }

            }
        }

        public class Video
        {
            [JsonProperty("accountId")]
            public string AccountId { get; set; }

            [JsonProperty("id")]
            public string Id { get; set; }

            [JsonProperty("state")]
            public string State { get; set; }

            [JsonProperty("moderationState")]
            public string ModerationState { get; set; }

            [JsonProperty("reviewState")]
            public string ReviewState { get; set; }

            [JsonProperty("privacyMode")]
            public string PrivacyMode { get; set; }

            [JsonProperty("processingProgress")]
            public string ProcessingProgress { get; set; }

            [JsonProperty("failureCode")]
            public string FailureCode { get; set; }

            [JsonProperty("failureMessage")]
            public string FailureMessage { get; set; }

            [JsonProperty("externalId")]
            public object ExternalId { get; set; }

            [JsonProperty("externalUrl")]
            public object ExternalUrl { get; set; }

            [JsonProperty("metadata")]
            public object Metadata { get; set; }

            [JsonProperty("insights")]
            public Insights InsightsValue { get; set; }

            [JsonProperty("thumbnailId")]
            public string ThumbnailId { get; set; }

            [JsonProperty("width")]
            public int Width { get; set; }

            [JsonProperty("height")]
            public int Height { get; set; }

            [JsonProperty("detectSourceLanguage")]
            public bool DetectSourceLanguage { get; set; }

            [JsonProperty("languageAutoDetectMode")]
            public string LanguageAutoDetectMode { get; set; }

            [JsonProperty("sourceLanguage")]
            public string SourceLanguage { get; set; }

            [JsonProperty("sourceLanguages")]
            public string[] SourceLanguages { get; set; }

            [JsonProperty("language")]
            public string Language { get; set; }

            [JsonProperty("languages")]
            public string[] Languages { get; set; }

            [JsonProperty("indexingPreset")]
            public string IndexingPreset { get; set; }

            [JsonProperty("linguisticModelId")]
            public string LinguisticModelId { get; set; }

            [JsonProperty("personModelId")]
            public string PersonModelOd { get; set; }

            [JsonProperty("isAdult")]
            public bool IsAdult { get; set; }

            [JsonProperty("publishedUrl")]
            public string PublishedUrl { get; set; }

            [JsonProperty("publishedProxyUrl")]
            public object PublishedProxyUrl { get; set; }

            [JsonProperty("viewToken")]
            public string ViewToken { get; set; }

            public class Insights
            {
                [JsonProperty("version")]
                public string Version { get; set; }

                [JsonProperty("duration")]
                public string Duration { get; set; }

                [JsonProperty("sourceLanguage")]
                public string Sourcelanguage { get; set; }

                [JsonProperty("sourceLanguages")]
                public string[] Sourcelanguages { get; set; }

                [JsonProperty("language")]
                public string Language { get; set; }

                [JsonProperty("languages")]
                public string[] Languages { get; set; }

                [JsonProperty("transcript")]
                public Transcript[] Transcripts { get; set; }

                [JsonProperty("ocr")]
                public Ocr[] Ocrs { get; set; }

                [JsonProperty("topics")]
                public Topic[] Topics { get; set; }

                [JsonProperty("faces")]
                public Face[] Faces { get; set; }

                [JsonProperty("labels")]
                public Label[] Labels { get; set; }

                [JsonProperty("scenes")]
                public Scene[] Scenes { get; set; }

                [JsonProperty("shots")]
                public Shot[] Shots { get; set; }

                [JsonProperty("namedPeople")]
                public NamedPeople[] NamedPeopleValue { get; set; }

                [JsonProperty("audioEffects")]
                public AudioEffect[] AudioEffects { get; set; }

                [JsonProperty("sentiments")]
                public Sentiment[] Sentiments { get; set; }

                [JsonProperty("blocks")]
                public Block[] Blocks { get; set; }

                [JsonProperty("speakers")]
                public Speaker[] Speakers { get; set; }

                [JsonProperty("textualContentModeration")]
                public TextualContentModeration TextualContentModerationValue { get; set; }

                [JsonProperty("statistics")]
                public Statistics StatisticsValue { get; set; }



                public class Transcript
                {
                    [JsonProperty("id")]
                    public int Id { get; set; }

                    [JsonProperty("text")]
                    public string Text { get; set; }

                    [JsonProperty("confidence")]
                    public float Confidence { get; set; }

                    [JsonProperty("speakerId")]
                    public int SpeakerId { get; set; }

                    [JsonProperty("language")]
                    public string Language { get; set; }

                    [JsonProperty("instances")]
                    public Instance[] Instances { get; set; }

                    public class Instance
                    {
                        [JsonProperty("adjustedStart")]
                        public string AdjustedStart { get; set; }

                        [JsonProperty("adjustedEnd")]
                        public string AdjustedEnd { get; set; }

                        [JsonProperty("start")]
                        public string Start { get; set; }

                        [JsonProperty("end")]
                        public string End { get; set; }
                    }
                }

                public class Ocr
                {
                    [JsonProperty("id")]
                    public int Id { get; set; }

                    [JsonProperty("text")]
                    public string Text { get; set; }

                    [JsonProperty("confidence")]
                    public float Confidence { get; set; }

                    [JsonProperty("left")]
                    public int Left { get; set; }

                    [JsonProperty("top")]
                    public int Top { get; set; }

                    [JsonProperty("width")]
                    public int Width { get; set; }

                    [JsonProperty("height")]
                    public int Height { get; set; }

                    [JsonProperty("angle")]
                    public int Angle { get; set; }

                    [JsonProperty("language")]
                    public string Language { get; set; }

                    [JsonProperty("instances")]
                    public Instance[] Instances { get; set; }

                    public class Instance
                    {
                        [JsonProperty("adjustedStart")]
                        public string AdjustedStart { get; set; }

                        [JsonProperty("adjustedEnd")]
                        public string AdjustedEnd { get; set; }

                        [JsonProperty("start")]
                        public string Start { get; set; }

                        [JsonProperty("end")]
                        public string End { get; set; }
                    }
                }

                public class Topic
                {
                    [JsonProperty("id")]
                    public int Id { get; set; }

                    [JsonProperty("name")]
                    public string Name { get; set; }

                    [JsonProperty("referenceId")]
                    public string ReferenceId { get; set; }

                    [JsonProperty("fullName")]
                    public string FullName { get; set; }

                    [JsonProperty("referenceType")]
                    public string ReferenceType { get; set; }

                    [JsonProperty("confidence")]
                    public float Confidence { get; set; }

                    [JsonProperty("iabName")]
                    public string IabName { get; set; }

                    [JsonProperty("language")]
                    public string Language { get; set; }

                    [JsonProperty("instances")]
                    public Instance[] Instances { get; set; }

                    public class Instance
                    {
                        [JsonProperty("adjustedStart")]
                        public string AdjustedStart { get; set; }

                        [JsonProperty("adjustedEnd")]
                        public string AdjustedEnd { get; set; }

                        [JsonProperty("start")]
                        public string Start { get; set; }

                        [JsonProperty("end")]
                        public string End { get; set; }
                    }
                }

                public class Face
                {
                    [JsonProperty("id")]
                    public int Id { get; set; }

                    [JsonProperty("name")]
                    public string Name { get; set; }

                    [JsonProperty("confidence")]
                    public int Confidence { get; set; }

                    [JsonProperty("description")]
                    public object Description { get; set; }

                    [JsonProperty("thumbnailId")]
                    public string ThumbnailId { get; set; }

                    [JsonProperty("title")]
                    public object Title { get; set; }

                    [JsonProperty("imageUrl")]
                    public object ImageUrl { get; set; }

                    [JsonProperty("thumbnails")]
                    public Thumbnail[] Thumbnails { get; set; }

                    [JsonProperty("instances")]
                    public Instance[] Instances { get; set; }

                    public class Thumbnail
                    {
                        [JsonProperty("id")]
                        public string Id { get; set; }

                        [JsonProperty("fileName")]
                        public string Filename { get; set; }

                        [JsonProperty("instances")]
                        public Instance[] Instances { get; set; }

                        public class Instance
                        {
                            [JsonProperty("adjustedStart")]
                            public string AdjustedStart { get; set; }

                            [JsonProperty("adjustedEnd")]
                            public string AdjustedEnd { get; set; }

                            [JsonProperty("start")]
                            public string Start { get; set; }

                            [JsonProperty("end")]
                            public string End { get; set; }
                        }
                    }

                    public class Instance
                    {
                        [JsonProperty("thumbnailsIds")]
                        public string[] ThumbnailsIds { get; set; }

                        [JsonProperty("adjustedStart")]
                        public string AdjustedStart { get; set; }

                        [JsonProperty("adjustedEnd")]
                        public string AdjustedEnd { get; set; }

                        [JsonProperty("start")]
                        public string Start { get; set; }

                        [JsonProperty("end")]
                        public string End { get; set; }
                    }
                }

                public class Label
                {
                    [JsonProperty("id")]
                    public int Id { get; set; }

                    [JsonProperty("name")]
                    public string Name { get; set; }

                    [JsonProperty("referenceId")]
                    public string ReferenceId { get; set; }

                    [JsonProperty("language")]
                    public string Language { get; set; }

                    [JsonProperty("instances")]
                    public Instance[] Instances { get; set; }

                    public class Instance
                    {
                        [JsonProperty("confidence")]
                        public float Confidence { get; set; }

                        [JsonProperty("adjustedStart")]
                        public string AdjustedStart { get; set; }

                        [JsonProperty("adjustedEnd")]
                        public string AdjustedEnd { get; set; }

                        [JsonProperty("start")]
                        public string Start { get; set; }

                        [JsonProperty("end")]
                        public string End { get; set; }
                    }
                }

                public class Scene
                {
                    [JsonProperty("id")]
                    public int Id { get; set; }

                    [JsonProperty("instances")]
                    public Instance[] Instances { get; set; }

                    public class Instance
                    {
                        [JsonProperty("adjustedStart")]
                        public string AdjustedStart { get; set; }

                        [JsonProperty("adjustedEnd")]
                        public string AdjustedEnd { get; set; }

                        [JsonProperty("start")]
                        public string Start { get; set; }

                        [JsonProperty("end")]
                        public string End { get; set; }
                    }
                }

                public class Shot
                {
                    [JsonProperty("id")]
                    public int Id { get; set; }

                    [JsonProperty("tags")]
                    public string[] Tags { get; set; }

                    [JsonProperty("keyFrames")]
                    public Keyframe[] KeyFrames { get; set; }

                    [JsonProperty("instances")]
                    public Instance[] Instances { get; set; }

                    public class Keyframe
                    {
                        [JsonProperty("id")]
                        public int Id { get; set; }

                        [JsonProperty("instances")]
                        public Instance[] Instances { get; set; }

                        public class Instance
                        {
                            [JsonProperty("thumbnailId")]
                            public string ThumbnailId { get; set; }

                            [JsonProperty("adjustedStart")]
                            public string AdjustedStart { get; set; }

                            [JsonProperty("adjustedEnd")]
                            public string AdjustedEnd { get; set; }

                            [JsonProperty("start")]
                            public string Start { get; set; }

                            [JsonProperty("end")]
                            public string End { get; set; }
                        }
                    }

                    public class Instance
                    {
                        [JsonProperty("adjustedStart")]
                        public string AdjustedStart { get; set; }

                        [JsonProperty("adjustedEnd")]
                        public string AdjustedEnd { get; set; }

                        [JsonProperty("start")]
                        public string Start { get; set; }

                        [JsonProperty("end")]
                        public string End { get; set; }
                    }
                }

                public class NamedPeople
                {
                    [JsonProperty("id")]
                    public int Id { get; set; }

                    [JsonProperty("name")]
                    public string Name { get; set; }

                    [JsonProperty("referenceId")]
                    public string ReferenceId { get; set; }

                    [JsonProperty("referenceUrl")]
                    public string ReferenceUrl { get; set; }

                    [JsonProperty("description")]
                    public object Description { get; set; }

                    [JsonProperty("tags")]
                    public object[] Tags { get; set; }

                    [JsonProperty("confidence")]
                    public float Confidence { get; set; }

                    [JsonProperty("isCustom")]
                    public bool IsCustom { get; set; }

                    [JsonProperty("instances")]
                    public Instance[] Instances { get; set; }

                    public class Instance
                    {
                        [JsonProperty("instanceSource")]
                        public string InstanceSource { get; set; }

                        [JsonProperty("adjustedStart")]
                        public string AdjustedStart { get; set; }

                        [JsonProperty("adjustedEnd")]
                        public string AdjustedEnd { get; set; }

                        [JsonProperty("start")]
                        public string Start { get; set; }

                        [JsonProperty("end")]
                        public string End { get; set; }
                    }
                }

                public class AudioEffect
                {
                    [JsonProperty("id")]
                    public int Id { get; set; }

                    [JsonProperty("type")]
                    public string Type { get; set; }

                    [JsonProperty("instances")]
                    public Instance[] Instances { get; set; }

                    public class Instance
                    {
                        [JsonProperty("confidence")]
                        public int Confidence { get; set; }

                        [JsonProperty("adjustedStart")]
                        public string AdjustedStart { get; set; }

                        [JsonProperty("adjustedEnd")]
                        public string AdjustedEnd { get; set; }

                        [JsonProperty("start")]
                        public string Start { get; set; }

                        [JsonProperty("end")]
                        public string End { get; set; }
                    }
                }

                public class Sentiment
                {
                    [JsonProperty("id")]
                    public int Id { get; set; }

                    [JsonProperty("averageScore")]
                    public float AverageScore { get; set; }

                    [JsonProperty("sentimentType")]
                    public string SentimentType { get; set; }

                    [JsonProperty("instances")]
                    public Instance[] Instances { get; set; }

                    public class Instance
                    {
                        [JsonProperty("adjustedStart")]
                        public string AdjustedStart { get; set; }

                        [JsonProperty("adjustedEnd")]
                        public string AdjustedEnd { get; set; }

                        [JsonProperty("start")]
                        public string Start { get; set; }

                        [JsonProperty("end")]
                        public string End { get; set; }
                    }
                }

                public class Block
                {
                    [JsonProperty("id")]
                    public int Id { get; set; }

                    [JsonProperty("instances")]
                    public Instance[] Instances { get; set; }

                    public class Instance
                    {
                        [JsonProperty("adjustedStart")]
                        public string AdjustedStart { get; set; }

                        [JsonProperty("adjustedEnd")]
                        public string AdjustedEnd { get; set; }

                        [JsonProperty("start")]
                        public string Start { get; set; }

                        [JsonProperty("end")]
                        public string End { get; set; }
                    }
                }

                public class Speaker
                {
                    [JsonProperty("id")]
                    public int Id { get; set; }

                    [JsonProperty("name")]
                    public string Name { get; set; }

                    [JsonProperty("instances")]
                    public Instance[] Instances { get; set; }

                    public class Instance
                    {
                        [JsonProperty("adjustedStart")]
                        public string AdjustedStart { get; set; }

                        [JsonProperty("adjustedEnd")]
                        public string AdjustedEnd { get; set; }

                        [JsonProperty("start")]
                        public string Start { get; set; }

                        [JsonProperty("end")]
                        public string End { get; set; }
                    }
                }

                public class TextualContentModeration
                {
                    [JsonProperty("id")]
                    public int Id { get; set; }

                    [JsonProperty("bannedWordsCount")]
                    public int BannedWordsCount { get; set; }

                    [JsonProperty("bannedWordsRatio")]
                    public int BannedWordsRatio { get; set; }

                    [JsonProperty("instances")]
                    public object[] Instances { get; set; }
                }

                public class Statistics
                {
                    [JsonProperty("correspondenceCount")]
                    public int CorrespondenceCount { get; set; }

                    [JsonProperty("speakerTalkToListenRatio")]
                    public SpeakerTalkToListenRatio SpeakerTalkToListenRatioValue { get; set; }

                    [JsonProperty("speakerLongestMonolog")]
                    public SpeakerLongestMonolog SpeakerLongestMonologValue { get; set; }

                    [JsonProperty("speakerNumberOfFragments")]
                    public SpeakerNumberOfFragments SpeakerNumberOfFragmentsValue { get; set; }

                    [JsonProperty("speakerWordCount")]
                    public SpeakerWordCount SpeakerWordCountValue { get; set; }


                    public class SpeakerTalkToListenRatio
                    {
                        [JsonProperty("_1")]
                        public int _1 { get; set; }
                    }

                    public class SpeakerLongestMonolog
                    {
                        [JsonProperty("_1")]
                        public int _1 { get; set; }
                    }

                    public class SpeakerNumberOfFragments
                    {
                        [JsonProperty("_1")]
                        public int _1 { get; set; }
                    }

                    public class SpeakerWordCount
                    {
                        [JsonProperty("_1")]
                        public int _1 { get; set; }
                    }
                }
            }
        }

        public class VideosRange
        {
            [JsonProperty("videoId")]
            public string VideoId { get; set; }

            [JsonProperty("range")]
            public Range RangeValue { get; set; }

            public class Range
            {
                [JsonProperty("start")]
                public string Start { get; set; }

                [JsonProperty("end")]
                public string End { get; set; }
            }
        }
    }
}