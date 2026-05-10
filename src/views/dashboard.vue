<template>
  <div class="dashboard-layout">


    <main class="main-content">
      <header class="topbar">
        <div>
          <h1>Dashboard Keuangan</h1>
          <p>Selamat datang kembali, Admin 👋</p>
        </div>

        <div class="profile-section">
          <button class="notif-btn">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0" />
            </svg>
          </button>
          <div class="profile profile-blue">
            <img src="https://i.pravatar.cc/100" alt="profile" />
            <span>Admin Keuangan</span>
          </div>
        </div>
      </header>

      <section class="stats-grid">
        <div class="card">
          <div class="card-icon blue">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z" />
            </svg>
          </div>
          <div class="card-text">
            <h3>Total Mahasiswa</h3>
            <h2>{{ totalMahasiswa }}</h2>
          </div>
        </div>

        <div class="card">
          <div class="card-icon green">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="m20.25 7.5-.625 10.632a2.25 2.25 0 0 1-2.247 2.118H6.622a2.25 2.25 0 0 1-2.247-2.118L3.75 7.5m8.25 3v6.75m0 0-3-3m3 3 3-3M3.375 7.5h17.25c.621 0 1.125-.504 1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125H3.375c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125Z" />
            </svg>
          </div>
          <div class="card-text">
            <h3>Sudah Membayar</h3>
            <h2>{{ sudahBayar }}</h2>
          </div>
        </div>

        <div class="card">
          <div class="card-icon red">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="m20.25 7.5-.625 10.632a2.25 2.25 0 0 1-2.247 2.118H6.622a2.25 2.25 0 0 1-2.247-2.118L3.75 7.5m6 4.125 2.25 2.25m0 0 2.25 2.25M12 13.875l2.25-2.25M12 13.875l-2.25 2.25M3.375 7.5h17.25c.621 0 1.125-.504 1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125H3.375c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125Z" />
            </svg>
          </div>
          <div class="card-text">
            <h3>Belum Membayar</h3>
            <h2>{{ belumBayar }}</h2>
          </div>
        </div>
      </section>

      <section class="content-grid">
        <div class="chart-card">
          <div class="chart-header">
            <h2>Grafik Mahasiswa Jurusan</h2>
            <select v-model="selectedJurusan">
              <option>Semua Jurusan</option>
              <option v-for="jur in jurusanList" :key="jur.name">{{ jur.name }}</option>
            </select>
          </div>

          <div class="chart-placeholder">
            <div v-for="(item, index) in chartData" :key="index" class="bar-group">
              <div class="bar" :style="{ height: item.value + '%' }"></div>
              <span>{{ item.name }}</span>
            </div>
          </div>
        </div>

        <div class="info-panel">
          <div v-for="(jurusan, index) in jurusanList" :key="index" class="info-box">
            <h4>{{ jurusan.name }}</h4>
            <p>{{ jurusan.total }} Mahasiswa</p>
          </div>
        </div>
      </section>
    </main>


  </div>
</template>

<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";

const router = useRouter();
const isCollapsed = ref(false);
const activeMenu = ref("Dashboard");
const selectedJurusan = ref("Semua Jurusan");
const showLogoutModal = ref(false);

const totalMahasiswa = 520;
const sudahBayar = 380;
const belumBayar = 140;

const handleMenuClick = (item) => {
  activeMenu.value = item.name;
  if (item.path) {
    router.push(item.path);
  }
};

const handleLogout = () => {
  showLogoutModal.value = true;
};

const confirmLogout = () => {
  router.push('/login');
};

const menus = [
  { 
    name: "Dashboard", 
    path: "/dashboard",
    icon: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25" /></svg>` 
  },
  {
    name: "Status Mahasiswa", 
    path: "/status-mahasiswa",
    icon: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6.042A8.967 8.967 0 0 0 6 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 0 1 6 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 0 1 6-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0 0 18 18a8.967 8.967 0 0 0-6 2.292m0-14.25v14.25" /> </svg>`,
  },
  { 
    name: "Pembayaran",
    path: "/dashboard",
    icon: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 8.25h19.5M2.25 9h19.5m-16.5 5.25h6m-6 2.25h3m-3.75 3h15a2.25 2.25 0 0 0 2.25-2.25V6.75A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25v10.5A2.25 2.25 0 0 0 4.5 19.5Z" /></svg>`
  },
  { 
    name: "Beasiswa",
    path: "/dashboard",
    icon: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M12 21v-8.25M15.75 21v-8.25M8.25 21v-8.25M3 9l9-6 9 6m-1.5 12V10.332A48.36 48.36 0 0 0 12 9.75c-2.551 0-5.056.2-7.5.582V21M3 21h18M12 6.75h.008v.008H12V6.75Z" /></svg>`
  },
  { 
    name: "Laporan",
    path: "/dashboard",
    icon: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z" /></svg>`
  },
];

const jurusanList = [
  { name: "Teknik Elektro", total: 120 },
  { name: "Teknik Mesin", total: 95 },
  { name: "Teknik Sipil", total: 110 },
  { name: "Akuntansi", total: 80 },
  { name: "Bisnis", total: 115 },
];

const chartData = [
  { name: "Elektro", value: 80 },
  { name: "Mesin", value: 60 },
  { name: "Sipil", value: 90 },
  { name: "Akuntansi", value: 50 },
  { name: "Bisnis", value: 70 },
];
</script>

