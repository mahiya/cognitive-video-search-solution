new Vue({
    el: '#app',
    data: {
        loading: false,
        videos: [],
        videoStateStr: {
            'Uploaded': 'アップロード済み',
            'Processing': '分析中',
            'Processed': '分析完了',
            'Failed': '分析失敗',
            'Quarantined': '検疫済み',
        },
        uploading: false,
        uploadProgress: 0,
        selectedFile: '',
        uploadErrorMessage: null
    },
    async mounted() {
        await this.listVideos();
    },
    watch: {},
    methods: {
        listVideos: async function () {
            this.loading = true;
            const resp = await axios.get("api/videos");
            this.loading = false;
            this.videos = resp.data.map(d => {
                d.created = formatDate(d.created);
                return d;
            });

            // ビデオがアップロードされていない場合は、アップロード用のモーダルを表示する
            if (this.videos.length == 0)
                $('#modal').modal('show');
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
                const resp = await axios.get(`api/videos/uploadurl?name=${file.name}`);
                uploadUrl = resp.data;
            } catch (error) {
                const statusCode = error.response.status;
                if (statusCode == 409) {
                    // 既に同じ名前のファイルが Blob に存在する場合はアップロードしないようにする
                    this.uploadErrorMessage = '既に同じ名前のファイルがアップロードされています。'
                    return;
                }
                throw error;
            }

            const reader = new FileReader();
            const onUploadProgress = (e) => {
                this.uploadProgress = Math.round(e.progress * 100);
                if (this.uploadProgress == 100) {
                    setTimeout(() => { $("#modal").modal('hide') }, 250);
                    setTimeout(() => { this.uploading = false; this.selectedFile = ''; }, 1000);
                    setTimeout(() => { this.listVideos() }, 5000);
                }
            }
            reader.onload = async (e) => {
                const headers = {
                    'x-ms-blob-type': 'BlockBlob',
                    'Content-Type': 'audio/wav'
                }
                this.uploading = true;
                await axios.put(uploadUrl, e.target.result, { headers, onUploadProgress });
            }
            reader.readAsArrayBuffer(file);
        }
    }
});

function formatDate(date) {
    const d = new Date(date);
    const twoDig = (val) => ('0' + val).slice(-2);
    return `${d.getFullYear()}/${twoDig(d.getMonth() + 1)}/${twoDig(d.getDate())} ${twoDig(d.getHours())}:${twoDig(d.getMinutes())}:${twoDig(d.getSeconds())}`;
}