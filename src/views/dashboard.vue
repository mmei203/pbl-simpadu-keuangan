<template>
  <div class="main-content">
    <header class="topbar">
      <div>
        <h1>Dashboard Keuangan</h1>
        <p class="subtitle">Selamat datang kembali, Admin 👋</p>
      </div>

      <div class="profile-section">
        <button class="notif-btn">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" d="M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0" />
          </svg>
        </button>
        <div class="profile-blue">
          <img src="https://i.pravatar.cc/100" alt="profile" />
          <span>Admin Keuangan</span>
        </div>
      </div>
    </header>

    <div v-if="isLoading" class="loading-state">Mengambil dan menghitung data dari server Laravel...</div>

    <div v-else-if="errorMessage" class="error-state">
      <p>{{ errorMessage }}</p>
      <button @click="fetchDashboardData" class="retry-btn">Coba Lagi</button>
    </div>

    <div v-else>
      <section class="stats-grid">
        <div class="stat-card blue">
          <div class="icon-box">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z" /></svg>
          </div>
          <div>
            <p>Total Mahasiswa</p>
            <h3>{{ totalMahasiswa }}</h3>
          </div>
        </div>

        <div class="stat-card red">
          <div class="icon-box">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m9.75 9.75 4.5 4.5m0-4.5-4.5 4.5M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" /></svg>
          </div>
          <div>
            <p>Belum Membayar</p>
            <h3>{{ belumBayar }}</h3>
          </div>
        </div>

        <div class="stat-card orange">
          <div class="icon-box">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 8.25h19.5M2.25 9h19.5m-16.5 5.25h6m-6 2.25h3m-3.75 3h15a2.25 2.25 0 0 0 2.25-2.25V6.75A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25v10.5A2.25 2.25 0 0 0 4.5 19.5Z" /></svg>
          </div>
          <div>
            <p>Cicil</p>
            <h3>{{ sedangCicil }}</h3>
          </div>
        </div>

        <div class="stat-card green">
          <div class="icon-box">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" /></svg>
          </div>
          <div>
            <p>Sudah Bayar</p>
            <h3>{{ sudahBayar }}</h3>
          </div>
        </div>
      </section>

      <div class="dashboard-grid">
        <div class="chart-card">
          <div class="chart-header">
            <h3>Grafik Mahasiswa Jurusan</h3>
            <select v-model="filterJurusanChart">
              <option value="">Semua Jurusan</option>
              <option v-for="(val, key) in dataJurusan" :key="key" :value="key">{{ key }}</option>
            </select>
          </div>

          <div class="bar-chart-container">
            <div v-if="Object.keys(dataJurusan).length === 0" class="empty-chart">Tidak ada data jurusan ditemukan</div>
            <div v-for="(count, jurusanName) in dataJurusan" :key="jurusanName" class="bar-group">
              <div class="bar-wrapper">
                <div 
                  class="bar-fill" 
                  :style="{ height: `${(count / (maxMahasiswaDiJurusan || 1)) * 100}%` }"
                  :title="`${count} Mahasiswa`"
                >
                  <span class="bar-tooltip">{{ count }}</span>
                </div>
              </div>
              <span class="bar-label">{{ jurusanName }}</span>
            </div>
          </div>
        </div>

        <div class="list-card">
          <div v-if="Object.keys(dataJurusan).length === 0" class="empty-list">Belum ada rincian data.</div>
          <div v-for="(count, jurusanName) in dataJurusan" :key="jurusanName" class="jurusan-row-item">
            <div>
              <h4>Teknik {{ jurusanName }}</h4>
              <p>{{ count }} Mahasiswa</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import axios from "../service/axios"; 

const rawMahasiswaData = ref([]);
const rawTagihanData = ref([]); 
const isLoading = ref(false);
const errorMessage = ref("");
const filterJurusanChart = ref("");

const API_URL_MAHASISWA = "https://api-mahasiswa-4a.akufarish.my.id:8874/api/mahasiswa";
const API_URL_TAGIHAN = "https://api-keuangan-4a.akufarish.my.id:8873/api/tagihan";

