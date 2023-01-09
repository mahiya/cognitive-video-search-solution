using Newtonsoft.Json;

namespace VideoSearchSolution.Common
{
    public class VideoArtifact
    {
#nullable disable warnings
        public string Locale { get; set; }
        public string Source { get; set; }
        public DateTime Timestamp { get; set; }
        public int DurationInTicks { get; set; }
        public string Duration { get; set; }
        public CombinedRecognizedPhrase[] CombinedRecognizedPhrases { get; set; }
        public RecognizedPhrase[] RecognizedPhrases { get; set; }

        public class CombinedRecognizedPhrase
        {
            public int Channel { get; set; }
            public string Lexical { get; set; }
            public string ITN { get; set; }
            public string MaskedITN { get; set; }
            public string Display { get; set; }
        }

        public class RecognizedPhrase
        {
            public string RecognitionStatus { get; set; }
            public int Channel { get; set; }
            public int Speaker { get; set; }
            public string Offset { get; set; }
            public string Duration { get; set; }
            public int OffsetInTicks { get; set; }
            public int DurationInTicks { get; set; }
            public Nbest[] NBest { get; set; }
            public object Locale { get; set; }

            public class Nbest
            {
                public float Confidence { get; set; }
                public string Lexical { get; set; }
                public string ITN { get; set; }
                public string MaskedITN { get; set; }
                public string Display { get; set; }
                public Word[] Words { get; set; }
                public object DisplayPhraseElements { get; set; }

                public class Word
                {
                    [JsonProperty("Word")]
                    public string Text { get; set; }
                    public float Confidence { get; set; }
                    public string Offset { get; set; }
                    public string Duration { get; set; }
                    public float OffsetInTicks { get; set; }
                    public float DurationInTicks { get; set; }
                }
            }
        }
    }
}
