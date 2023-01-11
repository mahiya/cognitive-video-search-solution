<template>
  <div class="upload p-3">
    <h2 class="h4">ビデオファイル一覧</h2>

    <!-- ボタンエリア -->
    <div class="text-end">
      <button class="btn btn-primary me-2" @click="listVideos()">最新情報に更新</button>
      <button type="button" class="btn btn-primary" @click="showModal = true">アップロード</button>
    </div>

    <!-- ビデオ一覧のテーブル -->
    <table class="table table-hover" v-if="!loading && videos.length > 0">
      <thead>
        <tr>
          <th>ファイル名</th>
          <th>状態</th>
          <th>アップロード日時</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="video in videos" :key="video.id">
          <td>
            <img class="me-1 fileIcon" src="images/video.svg" />
            <span>{{video.name}}</span>
          </td>
          <td>
            <span>{{videoStateStr[video.state]}}</span>
            <span v-if="video.state == 'Processing'">({{video.processingProgress}})</span>
          </td>
          <td>{{video.created}}</td>
        </tr>
      </tbody>
    </table>

    <div v-if="!loading && videos.length == 0">ビデオファイルがアップロードされていません</div>

    <!-- Loading アイコン -->
    <div class="text-center w-100" v-if="loading">
      <div>
        <div class="spinner spinner-border text-secondary" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
      </div>
    </div>

    <!-- ファイルアップロードのモーダル -->
    <Teleport to="body">
      <Modal :show="showModal" @close="showModal = false">
        <template #headerTitle>ビデオファイルのアップロード</template>
        <template #body>
          <div>
            <input type="file" @change="onUploadFileSelected" class="form-control" />
          </div>
          <p class="text-danger" v-if="uploadErrorMessage">{{uploadErrorMessage}}</p>
          <div class="progress" v-if="uploading">
            <div
              class="progress-bar progress-bar-striped progress-bar-animated"
              role="progressbar"
              v-bind:style="{ width: uploadProgress + '%' }"
            ></div>
          </div>
        </template>
      </Modal>
    </Teleport>
  </div>
</template>


<script>
import axios from "axios";
import Modal from "../components/ModalView.vue";

export default {
  name: "UploadView",
  components: {
    Modal,
  },
  data() {
    return {
      loading: false,
      videos: [],
      videoStateStr: {
        Uploaded: "アップロード済み",
        Processing: "分析中",
        Processed: "分析完了",
        Failed: "分析失敗",
        Quarantined: "検疫済み",
      },
      showModal: false,
      uploading: false,
      uploadProgress: 0,
      uploadErrorMessage: null,
    };
  },
  async mounted() {
    await this.listVideos();
  },
  watch: {},
  methods: {
    listVideos: async function () {
      this.loading = true;
      const resp = await axios.get(`${this.webApiEndpoint}/api/videos`);
      this.loading = false;
      this.videos = resp.data.map((d) => {
        d.created = formatDate(d.created);
        return d;
      });

      // ビデオがアップロードされていない場合は、アップロード用のモーダルを表示する
      if (this.videos.length == 0) this.showModal = true;
    },
    onUploadFileSelected: async function (e) {
      var file = e.target.files[0];
      if (!file) return;

      this.uploading = 0;
      this.uploadProgress = 0;
      this.uploadErrorMessage = null;

      // Azure Blob へのアップロード先URL(SAS付き)を取得する
      let uploadUrl;
      try {
        const resp = await axios.get(
          `${this.webApiEndpoint}/api/videos/uploadurl?name=${file.name}`
        );
        uploadUrl = resp.data;
      } catch (error) {
        const statusCode = error.response.status;
        if (statusCode == 409) {
          // 既に同じ名前のファイルが Blob に存在する場合はアップロードしないようにする
          this.uploadErrorMessage =
            "既に同じ名前のファイルがアップロードされています。";
          return;
        }
        throw error;
      }

      const reader = new FileReader();
      const onUploadProgress = (e) => {
        this.uploadProgress = Math.round(e.progress * 100);
        if (this.uploadProgress == 100) {
          setTimeout(() => {
            this.showModal = false;
          }, 250);
          setTimeout(() => {
            this.uploading = false;
          }, 500);
          this.videos.push({
            name: file.name,
            state: "Uploaded",
            created: formatDate(new Date()),
          });
        }
      };
      reader.onload = async (e) => {
        const headers = {
          "x-ms-blob-type": "BlockBlob",
          "Content-Type": "audio/wav",
        };
        this.uploading = true;
        await axios.put(uploadUrl, e.target.result, {
          headers,
          onUploadProgress,
        });
      };
      reader.readAsArrayBuffer(file);
    },
  },
};

function formatDate(date) {
  const d = new Date(date);
  const twoDig = (val) => ("0" + val).slice(-2);
  return `${d.getFullYear()}/${twoDig(d.getMonth() + 1)}/${twoDig(
    d.getDate()
  )} ${twoDig(d.getHours())}:${twoDig(d.getMinutes())}:${twoDig(
    d.getSeconds()
  )}`;
}
</script>

<style scoped>
img.fileIcon {
  height: 25px;
  position: relative;
  top: -1.5px;
}

.spinner {
  position: relative;
  top: 3.5rem;
  width: 5rem;
  height: 5rem;
}
</style>