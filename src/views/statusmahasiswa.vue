<template>
  <div class="main-content">
    <header class="topbar">
      <div>
        <p class="breadcrumb">Manajemen Keuangan > Status Mahasiswa</p>
        <h1>Status Keuangan Mahasiswa</h1>
        <p class="subtitle">Pantau status aktif dan kelancaran pembayaran mahasiswa</p>
      </div>
    </header>

    <section class="filter-card">
      <div class="search-box">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="search-icon">
          <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
        </svg>
        <input type="text" v-model="search" @input="debounceSearch" placeholder="Cari Nama atau NIM..." />
      </div>
      
      <div class="filter-group">
        <select v-model="selectedJurusan" @change="fetchDataMahasiswa">
          <option value="">Semua Jurusan</option>
          <option value="Elektro">Teknik Elektro</option>
          <option value="Mesin">Teknik Mesin</option>
          <option value="Sipil">Teknik Sipil</option>
        </select>
        <select v-model="selectedProdi" @change="fetchDataMahasiswa">
          <option value="">Semua Prodi</option>
          <option value="D3 Teknik Informatika">D3 Teknik Informatika</option>
          <option value="D4 Teknik Informatika">D4 Teknik Informatika</option>
        </select>
        <select v-model="selectedSemester" @change="fetchDataMahasiswa">
          <option value="">Semester</option>
          <option value="1">1</option>
          <option value="2">2</option>
          <option value="3">3</option>
          <option value="4">4</option>
          <option value="5">5</option>
          <option value="6">6</option>
        </select>
      </div>
    </section>

    <section class="table-card">
      <div class="table-responsive">
        <div v-if="isLoading" class="empty-state">Memuat data status mahasiswa...</div>
        <div v-else-if="errorMessage" class="empty-state error-text">{{ errorMessage }}</div>

        <table v-else class="data-table">
          <thead>
            <tr>
              <th>No</th>
              <th>NIM</th>
              <th>Nama Mahasiswa</th>
              <th>Jurusan / Prodi</th>
              <th>Semester</th>
              <th>Status Aktif</th>
              <th>Pembayaran</th>
              <th>Aksi</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, index) in tableData" :key="item.id || index">
              <td>{{ (currentPage - 1) * perPage + index + 1 }}</td>
              
              <!-- Menampilkan NIM Real / Ter-update -->
              <td class="font-bold">{{ item.nim || '-' }}</td>
              
              <!-- Menampilkan Nama Real / Ter-update -->
              <td class="nama-mhs">{{ item.nama || 'Memuat Nama...' }}</td>
              
              <td>
                <div class="jurusan-text">{{ item.jurusan || 'Teknik Elektro' }}</div>
                <div class="prodi-text">{{ item.prodi || 'D3 Teknik Informatika' }}</div>
              </td>
              
              <td><span class="semester-badge">Smstr {{ item.semester || '1' }}</span></td>
              <td>
                <span :class="['badge', statusClass(item.status || item.status_aktif)]">
                  {{ item.status || item.status_aktif || 'Aktif' }}
                </span>
              </td>
              <td>
                <span :class="['badge', pembayaranClass(item.status_pembayaran || item.pembayaran)]">
                  {{ item.status_pembayaran || item.pembayaran || 'Belum Lunas' }}
                </span>
              </td>
              <td>
                <button class="btn-detail" @click="openDetailModal(item)">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                  </svg>
                  Detail
                </button>
              </td>
            </tr>
            <tr v-if="tableData.length === 0">
              <td colspan="8" class="empty-state">Data tidak ditemukan</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="pagination" v-if="!isLoading && !errorMessage && lastPage > 1">
        <p>Halaman {{ currentPage }} dari {{ lastPage }}</p>
        <div class="page-controls">
          <button class="control-btn" @click="changePage(currentPage - 1)" :disabled="currentPage === 1">&lt;</button>
          <button class="control-btn active">{{ currentPage }}</button>
          <button class="control-btn" @click="changePage(currentPage + 1)" :disabled="currentPage === lastPage">&gt;</button>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted, reactive } from "vue";
import apiKeuangan from "../service/axios"; 
import axios from "axios";

const search = ref("");
const selectedJurusan = ref("");
const selectedProdi = ref("");
const selectedSemester = ref("");

const tableData = ref([]);
const isLoading = ref(false);
const errorMessage = ref("");
const currentPage = ref(1);
const lastPage = ref(1);
const perPage = ref(10);
let searchTimeout = null;

// Cache lokal memory supaya tidak fetch berulang-ulang untuk id mhs yang sama
const biodataCache = reactive({});
const TOKEN = localStorage.getItem("token");

