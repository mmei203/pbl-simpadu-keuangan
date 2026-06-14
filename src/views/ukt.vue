<template>
  <div class="main-content">
    <header class="topbar">
      <div>
        <p class="breadcrumb">Manajemen Keuangan > UKT</p>
        <h1>Kelola UKT</h1>
        <p class="subtitle">Perbarui dan pantau data UKT mahasiswa secara real-time</p>
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

    <section class="filter-card">
      <div class="search-box">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="search-icon">
          <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
        </svg>
        <input type="text" v-model="search" @input="debounceSearch" placeholder="Cari Nama atau NIM..." />
      </div>
      
      <div class="filter-group">
        <select v-model="selectedJurusan" @change="fetchDataUkt">
          <option value="">Semua Jurusan</option>
          <option value="Elektro">Teknik Elektro</option>
          <option value="Mesin">Teknik Mesin</option>
          <option value="Sipil">Teknik Sipil</option>
        </select>
        <select v-model="selectedSemester" @change="fetchDataUkt">
          <option value="">Semester</option>
          <option value="2">2</option>
          <option value="4">4</option>
          <option value="6">6</option>
        </select>
      </div>
    </section>

    <EditUkt
      :showEditModal="showEditModal"
      :selectedData="selectedData"
      @close="showEditModal = false"
      @update="handleUpdate"
    />

    <section class="table-card">
      <div class="table-responsive">
        <div v-if="isLoading" class="empty-state">Memuat data keuangan mahasiswa...</div>
        <div v-else-if="errorMessage" class="empty-state error-text">{{ errorMessage }}</div>

        <table v-else class="data-table">
          <thead>
            <tr>
              <th>No</th>
              <th>NIM</th>
              <th>Nama Mahasiswa</th>
              <th>Jurusan / Prodi</th>
              <th>Semester</th>
              <th>Golongan UKT</th>
              <th>Aksi</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, index) in tableData" :key="item.id || index">
              <td>{{ (currentPage - 1) * perPage + index + 1 }}</td>
              
              <td class="font-bold">
                {{ studentCache[item.id_mahasiswa]?.nim || 'Menghubungkan...' }}
              </td>
              
              <td class="nama-mhs">
                {{ studentCache[item.id_mahasiswa]?.nama || 'Loading...' }}
              </td>
              
              <td>
                <div class="jurusan-text">
                  {{ studentCache[item.id_mahasiswa]?.jurusan || 'Teknik Elektro' }}
                </div>
                <div class="prodi-text">
                  {{ studentCache[item.id_mahasiswa]?.prodi || 'D3 Teknik Informatika' }}
                </div>
              </td>
              
              <td>
                <span class="semester-badge">
                  Smstr {{ item.semester || studentCache[item.id_mahasiswa]?.semester || '4' }}
                </span>
              </td>
              
              <td>
                <span class="ukt-badge">
                  {{ item.golongan_ukt || item.ukt || '-' }}
                </span>
              </td>
              
              <td>
                <button class="btn-edit" @click="openEdit(item)">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
                  </svg>
                  Edit
                </button>
              </td>
            </tr>
            <tr v-if="tableData.length === 0">
              <td colspan="7" class="empty-state">Data tidak ditemukan</td>
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
import EditUkt from "./editukt.vue";

const showEditModal = ref(false);
const selectedData = ref(null);
const search = ref("");
const selectedJurusan = ref("");
const selectedSemester = ref("");

const tableData = ref([]);
const isLoading = ref(false);
const errorMessage = ref("");
const currentPage = ref(1);
const lastPage = ref(1);
const perPage = ref(10);
let searchTimeout = null;

const studentCache = reactive({});

const KATEGORI_URL = "https://api-keuangan-4a.akufarish.my.id:8873/api/keuangan-mahasiswa";
const AUTH_TOKEN = localStorage.getItem("token");

// --- UTILITY MANAGEMENT CADANGAN DATA ---
const setLocalFallback = (idMahasiswa, item) => {
  if (!studentCache[idMahasiswa]) {
    studentCache[idMahasiswa] = {
      nim: idMahasiswa ? idMahasiswa.toString().substring(0, 8).toUpperCase() : "MHS-REG",
      nama: item?.nama || "Mahasiswa SIMPADU",
      jurusan: "Teknik Elektro",
      prodi: "D3 Teknik Informatika",
      semester: item?.semester || "4"
    };
  }
};

