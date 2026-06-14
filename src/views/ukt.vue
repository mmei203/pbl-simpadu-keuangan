<template>
  <div class="main-content">
    <header class="topbar">
      <div>
        <p class="breadcrumb">Manajemen Keuangan > UKT</p>
        <h1>Kelola UKT</h1>
        <p class="subtitle">Perbarui dan pantau data UKT mahasiswa secara real-time</p>
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
        <select v-model="selectedProdi" @change="fetchDataUkt">
          <option value="">Semua Prodi</option>
          <option value="D3 Teknik Informatika">D3 Teknik Informatika</option>
          <option value="D4 Teknik Informatika">D4 Teknik Informatika</option>
        </select>
        <select v-model="selectedSemester" @change="fetchDataUkt">
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
        <div v-if="isLoading" class="empty-state">Memuat data UKT...</div>
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

              <td class="font-bold">{{ item.nim || "-" }}</td>

              <td class="nama-mhs">
                {{ item.nama_mahasiswa || "Memuat Nama..." }}
              </td>

              <td>
                <div class="jurusan-text">{{ item.jurusan || "Teknik Elektro" }}</div>
                <div class="prodi-text">{{ item.prodi || "D3 Teknik Informatika" }}</div>
              </td>

              <td>
                <span class="semester-badge">Smstr {{ item.semester || "1" }}</span>
              </td>

              <td>
                <span :class="['badge', uktClass(item.golongan_ukt)]">
                  Golongan {{ item.golongan_ukt || "-" }}
                </span>
              </td>

              <td>
                <button class="btn-edit" @click="editUkt(item)">Edit</button>
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

// Sama seperti statusmahasiswa — ref untuk menampung data dari API mahasiswa
const dataMahasiswa = ref([]);

// Cache lokal memory supaya tidak fetch berulang-ulang untuk id mhs yang sama
const biodataCache = reactive({});

// --- SINKRONISASI: Cocokkan data UKT dengan data biodata mahasiswa (port 8874) ---
const loadBiodataBackground = () => {
  tableData.value.forEach((item, idx) => {
    const idMhs = item.id_mahasiswa;
    if (!idMhs) return;

    // Jika sudah ada di cache, langsung pasang tanpa hit API lagi
    if (biodataCache[idMhs]) {
      tableData.value[idx].nama = biodataCache[idMhs].nama;
      tableData.value[idx].nim = biodataCache[idMhs].nim;
      tableData.value[idx].jurusan = biodataCache[idMhs].jurusan;
      tableData.value[idx].prodi = biodataCache[idMhs].prodi;
      return;
    }

    // Cari di dataMahasiswa yang sudah di-fetch oleh getDataMahasiswa()
    if (dataMahasiswa.value && Array.isArray(dataMahasiswa.value)) {
      const found = dataMahasiswa.value.find(
        (m) => String(m.id) === String(idMhs)
      );

      if (found) {
        const info = {
          nama: found.nama || found.nama_mahasiswa || found.NAMA || tableData.value[idx].nama,
          nim: found.nim || found.NIM || tableData.value[idx].nim,
          jurusan: found.jurusan || found.JURUSAN || "Teknik Elektro",
          prodi: found.prodi || found.program_studi || "D3 Teknik Informatika",
        };

        biodataCache[idMhs] = info;

        tableData.value[idx].nama = info.nama;
        tableData.value[idx].nim = info.nim;
        tableData.value[idx].jurusan = info.jurusan;
        tableData.value[idx].prodi = info.prodi;
      }
    }
  });
};

// --- GET DATA MAHASISWA dari API mahasiswa (port 8874) — sama persis seperti di statusmahasiswa ---
async function getDataMahasiswa() {
  try {
    const res = await axios.get(
      `https://api-mahasiswa-4a.akufarish.my.id:8874/api/mahasiswa`,
      {
        timeout: 4000,
        headers: { Accept: "application/json" },
      }
    );
    console.log(res.data.data);

    dataMahasiswa.value = res.data.data;

    // Setelah data mahasiswa berhasil didapat, langsung sinkronisasi ke tableData
    if (tableData.value.length > 0) {
      loadBiodataBackground();
    }
  } catch (error) {
    console.error("Gagal sinkronisasi data mahasiswa:", error);
  }
}