const fetchDashboardData = async () => {
  isLoading.value = true;
  errorMessage.value = "";
  
  const AUTH_TOKEN = localStorage.getItem("token");
  if (!AUTH_TOKEN) {
    errorMessage.value = "Sesi login tidak valid atau token tidak ditemukan. Silakan login kembali.";
    isLoading.value = false;
    return;
  }

  const apiConfig = {
    headers: {
      'Accept': 'application/json',
      'Authorization': `Bearer ${AUTH_TOKEN}`
    }
  };

  try {
    //Ambil data mahasiswa
    const resMhs = await axios.get(API_URL_MAHASISWA, {
      ...apiConfig,
      params: { per_page: 150 }
    });
    if (resMhs.data && resMhs.data.data) {
      rawMahasiswaData.value = resMhs.data.data.data || resMhs.data.data || [];
    }

    //Ambil data tagihan langsung dari API Keuangan
    const resTagihan = await axios.get(API_URL_TAGIHAN, apiConfig);
    if (resTagihan.data && resTagihan.data.data) {
      rawTagihanData.value = Array.isArray(resTagihan.data.data) 
        ? resTagihan.data.data 
        : [resTagihan.data.data];
    }
  } catch (error) {
    console.error("Dashboard API Error:", error);
    if (error.response && error.response.status === 401) {
       errorMessage.value = "Sesi habis (401 Unauthorized). Silakan login kembali.";
    } else {
       errorMessage.value = "Gagal terhubung ke server untuk memuat statistik dashboard.";
    }
  } finally {
    isLoading.value = false;
  }
};

// --- REAL TIME TRACKING LOGIC ---
const totalMahasiswa = computed(() => rawMahasiswaData.value.length);

const belumBayar = computed(() => {
  return rawTagihanData.value.filter(item => item.STATUS_BAYAR && item.STATUS_BAYAR.trim().toUpperCase() === 'BELUM BAYAR').length;
});

const sedangCicil = computed(() => {
  return rawTagihanData.value.filter(item => item.STATUS_BAYAR && item.STATUS_BAYAR.trim().toUpperCase() === 'CICIL').length;
});

const sudahBayar = computed(() => {
  return rawTagihanData.value.filter(item => item.STATUS_BAYAR && item.STATUS_BAYAR.trim().toUpperCase() === 'LUNAS').length;
});

const dataJurusan = computed(() => {
  const urusanObj = {};
  rawMahasiswaData.value.forEach(item => {
    let namaJurusan = item.jurusan || item.nama_jurusan || item.prodi || item.nama_prodi || item.prodi_nama || "Lainnya";
    if (typeof namaJurusan === 'string') {
      namaJurusan = namaJurusan.replace(/teknik\s+/i, "").trim();
      namaJurusan = namaJurusan.charAt(0).toUpperCase() + namaJurusan.slice(1);
    }
    if (!urusanObj[namaJurusan]) urusanObj[namaJurusan] = 0;
    urusanObj[namaJurusan]++;
  });

  if (filterJurusanChart.value) {
    const filtered = {};
    if (urusanObj[filterJurusanChart.value] !== undefined) {
      filtered[filterJurusanChart.value] = urusanObj[filterJurusanChart.value];
    }
    return filtered;
  }
  return urusanObj;
});

const maxMahasiswaDiJurusan = computed(() => {
  const counts = Object.values(dataJurusan.value);
  if (counts.length === 0) return 1;
  return Math.max(...counts);
});

onMounted(() => {
  fetchDashboardData();
});
</script>