// --- CORE SINKRONISASI BIODATA LANGSUNG VIA STATUS-AKTIF ENDPOINT ---
const fetchStudentDetailsForCurrentPage = () => {
  tableData.value.forEach(async (item) => {
    const idMhs = item.id_mahasiswa;
    if (!idMhs) return;
    if (studentCache[idMhs] && studentCache[idMhs].nim !== "Menghubungkan...") return;

    try {
      // Menembak endpoint relasi status-aktif milik port 8873 yang menampung gabungan data mhs
      const resStatusAktif = await apiKeuangan.get(`https://api-keuangan-4a.akufarish.my.id:8873/api/status-aktif/${idMhs}`, {
        headers: { 'Authorization': `Bearer ${AUTH_TOKEN}` }
      });
      
      const payload = resStatusAktif.data?.data || resStatusAktif.data;
      
      if (payload) {
        // Ekstraksi data mhs dari object status-aktif atau object bersarang 'mahasiswa'
        const innerMhs = payload.mahasiswa || payload;
        
        studentCache[idMhs] = {
          nim: innerMhs.nim || innerMhs.NIM || payload.nim || "220101002",
          nama: innerMhs.nama || innerMhs.NAMA || payload.nama || "Mahasiswa SIMPADU",
          jurusan: innerMhs.jurusan || "Teknik Elektro",
          prodi: innerMhs.prodi || "D3 Teknik Informatika",
          semester: item.semester || innerMhs.semester || "4"
        };
        return;
      }
      
      setLocalFallback(idMhs, item);
    } catch (err) {
      console.warn(`Gagal fetching status-aktif untuk ID ${idMhs}. Mengaktifkan cadangan.`);
      setLocalFallback(idMhs, item);
    }
  });
};

// --- FETCH UTAMA DATA UKT KEUANGAN ---
const fetchDataUkt = async () => {
  isLoading.value = true;
  errorMessage.value = "";
  try {
    const responseUkt = await apiKeuangan.get(KATEGORI_URL, {
      headers: {
        'Accept': 'application/json',
        'Authorization': `Bearer ${AUTH_TOKEN}`
      },
      params: {
        page: currentPage.value,
        search: search.value,
        jurusan: selectedJurusan.value,
        semester: selectedSemester.value
      }
    });

    const resBodyUkt = responseUkt.data;
    let rawUktData = [];

    if (resBodyUkt) {
      if (resBodyUkt.success && resBodyUkt.data) {
        const mainData = resBodyUkt.data;
        if (mainData.data && Array.isArray(mainData.data)) {
          rawUktData = mainData.data;
          currentPage.value = mainData.current_page || 1;
          lastPage.value = mainData.last_page || 1;
          perPage.value = mainData.per_page || 10;
        } else if (Array.isArray(mainData)) {
          rawUktData = mainData;
        }
      } else if (resBodyUkt.data && resBodyUkt.data.data && Array.isArray(resBodyUkt.data.data)) {
        rawUktData = resBodyUkt.data.data;
        currentPage.value = resBodyUkt.data.current_page || 1;
        lastPage.value = resBodyUkt.data.last_page || 1;
      } else if (Array.isArray(resBodyUkt)) {
        rawUktData = resBodyUkt;
      }
    }

    tableData.value = rawUktData.map(item => ({
      ...item,
      id_mahasiswa: item.id_mahasiswa || item.id || ""
    }));
    
    isLoading.value = false;

    if (tableData.value.length > 0) {
      fetchStudentDetailsForCurrentPage();
    }

  } catch (error) {
    console.error("Gagal Mengambil Data Keuangan:", error);
    isLoading.value = false;
    if (error.response) {
      errorMessage.value = `Error Server (${error.response.status}): ${error.response.data.message || 'Gagal memuat data.'}`;
    } else {
      errorMessage.value = "Tidak ada respon dari server keuangan.";
    }
  }
};

// --- INTERACTION CONTROLLER ---
const debounceSearch = () => {
  clearTimeout(searchTimeout);
  searchTimeout = setTimeout(() => {
    currentPage.value = 1;
    fetchDataUkt();
  }, 500);
};

const changePage = (page) => {
  if (page >= 1 && page <= lastPage.value) {
    currentPage.value = page;
    fetchDataUkt();
  }
};

const openEdit = async (item) => {
  const idKey = item.id || item.id_mahasiswa;
  if (!idKey) {
    alert('ID data tidak ditemukan.');
    return;
  }

  isLoading.value = true;
  try {
    const response = await apiKeuangan.get(`${KATEGORI_URL}/${idKey}`, {
      headers: {
        'Accept': 'application/json',
        'Authorization': `Bearer ${AUTH_TOKEN}`
      }
    });
    const detailData = response.data?.data || response.data;
    selectedData.value = { ...detailData };
    showEditModal.value = true;
  } catch (error) {
    console.error('Gagal memuat detail keuangan:', error);
    alert('Gagal memuat detail modal.');
  } finally {
    isLoading.value = false;
  }
};

const handleUpdate = async (updatedItem) => {
  try {
    const idKey = updatedItem.id || updatedItem.id_mahasiswa;
    await apiKeuangan.put(`${KATEGORI_URL}/${idKey}`, updatedItem, {
      headers: {
        'Accept': 'application/json',
        'Authorization': `Bearer ${AUTH_TOKEN}`
      }
    });
    
    alert("Data Keuangan/UKT Mahasiswa berhasil diperbarui!");
    showEditModal.value = false;
    selectedData.value = null;
    fetchDataUkt();
  } catch (error) {
    console.error("Gagal mengupdate data:", error);
    alert("Gagal memperbarui data ke server.");
  }
};

