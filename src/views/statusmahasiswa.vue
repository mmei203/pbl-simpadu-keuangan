<template>
  <div class="main-content">
    <header class="page-header">
      <div>
        <p class="breadcrumbs">Manajemen Keuangan > Status Mahasiswa</p>
        <h1>Status Mahasiswa</h1>
        <p class="subtitle">Kelola Status Mahasiswa</p>
      </div>
    </header>

    <div class="table-container">
      <div class="filter-action-bar">
        <div class="search-box">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="search-icon">
            <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.602 10.602Z" />
          </svg>
          <input 
            type="text" 
            v-model="search" 
            @input="debounceSearch" 
            placeholder="Cari Mahasiswa..." 
          />
        </div>

        <div class="dropdown-group">
          <select v-model="selectedJurusan" @change="fetchDataMahasiswa">
            <option value="">Jurusan</option>
            <option value="Elektro">Elektro</option>
            <option value="Mesin">Mesin</option>
            <option value="Sipil">Sipil</option>
            <option value="Akuntansi">Akuntansi</option>
            <option value="Bisnis">Bisnis</option>
          </select>

          <select v-model="selectedProdi" @change="fetchDataMahasiswa">
            <option value="">Prodi</option>
            <option value="Teknik Informatika">Teknik Informatika</option>
            <option value="Teknik Listrik">Teknik Listrik</option>
            <option value="Teknik Mesin">Teknik Mesin</option>
          </select>

          <select v-model="selectedSemester" @change="fetchDataMahasiswa">
            <option value="">Semester</option>
            <option v-for="n in 8" :key="n" :value="n">{{ n }}</option>
          </select>
        </div>
      </div>

      <div v-if="isLoading" class="state-message">Mengambil data mahasiswa dari server port 8874...</div>

      <div v-else class="responsive-table">
        <table>
          <thead>
            <tr>
              <th>No</th>
              <th>NIM</th>
              <th>Nama</th>
              <th>Jurusan</th>
              <th>Prodi</th>
              <th>Semester</th>
              <th>Status</th>
              <th>Pembayaran</th>
              <th>Aksi</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, index) in tableData" :key="item.id || item.nim || index">
              <td>{{ (currentPage - 1) * perPage + index + 1 }}</td>
              <td class="font-semibold">{{ item.nim || item.NIM || '-' }}</td>
              <td>{{ item.nama || item.NAMA || '-' }}</td>
              <td>{{ item.jurusan || 'Elektro' }}</td>
              <td>{{ item.prodi || 'Teknik Informatika' }}</td>
              <td>{{ item.semester || item.smt || '4' }}</td>
              <td>
                <span class="badge" :class="statusClass(item.status || item.status_aktif)">
                  {{ item.status || item.status_aktif || 'Aktif' }}
                </span>
              </td>
              <td>
                <span class="badge" :class="pembayaranClass(item.status_pembayaran || item.pembayaran)">
                  {{ item.status_pembayaran || item.pembayaran || 'Belum' }}
                </span>
              </td>
              <td>
                <button class="edit-btn" @click="openEditModal(item)">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
                  </svg>
                </button>
              </td>
            </tr>
            <tr v-if="tableData.length === 0">
              <td colspan="9" class="text-center py-4" style="color: #64748b; font-style: italic;">
                Data mahasiswa Kosong Di Server.
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="pagination-bar" v-if="tableData.length > 0">
        <button class="page-nav" :disabled="currentPage === 1" @click="changePage(currentPage - 1)">
          &larr; Previous
        </button>
        <div class="page-numbers">
          <button 
            v-for="page in lastPage" 
            :key="page" 
            class="page-num" 
            :class="{ active: page === currentPage }"
            @click="changePage(page)"
          >
            {{ page }}
          </button>
        </div>
        <button class="page-nav" :disabled="currentPage === lastPage" @click="changePage(currentPage + 1)">
          Next &rarr;
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import axios from "../service/axios";

// --- State UI & Filter ---
const search = ref("");
const selectedJurusan = ref("");
const selectedProdi = ref("");
const selectedSemester = ref("");

// --- State Data ---
const tableData = ref([]);
const isLoading = ref(false);
const errorMessage = ref("");
const currentPage = ref(1);
const lastPage = ref(1);
const perPage = ref(10);
let searchTimeout = null;

// Mengarah langsung ke API Master Mahasiswa Port 8874
const BASE_URL = "https://api-keuangan-4a.akufarish.my.id:8873/api/keuangan-mahasiswa"; 

