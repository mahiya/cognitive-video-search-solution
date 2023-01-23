using Azure.Core;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading;
using System.Threading.Tasks;
using System.Web;

namespace VideoSearchSolution
{
    public class VideoIndexerClient
    {
#nullable disable warnings
        readonly TokenCredential _credential;
        readonly string _location;
        readonly string _accountId;
        readonly string _resourceId;
        readonly Dictionary<string, (string, DateTime)> _cachedAccessTokens; // (Key, Value(AccessToken, ExpiredOn))

        public VideoIndexerClient(VideoIndexerClientSettings settings)
        {
            _credential = settings.Credential;
            _location = settings.VideoIndexerLocation;
            _accountId = settings.VideoIndexerAccountId;
            _resourceId = settings.VideoIndexerResourceId;
            _cachedAccessTokens = new Dictionary<string, (string, DateTime)>();
        }

        /// <summary>
        /// https://api-portal.videoindexer.ai/api-details#api=Operations&operation=List-Videos
        /// </summary>
        public async Task<Video[]> ListVideosAsync()
        {
            using var httpClient = new HttpClient();
            var accountAccessToken = await GetAccountAccessTokenAsync();
            httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accountAccessToken);
            var url = $"https://api.videoindexer.ai/{_location}/Accounts/{_accountId}/Videos";
            var resp = await httpClient.GetAsync(url);
            var json = await resp.Content.ReadAsStringAsync();
            var videos = JsonConvert.DeserializeObject<ListVideosApiResponse>(json).Videos;
            return videos;
        }