onMounted(() => {
  fetchDataUkt();
});
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

.main-content {
  padding: 25px;
  flex: 1;
  font-family: 'Poppins', sans-serif;
}

/* TOPBAR STYLE */
.topbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}
.breadcrumb { font-size: 11px; color: #64748b; margin-bottom: 4px; font-weight: 400; }
.topbar h1 { font-size: 24px; font-weight: 700; color: #1e293b; letter-spacing: -0.5px; }
.subtitle { font-size: 13px; color: #64748b; font-weight: 400; }

.profile-section { display: flex; align-items: center; gap: 15px; }
.notif-btn {
  background: white; border: 1px solid #e2e8f0; width: 40px; height: 40px;
  border-radius: 10px; cursor: pointer; display: flex; align-items: center; justify-content: center;
}
.notif-btn svg { width: 20px; color: #64748b; }

.profile-blue {
  background: #1e3a8a; color: white; padding: 8px 18px;
  border-radius: 12px; display: flex; align-items: center; gap: 12px; font-size: 13px; font-weight: 500;
}
.profile-blue img { width: 28px; height: 28px; border-radius: 50%; border: 2px solid rgba(255,255,255,0.2); }

/* FILTER CARD */
.filter-card {
  background: white; padding: 18px 20px; border-radius: 16px;
  border: 1px solid #e2e8f0; display: flex; justify-content: space-between;
  align-items: center; margin-bottom: 25px; gap: 20px;
}
.search-box { position: relative; flex: 1; max-width: 400px; }
.search-icon {
  position: absolute; left: 14px; top: 50%; transform: translateY(-50%);
  width: 18px; color: #94a3b8;
}
.search-box input {
  width: 100%; padding: 11px 15px 11px 42px; border: 1px solid #e2e8f0;
  border-radius: 12px; outline: none; font-size: 13px; font-family: 'Poppins', sans-serif; transition: 0.3s;
}
.search-box input:focus { border-color: #3b82f6; box-shadow: 0 0 0 4px rgba(59,130,246,0.08); }

.filter-group { display: flex; gap: 12px; }
.filter-group select {
  padding: 10px 14px; border: 1px solid #e2e8f0; border-radius: 12px;
  font-size: 13px; font-family: 'Poppins', sans-serif; outline: none; background: #f8fafc; cursor: pointer; color: #475569;
}

/* TABLE STYLE */
.table-card {
  background: white; border-radius: 16px; border: 1px solid #e2e8f0;
  overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.03);
}
.table-responsive { overflow-x: auto; }
.data-table { width: 100%; border-collapse: collapse; text-align: left; }
.data-table th {
  background: #f8fafc; padding: 16px; font-size: 12px;
  text-transform: uppercase; color: #64748b; font-weight: 700;
  border-bottom: 1px solid #e2e8f0; letter-spacing: 0.5px;
}
.data-table td { padding: 16px; border-bottom: 1px solid #f1f5f9; font-size: 14px; color: #334155; }
.font-bold { font-weight: 700; color: #1e3a8a; word-break: break-all; max-width: 150px; }
.nama-mhs { font-weight: 500; color: #1e293b; }

.jurusan-text { font-weight: 600; color: #334155; font-size: 13px; }
.prodi-text { font-size: 12px; color: #64748b; font-weight: 400; }

.semester-badge {
  background: #eff6ff; color: #2563eb; padding: 5px 12px;
  border-radius: 8px; font-size: 11px; font-weight: 600;
}
.ukt-badge {
  background: #f0fdf4; color: #15803d; padding: 5px 12px;
  border-radius: 8px; font-size: 11px; font-weight: 700; border: 1px solid #dcfce7;
}

.btn-edit {
  background: white; border: 1px solid #e2e8f0; padding: 7px 14px;
  border-radius: 10px; cursor: pointer; display: flex; align-items: center;
  gap: 6px; font-size: 12px; font-weight: 600; color: #64748b; transition: 0.2s;
}
.btn-edit svg { width: 15px; }
.btn-edit:hover { border-color: #3b82f6; color: #3b82f6; background: #eff6ff; }

.empty-state { text-align: center; padding: 50px; color: #94a3b8; font-size: 14px; }
.error-text { color: #ef4444; }

/* PAGINATION */
.pagination {
  padding: 20px; display: flex; justify-content: space-between;
  align-items: center; background: #f8fafc; border-top: 1px solid #e2e8f0;
}
.pagination p { font-size: 13px; color: #64748b; font-weight: 400; }
.page-controls { display: flex; gap: 6px; }
.control-btn {
  width: 36px; height: 36px; display: flex; align-items: center;
  justify-content: center; border-radius: 10px; border: 1px solid #e2e8f0;
  background: white; cursor: pointer; font-size: 13px; transition: 0.2s; font-weight: 500;
}
.control-btn.active { background: #1e3a8a; color: white; border-color: #1e3a8a; font-weight: 600; }
.control-btn:disabled { opacity: 0.5; cursor: not-allowed; }
</style>