import { createRouter, createWebHistory } from "vue-router";
import login from "../views/login.vue";
import dashboard from "../views/dashboard.vue";
import statusmahasiswa from "../views/statusmahasiswa.vue";
import Ukt from "@/views/ukt.vue";
import Beasiswa from "@/views/beasiswa.vue";
import TambahBeasiswa from "@/views/tambahbeasiswa.vue";
import Pembayaran from "@/views/pembayaran.vue";
import Cicilan from "@/views/cicilan.vue";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: "/", // Kita buat login jadi halaman utama
      redirect: "/login",
    },
    {
      path: "/login",
      name: "Login",
      component: login,
    },
    {
      path: "/ukt",
      name: "ukt",
      component: Ukt,
    },

    {
      path: "/dashboard",
      name: "Dashboard",
      component: dashboard,
    },
    {
      path: "/status-mahasiswa",
      name: "Status Mahasiswa",
      component: statusmahasiswa,
    },
    {
      path: "/beasiswa",
      name: "Beasiswa",
      component: Beasiswa,
    },
    {
      path: "/beasiswa/tambah",
      name: "Tambah Beasiswa",
      component: TambahBeasiswa,
    },
    {
      path: "/pembayaran",
      name: "Pembayaran",
      component:Pembayaran
    },
    {
      path: "/cicilan",
      name: "Cicilan",
      component:Cicilan
    }
  ],
});

export default router;