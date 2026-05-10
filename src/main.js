import { createApp } from 'vue'
import App from './App.vue'
import router from './router' // Pastikan mengarah ke index.js router tadi
import './assets/main.css'

const app = createApp(App)
app.use(router) // Router dipasang di sini
app.mount('#app')