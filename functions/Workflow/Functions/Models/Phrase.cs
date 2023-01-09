using System;

namespace VideoSearchSolution.Workflow
{
    class Phrase
    {
        public string id { get; set; } = Guid.NewGuid().ToString();
        public string account { get; set; }
        public string container { get; set; }
        public string blob { get; set; }
        public string videoId { get; set; }
        public int index { get; set; }
        public string phrase { get; set; }
        public long offset { get; set; }
    }
}