// --- GET LIST UTAMA UKT dari API Keuangan (port 8873) ---
const fetchDataUkt = async () => {
  isLoading.value = true;
  errorMessage.value = "";
  try {
    const response = await apiKeuangan.get(`https://api-keuangan-4a.akufarish.my.id:8873/api/keuangan-mahasiswa/`, {
      params: {
        page: currentPage.value,
        search: search.value,
        jurusan: selectedJurusan.value,
        prodi: selectedProdi.value,
        semester: selectedSemester.value,
      },
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
      } else if (Array.isArray(resBody)) {
        rawData = resBody;
      }
    }

    // Pemetaan data dasar awal — sama seperti di statusmahasiswa
    tableData.value = rawData.map((item) => ({
      ...item,
      id_mahasiswa: item.id_mahasiswa || item.ID_MAHASISWA || item.id || "",
      nama: item.nama || item.nama_mahasiswa || null,
      nim: item.nim || "-",
      jurusan: item.jurusan || "Teknik Elektro",
      prodi: item.prodi || "D3 Teknik Informatika",
      semester: item.semester || "1",
      golongan_ukt: item.golongan_ukt || "-",
    }));

    // Jika dataMahasiswa sudah ada (sudah di-fetch sebelumnya), langsung sinkronisasi
    if (tableData.value.length > 0 && dataMahasiswa.value?.length > 0) {
      setTimeout(() => {
        loadBiodataBackground();
      }, 200);
    }
  } catch (error) {
    console.error("Error Get Data UKT:", error);
    if (error.response && error.response.status === 429) {
      errorMessage.value = "Error Server (429): Terlalu banyak request. Silakan tunggu semenit.";
    } else if (error.response) {
      errorMessage.value = `Error Server (${error.response.status}): ${error.response.data?.message || "Gagal memuat list UKT."}`;
    } else {
      errorMessage.value = "Gagal terhubung ke API keuangan-mahasiswa.";
    }
  } finally {
    isLoading.value = false;
  }
};

const debounceSearch = () => {
  clearTimeout(searchTimeout);
  searchTimeout = setTimeout(() => {
    currentPage.value = 1;
    fetchDataUkt();
  }, 600);
};

const changePage = (page) => {
  if (page >= 1 && page <= lastPage.value) {
    currentPage.value = page;
    tableData.value = [];
    fetchDataUkt();
  }
};

const uktClass = (golongan) => {
  const g = String(golongan);
  if (g === "1") return "badge-success";
  if (g === "2") return "badge-primary";
  if (g === "3") return "badge-warning";
  return "badge-danger";
};

const editUkt = (item) => {
  alert(`Mode Edit UKT untuk: ${item.nama || "-"}\nGolongan Saat Ini: Golongan ${item.golongan_ukt || "-"}`);
};

onMounted(async () => {
  await fetchDataUkt();
  await getDataMahasiswa();
});
</script>

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
.btn-edit { background: white; border: 1px solid #cbd5e1; padding: 6px 16px; border-radius: 8px; cursor: pointer; font-size: 12px; font-weight: 600; color: #334155; }
.btn-edit:hover { border-color: #2563eb; color: #2563eb; background: #f0f9ff; }
.empty-state { text-align: center; padding: 50px; color: #94a3b8; }
.error-text { color: #ef4444; }
.pagination { padding: 20px; display: flex; justify-content: space-between; align-items: center; background: #f8fafc; border-top: 1px solid #e2e8f0; }
.page-controls { display: flex; gap: 6px; }
.control-btn { width: 36px; height: 36px; border-radius: 10px; border: 1px solid #e2e8f0; background: white; cursor: pointer; }
.control-btn.active { background: #1e3a8a; color: white; border-color: #1e3a8a; }
.control-btn:disabled { opacity: 0.5; cursor: not-allowed; }
</style>