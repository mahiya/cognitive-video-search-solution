
new Vue({
    el: '#app',
    data: {
        settings: {},
        loading: true,
        search: "",
        docs: [],
        videoWidgetsUrl: null,
        insightsWidgetsUrl: null,
        accessKeys: {},
        suggestions: [],
        page: 1,
        maxPage: null,
    },
    async mounted() {
        await this.getSettings();
        await this.searchDocuments();
    },
    watch: {
        // 検索テキストボックスの値が変更された時の処理
        search: function () {
            this.page = 1;
            this.getSuggestions();
            this.searchDocuments();
        },
        // ページネーションがクリックされた時の処理
        page: function () {
            this.searchDocuments();
        }
    },
    methods: {
        // 設定情報を取得する
        getSettings: async function () {
            const resp = await axios.get("./cogsearch_settings.json");
            this.settings = resp.data;
        },
        // 検索結果を取得する
        searchDocuments: async function () {

            // Azure Cognitive Search REST API を呼び出して検索結果を取得する
            // 参考：https://learn.microsoft.com/ja-jp/rest/api/searchservice/search-documents
            const url = `https://${this.settings.cognitiveSearchName}.search.windows.net/indexes/${this.settings.cognitiveSearchIndexName}/docs/search?api-version=${this.settings.apiVersion}`;
            const headers = {
                "Content-Type": "application/json",
                "api-key": this.settings.cognitiveSearchQueryKey
            };
            const body = {
                "search": this.search,
                "top": this.settings.searchTop,
                "skip": (this.page - 1) * this.settings.searchTop,
                "facets": Object.keys(this.settings.facetNames).map(f => `${f},count:5,sort:count`),
                "count": true,
                "highlight": this.settings.highlight,
                "highlightPreTag": this.settings.highlightPreTag,
                "highlightPostTag": this.settings.highlightPostTag
            };

            // REST API の呼び出し
            const resp = await axios.post(url, body, { headers });

            // 検索結果のテキストに対するハイライト処理を行う
            this.docs = resp.data.value.map(value => {
                if (value["@search.highlights"]) {
                    for (const highlightProp of Object.keys(value["@search.highlights"])) {
                        for (const highlight of value["@search.highlights"][highlightProp]) {
                            const replaceFrom = replaceAll(replaceAll(highlight, this.settings.highlightPreTag, ""), this.settings.highlightPostTag, "");
                            const replaceTo = highlight;
                            value[highlightProp] = replaceAll(value[highlightProp], replaceFrom, replaceTo);
                        }
                    }
                }
                return value;
            });

            // 検索対象のデータ数を取得する
            const dataCount = resp.data["@odata.count"];
            this.maxPage = Math.ceil(dataCount / this.settings.searchTop);

            // 検索結果の一番上位の発言のビデオを表示する
            if (this.docs.length > 0 && this.videoWidgetsUrl == null) {
                this.showVideo(this.docs[0].videoId, this.docs[0].offset);
            }
        },
        // サジェストを取得する
        getSuggestions: async function () {

            // 検索フィールドの入力がない場合は処理を行わない
            if (!this.search) return;

            // サジェスター名が指定されていない場合は処理を行わない
            if (!this.settings.suggesterName) return;

            // Azure Cognitive Search REST API を呼び出してサジェストを取得する
            // 参考：https://learn.microsoft.com/ja-jp/rest/api/searchservice/suggestions
            const queryParameters = {
                "api-version": this.settings.apiVersion,
                "search": this.search,
                "suggesterName": this.settings.suggesterName,
                "$top": 50,
            };
            const queryString = Object.keys(queryParameters).map(key => [key, queryParameters[key]].join("=")).join("&");
            const url = `https://${this.settings.cognitiveSearchName}.search.windows.net/indexes/${this.settings.indexName}/docs/suggest?${queryString}`;
            const headers = {
                "Content-Type": "application/json",
                "api-key": this.settings.queryKey
            };
            const resp = await axios.get(url, { headers });

            // サジェストの重複を排除する
            const values = []
            for (const value of resp.data.value) {
                if (!values.includes(value["@search.text"]))
                    values.push(value["@search.text"]);
                if (values.length >= this.settings.suggestionTop) break;
            }
            this.suggestions = values;
        },
        // 指定したビデオを画面に表示する
        showVideo: async function (videoId, offset) {
            const resp = await axios.get(`api/videos/${videoId}/widgets`);
            this.videoWidgetsUrl = resp.data.videoWidgetsUrl + `&t=${offset}`;
            this.insightsWidgetsUrl = resp.data.insightsWidgetsUrl;
        },
        // ページネーションがクリックされた時の処理
        onPagenationClicked: function (newPage) {
            this.page = newPage;
        },
    }
});

function replaceAll(text, oldStr, newStr) {
    return text.replace(new RegExp(oldStr, 'g'), newStr);
}