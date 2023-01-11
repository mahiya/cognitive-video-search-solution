import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import axios from 'axios'
import VueAxios from 'vue-axios'

const app = createApp(App);
app.use(router).use(VueAxios, axios).mount('#app')

app.config.globalProperties.webApiEndpoint = process.env.NODE_ENV == "development"
    ? "http://localhost:7234"
    : "";