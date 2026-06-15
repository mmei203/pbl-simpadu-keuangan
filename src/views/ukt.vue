<template>
  <div class="main-content">

    <EditUkt
      :showEditModal="showEditModal"
      :selectedData="dataForEdit"
      @close="showEditModal = false"
      @update="handleAfterUpdate"
    />

    <header class="topbar">
      <div>
        <p class="breadcrumb">Manajemen Keuangan &gt; UKT</p>
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
              <td class="nama-mhs">{{ item.nama || "-" }}</td>
              <td>
                <div class="jurusan-text">{{ item.jurusan_clean?.name || item.jurusan_clean || "Teknik Elektro" }}</div>
                <div class="prodi-text">{{ item.prodi_clean || "D3 Teknik Informatika" }}</div>
              </td>
              <td>
                <span class="semester-badge">Smstr {{ item.semester || "1" }}</span>
              </td>
              <td>
                <span :class="['badge', uktClass(item.golongan_ukt)]">
                  {{ item.golongan_ukt_nama }}
                </span>
              </td>
              <td>
                <button class="btn-edit" @click="openEditModal(item)">Edit</button>
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
import { ref, onMounted } from "vue";
import apiKeuangan from "../service/axios";
import axios from "axios";
import EditUkt from "./editukt.vue";

const search           = ref("");
const selectedJurusan  = ref("");
const selectedProdi    = ref("");
const selectedSemester = ref("");

const tableData    = ref([]);
const isLoading    = ref(false);
const errorMessage = ref("");
const currentPage  = ref(1);
const lastPage     = ref(1);
const perPage      = ref(10);
let searchTimeout  = null;

// Modal state
const showEditModal = ref(false);
const dataForEdit   = ref(null);

const openEditModal = (item) => {
  dataForEdit.value   = { ...item };
  showEditModal.value = true;
};

const handleAfterUpdate = () => {
  showEditModal.value = false;
  fetchDataUkt();
};