<style scoped>
* { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }

.dashboard-layout { display: flex; min-height: 100vh; background: #f4f7fa; font-size: 14px; }

/* SIDEBAR */
.sidebar { width: 240px; background: #1e3a8a; color: white; padding: 20px 10px; display: flex; flex-direction: column; transition: width 0.3s ease; }
.sidebar.collapsed { width: 80px; }
.logo-section { display: flex; align-items: center; gap: 10px; margin-bottom: 30px; height: 35px; padding: 0 10px; }
.logo-circle { min-width: 32px; height: 32px; border-radius: 8px; overflow: hidden; background: white; }
.logo-circle img { width: 100%; height: 100%; object-fit: cover; }
.logo-section h2 { font-size: 15px; font-weight: 600; }
.toggle-btn-inline { background: none; border: none; color: white; cursor: pointer; margin-left: auto; }
.toggle-btn-inline svg { width: 20px; height: 20px; }

.menu { display: flex; flex-direction: column; gap: 4px; flex: 1; }
.menu-item { background: transparent; border: none; color: #cbd5e1; padding: 10px 15px; border-radius: 12px; cursor: pointer; display: flex; align-items: center; gap: 12px; font-size: 13px; transition: 0.2s; white-space: nowrap; width: 100%; }
.menu-item:hover, .menu-item.active { background: rgba(255, 255, 255, 0.1); color: white; }
.icon-wrapper { min-width: 20px; display: flex; align-items: center; justify-content: center; }
.icon-wrapper :deep(svg) { width: 18px; height: 18px; }

.logout-btn { background: rgba(255, 255, 255, 0.05); border: none; color: #fca5a5; padding: 10px 15px; border-radius: 12px; cursor: pointer; display: flex; align-items: center; gap: 12px; transition: 0.3s; margin-top: 20px; }
.logout-btn:hover { background: rgba(239, 68, 68, 0.2); color: #ef4444; }

/* CONTENT */
.main-content { flex: 1; padding: 25px; overflow-y: auto; }
.topbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
.topbar h1 { font-size: 20px; font-weight: 600; color: #1e293b; }
.topbar p { font-size: 12px; color: #64748b; }

.profile-section { display: flex; align-items: center; gap: 12px; }
.notif-btn { background: white; border: 1px solid #e2e8f0; width: 35px; height: 35px; border-radius: 8px; cursor: pointer; display: flex; align-items: center; justify-content: center; }
.notif-btn svg { width: 20px; height: 20px; color: #64748b; }
.profile-blue { display: flex; align-items: center; gap: 10px; background: #1e3a8a; color: white; padding: 6px 15px; border-radius: 10px; font-size: 13px; }
.profile-blue img { width: 26px; height: 26px; border-radius: 50%; border: 1px solid white; }

/* STATS */
.stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 25px; }
.card { background: white; border-radius: 15px; padding: 20px; display: flex; align-items: center; gap: 15px; border: 1px solid #e2e8f0; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
.card-icon { width: 45px; height: 45px; border-radius: 12px; display: flex; align-items: center; justify-content: center; }
.card-icon svg { width: 24px; height: 24px; color: white; }
.card-icon.blue { background: #3b82f6; }
.card-icon.green { background: #10b981; }
.card-icon.red { background: #ef4444; }
.card-text h3 { font-size: 12px; color: #64748b; margin-bottom: 4px; }
.card-text h2 { font-size: 20px; font-weight: 700; color: #1e293b; }

/* CHART */
.content-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 20px; }
.chart-card, .info-panel { background: white; border-radius: 15px; padding: 20px; border: 1px solid #e2e8f0; }
.chart-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
.chart-header h2 { font-size: 15px; font-weight: 600; }
.chart-header select { font-size: 12px; padding: 5px; border-radius: 8px; border: 1px solid #e2e8f0; }
.chart-placeholder { height: 200px; display: flex; align-items: flex-end; justify-content: space-around; }
.bar-group { display: flex; flex-direction: column; align-items: center; width: 40px; }
.bar { width: 100%; background: #3b82f6; border-radius: 6px 6px 0 0; transition: height 0.5s ease; }
.bar-group span { margin-top: 10px; font-size: 11px; color: #64748b; }

.info-panel { display: flex; flex-direction: column; gap: 10px; }
.info-box { padding: 12px; background: #f8fafc; border-radius: 10px; border: 1px solid #f1f5f9; }
.info-box h4 { font-size: 12px; color: #64748b; margin-bottom: 2px; }
.info-box p { font-size: 13px; font-weight: 600; color: #1e3a8a; }

/* MODAL */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); backdrop-filter: blur(4px); display: flex; align-items: center; justify-content: center; z-index: 999; }
.modal-content { background: white; padding: 30px; border-radius: 20px; width: 360px; text-align: center; }
.modal-icon { width: 60px; height: 60px; background: #fef2f2; color: #ef4444; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 15px; }
.modal-icon svg { width: 30px; height: 30px; }
.modal-actions { display: flex; gap: 12px; margin-top: 20px; }
.btn-cancel { flex: 1; padding: 10px; border-radius: 10px; border: 1px solid #e2e8f0; cursor: pointer; }
.btn-confirm { flex: 1; padding: 10px; border-radius: 10px; border: none; background: #ef4444; color: white; cursor: pointer; font-weight: 500; }

.fade-enter-active, .fade-leave-active { transition: opacity 0.3s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>