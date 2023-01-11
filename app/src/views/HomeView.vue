<template>
  <div class="home row p-0 m-0">
    <!-- 左部分 -->
    <div class="col py-6 px-3 vh-100" style="overflow-y: scroll;">
      <!-- 検索ボックス -->
      <div style="margin-top: 15px">
        <div class="input-group">
          <span class="input-group-text">
            <i class="bi bi-search"></i>
          </span>
          <input v-model="search" class="form-control" list="datalistOptions" placeholder="検索" />
          <datalist id="datalistOptions">
            <option v-for="suggestion in suggestions" :key="suggestion" v-bind:value="suggestion"></option>
          </datalist>
        </div>
      </div>

      <!-- 検索結果 -->
      <div
        class="card my-3"
        style="cursor: pointer"
        v-for="doc in docs"
        :key="doc.id"
        @click="showVideo(doc.videoId, doc.offset)"
      >
        <div class="card-header">{{doc.blob}}</div>
        <div class="card-body" v-html="doc.phrase"></div>
      </div>
      <div class="mt-3" v-if="docs.length == 0">検索結果が見つかりませんでした</div>

      <!-- 検索結果のページ選択(ページネーション) -->
      <ul class="pagination" v-if="maxPage">
        <li class="page-item" v-bind:class="{ 'disabled': page == 1 }">
          <a class="page-link" href="#" aria-label="Previous" @:click="onPagenationClicked(page-1)">
            <span aria-hidden="true">&laquo;</span>
          </a>
        </li>
        <li
          class="page-item"
          v-for="pagenation in pagenations"
          :key="pagenation"
          v-bind:class="{ 'active': pagenation == page }"
        >
          <a class="page-link" href="#" @v-on:click="onPagenationClicked(pagenation)">{{pagenation}}</a>
        </li>
        <li class="page-item" v-bind:class="{ 'disabled': page == maxPage }">
          <a class="page-link" href="#" aria-label="Next" @:click="onPagenationClicked(page+1)">
            <span aria-hidden="true">&raquo;</span>
          </a>
        </li>
      </ul>
    </div>

    <!-- 中央部分 -->
    <div class="col py-3 px-2">
      <iframe
        class="w-100 h-100"
        v-if="videoWidgetsUrl != null"
        v-bind:src="videoWidgetsUrl"
        frameborder="0"
        allowfullscreen
      ></iframe>
    </div>

    <!-- 右部分 -->
    <div class="col py-3 px-2">
      <iframe
        class="w-100 h-100"
        v-if="insightsWidgetsUrl != null"
        v-bind:src="insightsWidgetsUrl"
        frameborder="0"
        allowfullscreen
      ></iframe>
    </div>
  </div>
</template>

<script>
import axios from "axios";

export default {
  name: "HomeView",
  data() {
    return {
      settings: {},
      loading: true,
      search: "",
      docs: [],
      videoWidgetsUrl: null,
      insightsWidgetsUrl: null,
      accessKeys: {},
      suggestions: [],
      page: 1,
      pagenations: [],
      maxPage: null,
    };
  },
  async mounted() {
    // 設定情報を取得する
    this.settings = require("@/assets/cogsearch_settings.json");

    // 画面表示時に検索処理を行う
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
    page: async function () {
      this.searchDocuments();
    },
  },
  methods: {
    // 検索結果を取得する
    searchDocuments: async function () {
      // Azure Cognitive Search REST API を呼び出して検索結果を取得する
      // 参考：https://learn.microsoft.com/ja-jp/rest/api/searchservice/search-documents
      const url = `https://${this.settings.cognitiveSearchName}.search.windows.net/indexes/${this.settings.cognitiveSearchIndexName}/docs/search?api-version=${this.settings.apiVersion}`;
      const headers = {
        "Content-Type": "application/json",
        "api-key": this.settings.cognitiveSearchQueryKey,
      };
      const body = {
        search: this.search,
        top: this.settings.searchTop,
        skip: (this.page - 1) * this.settings.searchTop,
        facets: Object.keys(this.settings.facetNames).map(
          (f) => `${f},count:5,sort:count`
        ),
        count: true,
        highlight: this.settings.highlight,
        highlightPreTag: this.settings.highlightPreTag,
        highlightPostTag: this.settings.highlightPostTag,
      };

      // REST API の呼び出し
      const resp = await axios.post(url, body, { headers });

      // 検索結果のテキストに対するハイライト処理を行う
      this.docs = resp.data.value.map((value) => {
        if (value["@search.highlights"]) {
          for (const highlightProp of Object.keys(
            value["@search.highlights"]
          )) {
            for (const highlight of value["@search.highlights"][
              highlightProp
            ]) {
              const replaceFrom = replaceAll(
                replaceAll(highlight, this.settings.highlightPreTag, ""),
                this.settings.highlightPostTag,
                ""
              );
              const replaceTo = highlight;
              value[highlightProp] = replaceAll(
                value[highlightProp],
                replaceFrom,
                replaceTo
              );
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

      // ページネーションに使用する変数を更新する
      this.updatePagenation();
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
        search: this.search,
        suggesterName: this.settings.suggesterName,
        $top: 50,
      };
      const queryString = Object.keys(queryParameters)
        .map((key) => [key, queryParameters[key]].join("="))
        .join("&");
      const url = `https://${this.settings.cognitiveSearchName}.search.windows.net/indexes/${this.settings.indexName}/docs/suggest?${queryString}`;
      const headers = {
        "Content-Type": "application/json",
        "api-key": this.settings.queryKey,
      };
      const resp = await axios.get(url, { headers });

      // サジェストの重複を排除する
      const values = [];
      for (const value of resp.data.value) {
        if (!values.includes(value["@search.text"]))
          values.push(value["@search.text"]);
        if (values.length >= this.settings.suggestionTop) break;
      }
      this.suggestions = values;
    },
    // 指定したビデオを画面に表示する
    showVideo: async function (videoId, offset) {
      const resp = await axios.get(
        `${this.webApiEndpoint}/api/videos/${videoId}/widgets`
      );
      this.videoWidgetsUrl = resp.data.videoWidgetsUrl + `&t=${offset}`;
      this.insightsWidgetsUrl = resp.data.insightsWidgetsUrl;
    },
    // ページネーションがクリックされた時の処理
    onPagenationClicked: function (newPage) {
      this.page = newPage;
    },
    // ページネーションに使用する変数を更新する
    updatePagenation: function () {
      this.pagenations = Array.from(
        { length: 5 },
        (v, k) => this.page + k - 2
      ).filter((p) => p > 0 && p <= this.maxPage);
    },
  },
};

function replaceAll(text, oldStr, newStr) {
  return text.replace(new RegExp(oldStr, "g"), newStr);
}
</script>

<style scoped>
.card:hover {
  border: 1px solid #bbb;
}
</style>