        /// <summary>
        /// https://api-portal.videoindexer.ai/api-details#api=Operations&operation=List-Videos
        /// </summary>
        public async Task<VideoIndex> GetVideoIndexAsync(string videoId)
        {
            using var httpClient = new HttpClient();
            var accountAccessToken = await GetAccountAccessTokenAsync();
            httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accountAccessToken);
            var url = $"https://api.videoindexer.ai/{_location}/Accounts/{_accountId}/Videos/{videoId}/Index";
            var resp = await httpClient.GetAsync(url);
            var json = await resp.Content.ReadAsStringAsync();
            var videoIndex = JsonConvert.DeserializeObject<VideoIndex>(json);
            return videoIndex;
        }

        /// <summary>
        /// https://api-portal.videoindexer.ai/api-details#api=Operations&operation=Get-Video-Artifact-Download-Url
        /// </summary>
        public async Task<VideoArtifact> GetVideoArtifactAsync(string videoId)
        {
            var artifactDownloadUrl = await GetVideoArtifactDownloadUrlAsync(videoId);
            using var client = new HttpClient();
            var json = await client.GetStringAsync(artifactDownloadUrl);
            var result = JsonConvert.DeserializeObject<VideoArtifact>(json);
            return result;
        }

        /// <summary>
        /// https://api-portal.videoindexer.ai/api-details#api=Operations&operation=Get-Video-Artifact-Download-Url
        /// </summary>
        async Task<string> GetVideoArtifactDownloadUrlAsync(string videoId)
        {
            using var client = new HttpClient();
            var accountAccessToken = await GetAccountAccessTokenAsync();
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accountAccessToken);
            var url = $"https://api.videoindexer.ai/{_location}/Accounts/{_accountId}/Videos/{videoId}/ArtifactUrl?type=Transcript";
            var resp = await client.GetAsync(url);
            var downloadUrl = (await resp.Content.ReadAsStringAsync()).Replace("\"", "");
            return downloadUrl;
        }

        /// <summary>
        /// https://api-portal.videoindexer.ai/api-details#api=Operations&operation=Upload-Video
        /// </summary>
        public async Task<string> UploadVideoAsync(string videoUrl, string videoName = null, string description = "-", string language = "ja-JP")
        {
            if (videoName == null)
                videoName = Path.GetFileName(new Uri(videoUrl).LocalPath);

            using var client = new HttpClient();
            var accountAccessToken = await GetAccountAccessTokenAsync();
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accountAccessToken);
            var queryParameters = new Dictionary<string, string>()
            {
                {"name", videoName},
                {"description", description},
                {"privacy", "private"},
                {"partition", "partition"},
                {"videoUrl", HttpUtility.UrlEncode(videoUrl)},
                {"language", language}
            };
            var queryString = string.Join("&", queryParameters.Select(pair => $"{pair.Key}={pair.Value}"));
            var url = $"https://api.videoindexer.ai/{_location}/Accounts/{_accountId}/Videos?{queryString}";
            var resp = await client.PostAsync(url, null);
            var json = await resp.Content.ReadAsStringAsync();
            var result = JsonConvert.DeserializeObject<UploadVideoApiResponse>(json);
            return result.Id;
        }

        async Task<string> GetAccountAccessTokenAsync()
        {
            const string cacheKey = "account";
            var cachedToken = GetCachedAccessToken(cacheKey);
            if (cachedToken != null) return cachedToken;

            var armAccessToken = await GenerateArmAccessTokenAsync();
            var accountAccessToken = await GenerateAccessTokenAsync(armAccessToken, new AccessTokenRequestOptions
            {
                Scope = AccessTokenScope.Account,
                PermissionType = AccessTokenPermission.Contributor,
            });

            SetCachedAccessToken(cacheKey, accountAccessToken, DateTime.UtcNow.AddMinutes(55));
            return accountAccessToken;
        }

        public async Task<string> GenerateVideoAccessTokenAsync(string videoId)
        {
            var cachedToken = GetCachedAccessToken(videoId);
            if (cachedToken != null) return cachedToken;

            var armAccessToken = await GenerateArmAccessTokenAsync();
            var videoAccessToken = await GenerateAccessTokenAsync(armAccessToken, new AccessTokenRequestOptions
            {
                Scope = AccessTokenScope.Video,
                PermissionType = AccessTokenPermission.Contributor,
                VideoId = videoId,
            });

            SetCachedAccessToken(videoId, videoAccessToken, DateTime.UtcNow.AddMinutes(55));
            return videoAccessToken;
        }

        async Task<string> GenerateArmAccessTokenAsync()
        {
            var context = new TokenRequestContext(new[] { "https://management.azure.com/.default" });
            var result = await _credential.GetTokenAsync(context, CancellationToken.None);
            return result.Token;
        }

        async Task<string> GenerateAccessTokenAsync(string armAccessToken, AccessTokenRequestOptions options)
        {
            using var client = new HttpClient();
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", armAccessToken);
            var url = $"https://management.azure.com/{_resourceId}/generateAccessToken?api-version=2022-08-01";
            var body = JsonConvert.SerializeObject(options);
            var content = new StringContent(body, System.Text.Encoding.UTF8, "application/json");
            var resp = await client.PostAsync(url, content);
            var json = await resp.Content.ReadAsStringAsync();
            var accountAccessToken = JObject.Parse(json)["accessToken"].ToString();
            return accountAccessToken;
        }

        string GetCachedAccessToken(string key)
        {
            if (!_cachedAccessTokens.ContainsKey(key))
                return null;
            var cachedAccessToken = _cachedAccessTokens[key];
            if (cachedAccessToken.Item2 < DateTime.UtcNow)
                return null;
            return cachedAccessToken.Item1;
        }

        void SetCachedAccessToken(string key, string accessToken, DateTime expiredOn)
        {
            if (_cachedAccessTokens.ContainsKey(key))
                _cachedAccessTokens[key] = (accessToken, expiredOn);
            else
                _cachedAccessTokens.Add(key, (accessToken, expiredOn));
        }

        class AccessTokenRequestOptions
        {
            public AccessTokenPermission PermissionType { get; set; }
            public AccessTokenScope Scope { get; set; }
            public string ProjectId { get; set; }
            public string VideoId { get; set; }
        }

        [JsonConverter(typeof(StringEnumConverter))]
        enum AccessTokenPermission
        {
            Reader,
            Contributor,
            MyAccessAdministrator,
            Owner,
        }

        [JsonConverter(typeof(StringEnumConverter))]
        enum AccessTokenScope
        {
            Account,
            Project,
            Video
        }
    }
}