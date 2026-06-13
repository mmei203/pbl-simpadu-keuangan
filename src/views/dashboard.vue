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

    <div v-else>
      <section class="stats-grid">
        <div class="stat-card blue">
          <div class="icon-box">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z" /></svg>
          </div>
          <div>
            <p>Total Mahasiswa</p>
            <h3>{{ totalMahasiswa }}</h3>
          </div>
        </div>

        <div class="stat-card green">
          <div class="icon-box">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" /></svg>
          </div>
          <div>
            <p>Sudah Membayar</p>
            <h3>{{ sudahBayar }}</h3>
          </div>
        </div>

        <div class="stat-card red">
          <div class="icon-box">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" d="m9.75 9.75 4.5 4.5m0-4.5-4.5 4.5M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" /></svg>
          </div>
          <div>
            <p>Belum Membayar</p>
            <h3>{{ belumBayar }}</h3>
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
            <div v-for="(count, jurusanName) in dataJurusan" :key="jurusanName" class="bar-group">
              <div class="bar-wrapper">
                <div 
                  class="bar-fill" 
                  :style="{ height: `${(count / (totalMahasiswa || 1)) * 100}%` }"
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

// --- API States ---
const rawMahasiswaData = ref([]);
const isLoading = ref(false);
const errorMessage = ref("");
const filterJurusanChart = ref("");

const BASE_URL = "https://api-mahasiswa-4a.akufarish.my.id:8874/docs/api#/";
const AUTH_TOKEN = localStorage.getItem("token")

// --- HIT DATA MAHASISWA ---
const fetchDashboardData = async () => {
  isLoading.value = true;
  errorMessage.value = "";
  try {
    const response = await axios.get(`${BASE_URL}/keuangan-mahasiswa`, {
      headers: {
        'Accept': 'application/json',
        'Authorization': `Bearer ${AUTH_TOKEN}`
      },
      params: {
        per_page: 1000 // Mengambil data skala besar agar kalkulasi statistik akurat
      }
    });

    const resBody = response.data;
    if (resBody && resBody.success) {
      // Mendukung response pagination (.data.data) maupun array biasa (.data)
      rawMahasiswaData.value = resBody.data.data || resBody.data || [];
    } else {
      errorMessage.value = "Gagal memproses struktur data dashboard.";
    }
  } catch (error) {
    console.error("Dashboard API Error:", error);
    errorMessage.value = "Gagal terhubung ke backend untuk memuat statistik dashboard.";
  } finally {
    isLoading.value = false;
  }
};

// --- LOGIKA HITUNG OTOMATIS (COMPUTED PROPERTYS) ---

// 1. Total Mahasiswa
const totalMahasiswa = computed(() => rawMahasiswaData.value.length);

// 2. Menghitung yang Sudah Membayar (Mencari status 'Lunas' atau 'Paid' / disesuaikan nilai API)
const sudahBayar = computed(() => {
  return rawMahasiswaData.value.filter(item => {
    const status = (item.status_pembayaran || item.STATUS_PEMBAYARAN || item.status || '').toLowerCase();
    return status === 'lunas' || status === 'paid' || status === 'aktif';
  }).length;
});

// 3. Menghitung yang Belum Membayar
const belumBayar = computed(() => {
  return totalMahasiswa.value - sudahBayar.value;
});