const fetchDataMahasiswa = async () => {
  isLoading.value = true;
  errorMessage.value = "";
  try {
    const authToken = localStorage.getItem("token") || "";
    const headers = {
      'Accept': 'application/json',
      ...(authToken ? { 'Authorization': `Bearer ${authToken}` } : {})
    };

    // Menembak endpoint /mahasiswa dengan konfigurasi Header murni (Bearer Auth)
    const response = await axios.get(`${BASE_URL}/mahasiswa`, {
      headers,
      params: {
        page: currentPage.value,
        search: search.value,
        jurusan: selectedJurusan.value,
        prodi: selectedProdi.value,
        semester: selectedSemester.value
      }
    });

    console.log("=== API 8874 MAHASISWA SUCCESS ===", response.data);
    const resBody = response.data;

    // Normalisasi pembacaan response data dari Laravel
    if (resBody) {
      if (Array.isArray(resBody)) {
        tableData.value = resBody;
        lastPage.value = 1;
      } else if (resBody.data && resBody.data.data && Array.isArray(resBody.data.data)) {
        tableData.value = resBody.data.data;
        currentPage.value = resBody.data.current_page || 1;
        lastPage.value = resBody.data.last_page || 1;
        perPage.value = resBody.data.per_page || 10;
      } else if (resBody.data && Array.isArray(resBody.data)) {
        tableData.value = resBody.data;
        lastPage.value = 1;
      } else {
        tableData.value = [];
      }
    } else {
      tableData.value = [];
    }
  } catch (error) {
    console.error("Detail Error Port 8874:", error);
    
    // Menampilkan pesan error asli dari response Laravel agar mudah di-debug
    if (error.response && error.response.data) {
      errorMessage.value = `Error Server (${error.response.status}): ${error.response.data.message || 'Token / Akses Ditolak'}`;
    } else {
      errorMessage.value = "Gagal terhubung ke API Master Mahasiswa (Port 8874). Periksa koneksi jaringan atau CORS.";
    }
  } finally {
    isLoading.value = false;
  }
};

const debounceSearch = () => {
  clearTimeout(searchTimeout);
  searchTimeout = setTimeout(() => {
    currentPage.value = 1;
    fetchDataMahasiswa();
  }, 500);
};

const changePage = (page) => {
  if (page >= 1 && page <= lastPage.value) {
    currentPage.value = page;
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

const openEditModal = (item) => {
  alert(`Detail Mahasiswa: ${item.nama || item.NAMA}`);
};

onMounted(() => {
  fetchDataMahasiswa();
});
</script>

<style scoped>
.main-content { padding: 24px; background: #f8fafc; min-height: 100vh; font-family: 'Poppins', sans-serif; }
.breadcrumbs { font-size: 11px; color: #64748b; margin-bottom: 4px; }
.page-header h1 { font-size: 24px; font-weight: 700; color: #1e293b; }
.subtitle { font-size: 12px; color: #94a3b8; }
.table-container { background: white; border-radius: 16px; border: 1px solid #e2e8f0; margin-top: 24px; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.02); }
.filter-action-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; gap: 15px; }
.search-box { position: relative; width: 300px; }
.search-box input { width: 100%; padding: 9px 12px 9px 36px; border-radius: 10px; border: 1px solid #cbd5e1; outline: none; font-size: 13px; transition: 0.2s; }
.search-box input:focus { border-color: #3b82f6; box-shadow: 0 0 0 3px rgba(59,130,246,0.1); }
.search-icon { width: 16px; position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #94a3b8; }
.dropdown-group { display: flex; gap: 10px; }
.dropdown-group select { padding: 9px 14px; border-radius: 10px; border: 1px solid #cbd5e1; font-size: 13px; color: #334155; background: #f8fafc; outline: none; cursor: pointer; }
.responsive-table { overflow-x: auto; }
table { width: 100%; border-collapse: collapse; text-align: left; font-size: 13px; }
th { background: #f1f5f9; color: #475569; padding: 14px; font-weight: 600; border-bottom: 2px solid #e2e8f0; }
td { padding: 14px; border-bottom: 1px solid #f1f5f9; color: #334155; vertical-align: middle; }
.font-semibold { font-weight: 600; color: #0f172a; }
.badge { padding: 6px 14px; border-radius: 20px; font-size: 11px; font-weight: 600; display: inline-block; text-align: center; min-width: 75px; }
.badge-primary { background: #e0e7ff; color: #4f46e5; }
.badge-success { background: #dcfce7; color: #15803d; }
.badge-warning { background: #fef9c3; color: #a16207; }
.badge-danger { background: #fee2e2; color: #b91c1c; }
.edit-btn { background: none; border: 1px solid #cbd5e1; padding: 6px; border-radius: 8px; cursor: pointer; color: #4f46e5; display: inline-flex; align-items: center; justify-content: center; transition: 0.2s; }
.edit-btn:hover { background: #f1f5f9; border-color: #4f46e5; }
.edit-btn svg { width: 16px; height: 16px; }
.pagination-bar { display: flex; justify-content: space-between; align-items: center; margin-top: 20px; padding-top: 15px; border-top: 1px solid #f1f5f9; }
.page-nav { padding: 8px 14px; border-radius: 8px; border: 1px solid #cbd5e1; background: white; font-size: 12px; font-weight: 500; cursor: pointer; color: #475569; }
.page-nav:disabled { opacity: 0.5; cursor: not-allowed; }
.page-numbers { display: flex; gap: 5px; }
.page-num { width: 32px; height: 32px; border-radius: 6px; border: 1px solid #cbd5e1; background: white; font-size: 12px; font-weight: 600; cursor: pointer; display: flex; align-items: center; justify-content: center; color: #475569; }
.page-num.active { background: #4f46e5; color: white; border-color: #4f46e5; }
.state-message { text-align: center; padding: 40px; font-size: 13px; color: #64748b; }
.state-message.error { color: #ef4444; font-weight: 500; }
</style>