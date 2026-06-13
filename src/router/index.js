import { createRouter, createWebHistory } from "vue-router";
import login from "../views/login.vue";
import dashboard from "../views/dashboard.vue";
import statusmahasiswa from "../views/statusmahasiswa.vue";
import Ukt from "@/views/ukt.vue";
import Pembayaran from "@/views/pembayaran.vue";
import Cicilan from "@/views/cicilan.vue";
import TambahCicilan from "@/views/tambahcicilan.vue";
import EditCicilan from "@/views/editcicilan.vue";

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
      path: "/pembayaran",
      name: "Pembayaran",
      component:Pembayaran
    },
    {
      path: "/cicilan",
      name: "Cicilan",
      component:Cicilan
    },
    {
      path: "/cicilan/tambah/",
      name: "Tambah Cicilan",
      component: TambahCicilan
    },
    {
      path: "/cicilan/edit/:nim",
      name: "Edit Cicilan",
      component: EditCicilan,
      props: true
    },
  ],
});

export default router;