// 4. Mengelompokkan & Menghitung Berdasarkan Jurusan
const dataJurusan = computed(() => {
  const urusanObj = {};
  rawMahasiswaData.value.forEach(item => {
    const namaJurusan = item.jurusan || item.JURUSAN || "Lainnya";
    if (!urusanObj[namaJurusan]) {
      urusanObj[namaJurusan] = 0;
    }
    urusanObj[namaJurusan]++;
  });

  // Jika ada filter dropdown aktif, potong objek hanya tampilkan jurusan terpilih
  if (filterJurusanChart.value) {
    const filtered = {};
    if (urusanObj[filterJurusanChart.value] !== undefined) {
      filtered[filterJurusanChart.value] = urusanObj[filterJurusanChart.value];
    }
    return filtered;
  }

  return urusanObj;
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

/* Profile Styles */
.profile-section { display: flex; align-items: center; gap: 15px; }
.notif-btn { background: white; border: 1px solid #e2e8f0; width: 40px; height: 40px; border-radius: 10px; cursor: pointer; display: flex; align-items: center; justify-content: center; }
.notif-btn svg { width: 20px; color: #64748b; }
.profile-blue { background: #1e3a8a; color: white; padding: 8px 18px; border-radius: 12px; display: flex; align-items: center; gap: 12px; font-size: 13px; font-weight: 500; }
.profile-blue img { width: 28px; height: 28px; border-radius: 50%; }

/* Stats Grid Cards */
.stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 25px; }
.stat-card { background: white; padding: 20px; border-radius: 16px; border: 1px solid #e2e8f0; display: flex; align-items: center; gap: 16px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.01); }
.icon-box { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; }
.icon-box svg { width: 24px; height: 24px; }
.stat-card p { font-size: 13px; color: #64748b; font-weight: 500; }
.stat-card h3 { font-size: 24px; font-weight: 700; color: #1e293b; margin-top: 2px; }

.stat-card.blue .icon-box { background: #eff6ff; color: #2563eb; }
.stat-card.green .icon-box { background: #f0fdf4; color: #16a34a; }
.stat-card.red .icon-box { background: #fef2f2; color: #dc2626; }

/* Dashboard Content Grid Layout */
.dashboard-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 25px; }
.chart-card, .list-card { background: white; border-radius: 16px; border: 1px solid #e2e8f0; padding: 22px; }

.chart-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
.chart-header h3 { font-size: 16px; font-weight: 600; color: #1e293b; }
.chart-header select { padding: 8px 12px; border-radius: 8px; border: 1px solid #e2e8f0; font-size: 12px; outline: none; background: #f8fafc; }

/* Custom CSS Bar Chart Graphics */
.bar-chart-container { display: flex; justify-content: space-around; align-items: flex-end; height: 240px; padding-top: 20px; }
.bar-group { display: flex; flex-direction: column; align-items: center; flex: 1; height: 100%; }
.bar-wrapper { width: 35px; height: 85%; background: #f1f5f9; border-radius: 8px; display: flex; align-items: flex-end; position: relative; }
.bar-fill { width: 100%; background: #3b82f6; border-radius: 8px; transition: height 0.6s cubic-bezier(0.4, 0, 0.2, 1); position: relative; cursor: pointer; }
.bar-fill:hover { background: #1d4ed8; }
.bar-label { font-size: 11px; color: #64748b; margin-top: 10px; text-align: center; font-weight: 500; }

/* Tooltip on Hover Chart */
.bar-tooltip { position: absolute; top: -30px; left: 50%; transform: translateX(-50%); background: #1e293b; color: white; padding: 2px 8px; border-radius: 4px; font-size: 10px; font-weight: 600; opacity: 0; transition: 0.2s; pointer-events: none; }
.bar-fill:hover .bar-tooltip { opacity: 1; }

/* Right List Rows */
.list-card { display: flex; flex-direction: column; gap: 12px; justify-content: center; }
.jurusan-row-item { background: #f8fafc; padding: 14px 18px; border-radius: 12px; border: 1px solid #f1f5f9; }
.jurusan-row-item h4 { font-size: 13px; color: #334155; font-weight: 600; }
.jurusan-row-item p { font-size: 12px; color: #2563eb; font-weight: 700; margin-top: 2px; }

.loading-state, .error-state { text-align: center; padding: 60px; font-size: 14px; color: #64748b; background: white; border-radius: 16px; border: 1px solid #e2e8f0; }
.error-state { color: #ef4444; }
</style>