<style scoped>
.main-content { padding: 25px; flex: 1; font-family: 'Poppins', sans-serif; background: #f8fafc; }
.topbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
.topbar h1 { font-size: 24px; font-weight: 700; color: #1e293b; }
.subtitle { font-size: 13px; color: #64748b; }

.profile-section { display: flex; align-items: center; gap: 15px; }
.notif-btn { background: white; border: 1px solid #e2e8f0; width: 40px; height: 40px; border-radius: 10px; cursor: pointer; display: flex; align-items: center; justify-content: center; }
.notif-btn svg { width: 20px; color: #64748b; }
.profile-blue { background: #1e3a8a; color: white; padding: 8px 18px; border-radius: 12px; display: flex; align-items: center; gap: 12px; font-size: 13px; font-weight: 500; }
.profile-blue img { width: 28px; height: 28px; border-radius: 50%; }

/* STATS GRID: Sesuai Figma urutan & warnanya */
.stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 25px; }
.stat-card { background: white; padding: 20px; border-radius: 16px; border: 1px solid #e2e8f0; display: flex; align-items: center; gap: 16px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.01); }
.icon-box { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; }
.icon-box svg { width: 24px; height: 24px; }
.stat-card p { font-size: 13px; color: #64748b; font-weight: 500; margin: 0; }
.stat-card h3 { font-size: 24px; font-weight: 700; color: #1e293b; margin-top: 2px; margin-bottom: 0; }

/* Setup Aksen Warna CSS Card Sesuai Figma */
.stat-card.blue .icon-box { background: #eff6ff; color: #2563eb; }
.stat-card.red .icon-box { background: #fef2f2; color: #dc2626; }
.stat-card.orange .icon-box { background: #fffbeb; color: #d97706; }
.stat-card.green .icon-box { background: #f0fdf4; color: #16a34a; }

.dashboard-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 25px; }
.chart-card, .list-card { background: white; border-radius: 16px; border: 1px solid #e2e8f0; padding: 22px; min-height: 320px; }

.chart-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
.chart-header h3 { font-size: 16px; font-weight: 600; color: #1e293b; }
.chart-header select { padding: 8px 12px; border-radius: 8px; border: 1px solid #e2e8f0; font-size: 12px; outline: none; background: #f8fafc; cursor: pointer; }

.bar-chart-container { display: flex; justify-content: space-around; align-items: flex-end; height: 220px; padding-top: 20px; position: relative; }
.bar-group { display: flex; flex-direction: column; align-items: center; flex: 1; height: 100%; justify-content: flex-end; }
.bar-wrapper { width: 35px; height: 160px; background: #f1f5f9; border-radius: 8px; display: flex; align-items: flex-end; position: relative; }
.bar-fill { width: 100%; background: #3b82f6; border-radius: 8px; transition: height 0.6s cubic-bezier(0.4, 0, 0.2, 1); position: relative; cursor: pointer; }
.bar-fill:hover { background: #1d4ed8; }
.bar-label { font-size: 11px; color: #64748b; margin-top: 10px; text-align: center; font-weight: 500; max-width: 80px; text-overflow: ellipsis; overflow: hidden; white-space: nowrap; }

.bar-tooltip { position: absolute; top: -30px; left: 50%; transform: translateX(-50%); background: #1e293b; color: white; padding: 2px 8px; border-radius: 4px; font-size: 10px; font-weight: 600; opacity: 0; transition: 0.2s; pointer-events: none; white-space: nowrap; }
.bar-fill:hover .bar-tooltip { opacity: 1; }

.list-card { display: flex; flex-direction: column; gap: 12px; justify-content: flex-start; overflow-y: auto; max-height: 340px; }
.jurusan-row-item { background: #f8fafc; padding: 14px 18px; border-radius: 12px; border: 1px solid #f1f5f9; }
.jurusan-row-item h4 { font-size: 13px; color: #334155; font-weight: 600; margin: 0; }
.jurusan-row-item p { font-size: 12px; color: #2563eb; font-weight: 700; margin-top: 2px; margin-bottom: 0; }

.loading-state, .error-state { text-align: center; padding: 60px; font-size: 14px; color: #64748b; background: white; border-radius: 16px; border: 1px solid #e2e8f0; margin-top: 20px; }
.error-state { color: #ef4444; font-weight: 500; }
.retry-btn { margin-top: 12px; padding: 8px 20px; background: #3b82f6; color: white; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; font-size: 12px; }
.retry-btn:hover { background: #2563eb; }
.empty-chart, .empty-list { color: #94a3b8; font-size: 13px; text-align: center; width: 100%; }

@media (max-width: 1024px) {
  .stats-grid { grid-template-columns: repeat(2, 1fr); }
}
</style>