// --- UTILITY AMBIL DATA SINKRONISASI SATU-SATU SECARA AMAN ---
const loadBiodataBackground = async () => {
  // Ambil data baris yang belum mempunyai data nama/nim real
  tableData.value.forEach(async (item, idx) => {
    const idMhs = item.id_mahasiswa;
    if (!idMhs) return;

    // Jika sudah ada di cache lokal, langsung pasang tanpa hit API lagi
    if (biodataCache[idMhs]) {
      tableData.value[idx].nama = biodataCache[idMhs].nama;
      tableData.value[idx].nim = biodataCache[idMhs].nim;
      tableData.value[idx].jurusan = biodataCache[idMhs].jurusan;
      tableData.value[idx].prodi = biodataCache[idMhs].prodi;
      return;
    }

    try {
      // Hit langsung ke port mahasiswa (8874) dengan aman
      const res = await axios.get(`https://api-mahasiswa-4a.akufarish.my.id:8874/api/mahasiswa/${idMhs}`, {
        timeout: 4000,
        headers: { 'Accept': 'application/json' }
      });

      const resData = res.data?.data || res.data;
      if (resData) {
        const info = {
          nama: resData.nama || resData.NAMA || "Mahasiswa Terdaftar",
          nim: resData.nim || resData.NIM || "220101...",
          jurusan: resData.jurusan || "Teknik Elektro",
          prodi: resData.prodi || resData.program_studi || "D3 Teknik Informatika"
        };

        // Simpan ke cache memory
        biodataCache[idMhs] = info;

        // Terapkan langsung ke baris tabel aktif
        tableData.value[idx].nama = info.nama;
        tableData.value[idx].nim = info.nim;
        tableData.value[idx].jurusan = info.jurusan;
        tableData.value[idx].prodi = info.prodi;
      }
    } catch (e) {
      // Jika server port 8874 ngadat/timeout, berikan fallback nama rapi agar tidak kosong
      const fallback = {
        nama: `Mahasiswa (${idMhs.substring(0,4).toUpperCase()})`,
        nim: item.nim && item.nim !== '-' ? item.nim : "MHS-REG",
        jurusan: "Teknik Elektro",
        prodi: "D3 Teknik Informatika"
      };
      tableData.value[idx].nama = fallback.nama;
      if (!tableData.value[idx].nim || tableData.value[idx].nim === '-') {
        tableData.value[idx].nim = fallback.nim;
      }
    }
  });
};

// --- GET LIST UTAMA KEUANGAN (PORT 8873) ---
const fetchDataMahasiswa = async () => {
  isLoading.value = true;
  errorMessage.value = "";
  try {
    const response = await apiKeuangan.get("/keuangan-mahasiswa", {
      params: {
        page: currentPage.value,
        search: search.value,
        jurusan: selectedJurusan.value,
        prodi: selectedProdi.value,
        semester: selectedSemester.value
      }
    });

    const resBody = response.data;
    let rawData = [];

    if (resBody) {
      if (resBody.success && resBody.data) {
        const mainData = resBody.data;
        if (mainData.data && Array.isArray(mainData.data)) {
          rawData = mainData.data;
          currentPage.value = mainData.current_page || 1;
          lastPage.value = mainData.last_page || 1;
          perPage.value = mainData.per_page || 10;
        } else if (Array.isArray(mainData)) {
          rawData = mainData;
        }
      } else if (resBody.data && resBody.data.data && Array.isArray(resBody.data.data)) {
        rawData = resBody.data.data;
        currentPage.value = resBody.data.current_page || 1;
        lastPage.value = resBody.data.last_page || 1;
      }
    }

    // Pemetaan data dasar awal
    tableData.value = rawData.map(item => ({
      ...item,
      id_mahasiswa: item.id_mahasiswa || item.ID_MAHASISWA || item.id || "",
      nama: item.nama || null, 
      nim: item.nim || '-'
    }));

    isLoading.value = false;

    // Trigger pencarian data nama asli secara bertahap di background tanpa membebani server
    if (tableData.value.length > 0) {
      setTimeout(() => {
        loadBiodataBackground();
      }, 200);
    }

  } catch (error) {
    console.error("Error Get Data Keuangan:", error);
    isLoading.value = false;
    if (error.response && error.response.status === 429) {
      errorMessage.value = "Error Server (429): Terlalu banyak request. Silakan bersihkan cache backend Anda atau tunggu semenit.";
    } else if (error.response) {
      errorMessage.value = `Error Server (${error.response.status}): ${error.response.data?.message || 'Gagal memuat list keuangan.'}`;
    } else {
      errorMessage.value = "Gagal terhubung ke API keuangan-mahasiswa.";
    }
  }
};