async function fetchDataUkt() {
  isLoading.value    = true;
  errorMessage.value = "";
  try {
    const token = localStorage.getItem("token");
    const headersConfig = {
      Accept: "application/json",
      ...(token && { Authorization: `Bearer ${token}` }),
    };

    // 1. PANGGIL PARALEL API
    const [resMahasiswa, resProdi, resKeuangan, resKategoriUkt] = await Promise.all([
      axios.get(`https://api-mahasiswa-4a.akufarish.my.id:8874/api/mahasiswa`, {
        timeout: 10000,
        headers: headersConfig,
        params: {
          page:     currentPage.value,
          search:   search.value,
          jurusan:  selectedJurusan.value,
          prodi:    selectedProdi.value,
          semester: selectedSemester.value,
        },
      }),
      axios.get(`https://be.karlearn.site/api/prodi`, {
        timeout: 10000,
        headers: headersConfig,
      }),
      apiKeuangan.get(`https://api-keuangan-4a.akufarish.my.id:8873/api/keuangan-mahasiswa`, {
        headers: headersConfig,
      }),
      apiKeuangan.get(`https://api-keuangan-4a.akufarish.my.id:8873/api/kategori-ukt`, {
        headers: headersConfig,
      }),
    ]);

    // ── Parse Mahasiswa Utama ──
    const mhsBody = resMahasiswa.data;
    let listMahasiswa = [];
    if (mhsBody?.data?.data) {
      listMahasiswa     = mhsBody.data.data;
      currentPage.value = mhsBody.data.current_page || 1;
      lastPage.value    = mhsBody.data.last_page    || 1;
      perPage.value     = mhsBody.data.per_page     || 10;
    } else {
      listMahasiswa = mhsBody.data || mhsBody || [];
    }

    if (!Array.isArray(listMahasiswa)) {
      tableData.value = [];
      return;
    }

    // ── Parse Data Pendukung ──
    const listProdi       = resProdi.data?.data || resProdi.data || [];
    const keuBody         = resKeuangan.data;
    const listKeuangan    = keuBody?.data?.data || keuBody?.data || keuBody || [];
    
    const kategoriUktBody = resKategoriUkt.data;
    const listKategoriUkt = kategoriUktBody?.data?.data || kategoriUktBody?.data || kategoriUktBody || [];

    // ── LOOPING & MAPPING DATA MAHASISWA ──
    tableData.value = listMahasiswa.map((mahasiswa) => {
      const nimMhs = String(mahasiswa.nim || mahasiswa.NIM || "").trim();
      const idMhsUtama = String(mahasiswa.id || mahasiswa.ID || mahasiswa.id_mahasiswa || "").trim();

      // 1. CARI RELASI KEUANGAN (Gunakan multi-kondisi ID & NIM demi akurasi)
      const keuanganMatch = Array.isArray(listKeuangan)
        ? listKeuangan.find((k) => {
            const idKeuMhs = String(k.id_mahasiswa || k.ID_MAHASISWA || k.id || k.ID || "").trim();
            const nimKeuMhs = String(k.nim || k.NIM || "").trim();
            
            // Cocokkan berdasarkan ID Mahasiswa atau berdasarkan NIM
            const matchById = (idMhsUtama !== "" && idKeuMhs !== "") && (idMhsUtama === idKeuMhs);
            const matchByNim = (nimMhs !== "" && nimKeuMhs !== "") && (nimMhs === nimKeuMhs);
            
            return matchById || matchByNim;
          })
        : null;

      // 2. AMBIL ID KATEGORI UKT (Cek semua kemungkinan properti pembungkus)
      const idKategoriUktMatch = keuanganMatch?.ID_KATEGORI || 
                                 keuanganMatch?.id_kategori_ukt || 
                                 keuanganMatch?.keuangan_mahasiswa?.ID_KATEGORI ||
                                 keuanganMatch?.kategori_ukt?.ID_KATEGORI || null;

      // 3. CARI KE MASTER KATEGORI UKT
      const kategoriMatch = (idKategoriUktMatch && Array.isArray(listKategoriUkt))
        ? listKategoriUkt.find((kat) => String(kat.ID_KATEGORI || kat.id).trim() === String(idKategoriUktMatch).trim())
        : null;

      // 4. SINKRONISASI TEKS GOLONGAN
      let namaGolonganFinal = "-";
      if (kategoriMatch?.GOLONGAN_UKT || kategoriMatch?.golongan_ukt) {
        namaGolonganFinal = kategoriMatch.GOLONGAN_UKT || kategoriMatch.golongan_ukt;
      } else if (keuanganMatch?.keuangan_mahasiswa?.kategori_ukt?.GOLONGAN_UKT) {
        namaGolonganFinal = keuanganMatch.keuangan_mahasiswa.kategori_ukt.GOLONGAN_UKT;
      } else if (keuanganMatch?.kategori_ukt?.GOLONGAN_UKT) {
        namaGolonganFinal = keuanganMatch.kategori_ukt.GOLONGAN_UKT;
      } else if (keuanganMatch?.GOLONGAN_UKT || keuanganMatch?.golongan_ukt) {
        namaGolonganFinal = keuanganMatch.GOLONGAN_UKT || keuanganMatch.golongan_ukt;
      }

      // Logika Pembersihan Data Jurusan & Prodi
      const targetProdiId = mahasiswa.PRODI_ID || mahasiswa.prodi_id;
      let rawJurusan = mahasiswa.jurusan?.name || mahasiswa.jurusan?.nama || mahasiswa.nama_jurusan || mahasiswa.jurusan || "";
      let rawProdi = mahasiswa.prodi?.name || mahasiswa.prodi?.nama || mahasiswa.nama_prodi || mahasiswa.prodi || "";
      const gabunganTeksMentah = `${String(rawJurusan)} ${String(rawProdi)}`.toLowerCase();

      const prodiDitemukan = Array.isArray(listProdi)
        ? listProdi.find((p) => String(p.id).trim() === String(targetProdiId).trim())
        : null;

      let finalJurusan = "", finalProdi = "";

      if (prodiDitemukan) {
        finalJurusan = prodiDitemukan.nama_jurusan || prodiDitemukan.jurusan || "";
        finalProdi   = prodiDitemukan.nama_prodi || prodiDitemukan.name || prodiDitemukan.nama || "";
      } else {
        if (gabunganTeksMentah.includes("informatika") || gabunganTeksMentah.includes("ti")) {
          finalJurusan = "Teknik Elektro";
          finalProdi = gabunganTeksMentah.includes("d4") ? "D4 Teknik Informatika" : "D3 Teknik Informatika";
        } else if (gabunganTeksMentah.includes("mesin")) {
          finalJurusan = "Teknik Mesin";
          finalProdi = "D3 Teknik Mesin";
        } else if (gabunganTeksMentah.includes("sipil")) {
          finalJurusan = "Teknik Sipil";
          finalProdi = "D3 Teknik Sipil";
        } else {
          finalJurusan = "Teknik Elektro";
          finalProdi = "D3 Teknik Informatika";
        }
      }

      return {
        ...mahasiswa,
        id:                mahasiswa.id || mahasiswa.ID,
        nama:              mahasiswa.NAMA || mahasiswa.nama || mahasiswa.nama_mahasiswa || "-",
        nim:               nimMhs !== "" ? nimMhs : "-",
        semester:          mahasiswa.SEMESTER || mahasiswa.semester || "1",
        jurusan_clean:     finalJurusan,
        prodi_clean:       finalProdi,
        golongan_ukt:      namaGolonganFinal, 
        golongan_ukt_nama: namaGolonganFinal, 
        id_kategori_ukt:   idKategoriUktMatch,
        keuangan_id:       keuanganMatch?.id || keuanganMatch?.ID_KEUANGAN_MHS || keuanganMatch?.ID_KEUANGAN || null
      };
    });

    console.log("Data Kelola UKT Sinkronisasi Terbaru:", tableData.value);

  } catch (error) {
    console.error("Error fetchDataUkt:", error);
    if (error.response?.status === 429) {
      errorMessage.value = "Error Server (429): Terlalu banyak request. Silakan tunggu.";
    } else if (error.response) {
      errorMessage.value = `Error Server (${error.response.status}): ${error.response.data?.message || "Gagal memuat data UKT."}`;
    } else {
      errorMessage.value = "Gagal terhubung ke server.";
    }
  } finally {
    isLoading.value = false;
  }
}

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
    tableData.value   = [];
    fetchDataUkt();
  }
};

const uktClass = (golongan) => {
  const g = String(golongan).toLowerCase();
  if (g.includes("1")) return "badge-success";
  if (g.includes("2")) return "badge-primary";
  if (g.includes("3")) return "badge-warning";
  return "badge-danger";
};

onMounted(() => fetchDataUkt());
</script>

<style scoped>
@import url("https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap");
.main-content { padding: 25px; flex: 1; font-family: "Poppins", sans-serif; }
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
.badge-danger  { background-color: #fef2f2; color: #dc2626; }
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