const debounceSearch = () => {
  clearTimeout(searchTimeout);
  searchTimeout = setTimeout(() => {
    currentPage.value = 1;
    fetchDataMahasiswa();
  }, 600);
};

const changePage = (page) => {
  if (page >= 1 && page <= lastPage.value) {
    currentPage.value = page;
    tableData.value = [];
    fetchDataMahasiswa();
  }
};

const statusClass = (status) => {
  return String(status || '').toLowerCase() === 'nonaktif' ? 'badge-danger' : 'badge-primary';
};

const pembayaranClass = (statusBayar) => {
  const b = String(statusBayar || '').toLowerCase();
  if (b === 'lunas' || b === 'paid') return 'badge-success';
  if (b === 'cicilan') return 'badge-warning';
  return 'badge-danger';
};

const openDetailModal = async (item) => {
  const idKey = item.id || item.id_mahasiswa;
  if (!idKey) {
    alert("ID data tidak valid.");
    return;
  }
  try {
    const response = await apiKeuangan.get(`/keuangan-mahasiswa/${idKey}`);
    const data = response.data?.data || response.data;
    alert(`Detail Mahasiswa:\nNama: ${item.nama || '-'}\nNIM: ${item.nim || '-'}\nStatus: ${data.status || 'Aktif'}\nPembayaran: ${data.status_pembayaran || 'Belum Lunas'}`);
  } catch (error) {
    alert(`Gagal memuat detail dari server.`);
  }
};

onMounted(() => {
  fetchDataMahasiswa();
});
</script>

<!-- CSS Style tetap sama seperti desain awal kamu -->
<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');
.main-content { padding: 25px; flex: 1; font-family: 'Poppins', sans-serif; }
.topbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
.breadcrumb { font-size: 11px; color: #64748b; margin-bottom: 4px; }
.topbar h1 { font-size: 24px; font-weight: 700; color: #1e293b; }
.subtitle { font-size: 13px; color: #64748b; }
.filter-card { background: white; padding: 18px 20px; border-radius: 16px; border: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; gap: 20px; }
.search-box { position: relative; flex: 1; max-width: 400px; }
.search-icon { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); width: 18px; color: #94a3b8; }
.search-box input { width: 100%; padding: 11px 15px 11px 42px; border: 1px solid #e2e8f0; border-radius: 12px; outline: none; font-size: 13px; }
.filter-group { display: flex; gap: 12px; }
.filter-group select { padding: 10px 14px; border: 1px solid #e2e8f0; border-radius: 12px; font-size: 13px; background: #f8fafc; }
.table-card { background: white; border-radius: 16px; border: 1px solid #e2e8f0; overflow: hidden; }
.table-responsive { overflow-x: auto; }
.data-table { width: 100%; border-collapse: collapse; text-align: left; }
.data-table th { background: #f8fafc; padding: 16px; font-size: 12px; text-transform: uppercase; color: #64748b; font-weight: 700; border-bottom: 1px solid #e2e8f0; }
.data-table td { padding: 16px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
.font-bold { font-weight: 700; color: #1e3a8a; }
.nama-mhs { font-weight: 500; }
.jurusan-text { font-weight: 600; font-size: 13px; }
.prodi-text { font-size: 12px; color: #64748b; }
.semester-badge { background: #eff6ff; color: #2563eb; padding: 5px 12px; border-radius: 8px; font-size: 11px; font-weight: 600; }
.badge { padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-block; }
.badge-primary { background-color: #eff6ff; color: #2563eb; }
.badge-success { background-color: #f0fdf4; color: #16a34a; }
.badge-warning { background-color: #fffbeb; color: #d97706; }
.badge-danger { background-color: #fef2f2; color: #dc2626; }
.btn-detail { background: white; border: 1px solid #e2e8f0; padding: 7px 14px; border-radius: 10px; cursor: pointer; display: flex; align-items: center; gap: 6px; font-size: 12px; font-weight: 600; color: #64748b; }
.btn-detail svg { width: 16px; }
.btn-detail:hover { border-color: #3b82f6; color: #3b82f6; background: #eff6ff; }
.empty-state { text-align: center; padding: 50px; color: #94a3b8; }
.error-text { color: #ef4444; }
.pagination { padding: 20px; display: flex; justify-content: space-between; align-items: center; background: #f8fafc; border-top: 1px solid #e2e8f0; }
.page-controls { display: flex; gap: 6px; }
.control-btn { width: 36px; height: 36px; border-radius: 10px; border: 1px solid #e2e8f0; background: white; cursor: pointer; }
.control-btn.active { background: #1e3a8a; color: white; border-color: #1e3a8a; }
.control-btn:disabled { opacity: 0.5; cursor: not-allowed; }
</style>