<template>
  <div class="main-content">

    <!-- Modal Edit Mahasiswa -->
    <EditMahasiswa
      :showEditModal="showEditModal"
      :selectedData="dataForEdit"
      @close="showEditModal = false"
      @update="handleAfterUpdate"
    />
    <header class="topbar">
      <div>
        <p class="breadcrumb">Manajemen Keuangan > Status Mahasiswa</p>
        <h1>Status Keuangan Mahasiswa</h1>
        <p class="subtitle">
          Pantau status aktif dan kelancaran pembayaran mahasiswa
        </p>
      </div>
    </header>

    <section class="filter-card">
      <div class="search-box">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="search-icon"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"
          />
        </svg>
        <input
          type="text"
          v-model="search"
          @input="debounceSearch"
          placeholder="Cari Nama atau NIM..."
        />
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
        
        <div v-if="isLoading" class="empty-state">
          Memuat data status keuangan mahasiswa...
        </div>
        <div v-else-if="errorMessage" class="empty-state error-text">
          {{ errorMessage }}
        </div>

        <table v-else class="data-table">
          <thead>
            <tr>
              <th>No</th>
              <th>NIM</th>
              <th>Nama Mahasiswa</th>
              <th>Jurusan / Prodi</th>
              <th>Semester</th>
              <th>Pembayaran</th>
              <th>Aksi</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, index) in dataMahasiswa" :key="item.id || index">
              <td>{{ (currentPage - 1) * perPage + index + 1 }}</td>

              <td class="font-bold">{{ item.nim }}</td>

              <td class="nama-mhs">
                {{ item.nama_mahasiswa }}
              </td>

              <td>
                <div class="jurusan-text">
                  {{ item.jurusan_clean.name }}
                </div>
                <div class="prodi-text">
                  {{ item.prodi_clean }}
                </div>
              </td>

              <td>
                <span class="semester-badge">Smstr {{ item.semester }}</span>
              </td>

              <td>
                <span
                  :class="[
                    'badge',
                    pembayaranClass(item.tagihan.STATUS_AKTIF),
                  ]"
                >
                  {{ item.tagihan.STATUS_AKTIF }}
                </span>
              </td>
              <td>
                <button class="btn-detail" @click="openDetailModal(item)">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke-width="1.5"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z"
                    />
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"
                    />
                  </svg>
                  Detail
                </button>
              </td>
            </tr>
            <tr v-if="dataMahasiswa && dataMahasiswa.length === 0">
              <td colspan="7" class="empty-state">Data tidak ditemukan</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div
        class="pagination"
        v-if="!isLoading && !errorMessage && lastPage > 1"
      >
        <p>Halaman {{ currentPage }} dari {{ lastPage }}</p>
        <div class="page-controls">
          <button
            class="control-btn"
            @click="changePage(currentPage - 1)"
            :disabled="currentPage === 1"
          >
            &lt;
          </button>
          <button class="control-btn active">{{ currentPage }}</button>
          <button
            class="control-btn"
            @click="changePage(currentPage + 1)"
            :disabled="currentPage === lastPage"
          >
            &gt;
          </button>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import apiKeuangan from "../service/axios";
import axios from "axios";
import EditMahasiswa from "./editmahasiswa.vue";

const search = ref("");
const selectedJurusan = ref("");
const selectedProdi = ref("");
const selectedSemester = ref("");

const isLoading = ref(false);
const errorMessage = ref("");
const currentPage = ref(1);
const lastPage = ref(1);
const perPage = ref(10);
let searchTimeout = null;

const dataMahasiswa = ref([]);

const loadKeuanganBackground = async () => {
  try {
    const responseKeuangan = await apiKeuangan.get("/keuangan-mahasiswa");
    const listKeuangan = responseKeuangan.data?.data?.data || responseKeuangan.data?.data || responseKeuangan.data || [];

    if (Array.isArray(listKeuangan) && dataMahasiswa.value.length > 0) {
      dataMahasiswa.value = dataMahasiswa.value.map((mhs) => {
        const keuanganDetail = listKeuangan.find(
          (k) => String(k.id_mahasiswa || k.ID_MAHASISWA || k.mahasiswa_id || k.id).toLowerCase().trim() === String(mhs.id).toLowerCase().trim()
        );
        return {
          ...mhs,
          status_pembayaran: keuanganDetail?.status_pembayaran || keuanganDetail?.pembayaran || "Belum Lunas"
        };
      });
    }
  } catch (err) {
    console.error("Gagal sinkronisasi data keuangan di background:", err);
  }
};

async function fetchDataMahasiswa() {
  isLoading.value = true;
  errorMessage.value = "";
  try {
    const token = localStorage.getItem("token");
    const headersConfig = {
      Accept: "application/json",
      ...(token && { Authorization: `Bearer ${token}` }),
    };

    // 1. Jalankan 3 request secara paralel demi mendapatkan data relasi yang lengkap
    const [resMahasiswa, resProdi, resKeuangan, resTagihan] = await Promise.all([
      axios.get(`https://api-mahasiswa-4a.akufarish.my.id:8874/api/mahasiswa`, {
        timeout: 10000,
        headers: headersConfig,
        params: {
          page: currentPage.value,
          search: search.value,
          jurusan: selectedJurusan.value,
          prodi: selectedProdi.value,
          semester: selectedSemester.value,
        },
      }),
      axios.get(`https://be.karlearn.site/api/prodi`, {
        timeout: 10000,
        headers: headersConfig,
      }),
      apiKeuangan.get(`https://api-keuangan-4a.akufarish.my.id:8873/api/keuangan-mahasiswa`, {
        headers: headersConfig
      }),
      apiKeuangan.get(`https://api-keuangan-4a.akufarish.my.id:8873/api/tagihan`, {
        headers: headersConfig
      })
    ]);

    const resMhsBody = resMahasiswa.data;
    const listProdi = resProdi.data?.data || resProdi.data || [];
    const listKeuangan = resKeuangan.data?.data?.data || resKeuangan.data?.data || resKeuangan.data || [];
    const listTagihan = resTagihan.data?.data || resTagihan.data || [];

    let listMahasiswa = [];
    if (resMhsBody?.data?.data) {
        listMahasiswa = resMhsBody.data.data;
        currentPage.value = resMhsBody.data.current_page || 1;
        lastPage.value = resMhsBody.data.last_page || 1;
    } else {
        listMahasiswa = resMhsBody.data || resMhsBody || [];
    }

    if (!Array.isArray(listMahasiswa)) {
      dataMahasiswa.value = [];
      return;
    }

    // 2. Mapping & Penggabungan Data Menggunakan Jembatan Keuangan
    dataMahasiswa.value = listMahasiswa.map((mahasiswa) => {
      const mhsIdAkademik = String(mahasiswa.id || mahasiswa.ID || "").trim();

      // Jembatan 1: Cari baris keuangan yang kolom 'mahasiswa_id' atau 'id_mahasiswa'-nya cocok dengan UUID akademik
      const keuanganMatch = Array.isArray(listKeuangan)
        ? listKeuangan.find(k => 
            String(k.mahasiswa_id || k.id_mahasiswa || "").trim() === mhsIdAkademik
          )
        : null;

      let tagihanMatch = null;

      // Jembatan 2: Jika ketemu di keuangan, gunakan internal ID keuangan (angka) untuk mencari data tagihannya
      if (keuanganMatch) {
        const internalKeuanganId = keuanganMatch.id; // Ini ID angka (contoh: 4)
        
        tagihanMatch = Array.isArray(listTagihan)
          ? listTagihan.find(t => 
              String(t.id_mahasiswa || "").trim() === String(internalKeuanganId).trim()
            )
          : null;
      }

      // Logika Klasifikasi Jurusan & Prodi
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
        finalProdi = prodiDitemukan.nama_prodi || prodiDitemukan.name || prodiDitemukan.nama || "";
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
        id: mhsIdAkademik,
        nama: mahasiswa.NAMA || mahasiswa.nama || mahasiswa.nama_mahasiswa || "-",
        nim: mahasiswa.NIM || mahasiswa.nim || "-",
        semester: mahasiswa.SEMESTER || mahasiswa.semester || "1",
        jurusan_clean: finalJurusan,
        prodi_clean: finalProdi,
        tagihan: keuanganMatch,
        tagihan_internal_id: keuanganMatch ? keuanganMatch.id : null, // Disimpan untuk keperluan aksi Detail/Edit nanti
        status_pembayaran: tagihanMatch?.status || tagihanMatch?.status_pembayaran || "Belum Lunas",
        // Status keaktifan mahasiswa — dipakai di modal edit
        status: mahasiswa.status || mahasiswa.STATUS || mahasiswa.status_mahasiswa || "Aktif"
      };
    });

    console.log("Data Berhasil Disinkronkan:", dataMahasiswa.value);

  } catch (error) {
    console.error("Gagal memuat data:", error);
    errorMessage.value = "Gagal memuat data mahasiswa, keuangan, atau tagihan.";
  } finally {
    isLoading.value = false;
  }
}const debounceSearch = () => {
  clearTimeout(searchTimeout);
  searchTimeout = setTimeout(() => {
    currentPage.value = 1;
    fetchDataMahasiswa();
  }, 600);
};

const changePage = (page) => {
  if (page >= 1 && page <= lastPage.value) {
    currentPage.value = page;
    fetchDataMahasiswa();
  }
};

const pembayaranClass = (statusBayar) => {
  const b = String(statusBayar || "").toLowerCase().trim();
  if (b === "lunas" || b === "paid") return "badge-success";
  if (b === "cicilan") return "badge-warning";
  return "badge-danger";
};

// Tambahkan ref untuk mengontrol modal edit
const showEditModal = ref(false);
const dataForEdit = ref(null);

const openDetailModal = (item) => {
  // Langsung pakai data item dari tabel — tidak perlu fetch API lagi
  dataForEdit.value = { ...item };
  showEditModal.value = true;
};

// Setelah update berhasil dari modal, refresh tabel
const handleAfterUpdate = () => {
  showEditModal.value = false;
  fetchDataMahasiswa();
};

async function getDataTagihan() {
  const res = await apiKeuangan.get("https://api-keuangan-4a.akufarish.my.id:8873/api/tagihan");
  console.log(res.data);
  
}


  

onMounted(() => {
  fetchDataMahasiswa();
  getDataTagihan();
});
</script>

<style scoped>
@import url("https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap");
.main-content {
  padding: 25px;
  flex: 1;
  font-family: "Poppins", sans-serif;
}
.topbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}
.breadcrumb {
  font-size: 11px;
  color: #64748b;
  margin-bottom: 4px;
}
.topbar h1 {
  font-size: 24px;
  font-weight: 700;
  color: #1e293b;
}
.subtitle {
  font-size: 13px;
  color: #64748b;
}
.filter-card {
  background: white;
  padding: 18px 20px;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
  gap: 20px;
}
.search-box {
  position: relative;
  flex: 1;
  max-width: 400px;
}
.search-icon {
  position: absolute;
  left: 14px;
  top: 50%;
  transform: translateY(-50%);
  width: 18px;
  color: #94a3b8;
}
.search-box input {
  width: 100%;
  padding: 11px 15px 11px 42px;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  outline: none;
  font-size: 13px;
}
.filter-group {
  display: flex;
  gap: 12px;
}
.filter-group select {
  padding: 10px 14px;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  font-size: 13px;
  background: #f8fafc;
}
.table-card {
  background: white;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  overflow: hidden;
}
.table-responsive {
  overflow-x: auto;
}
.data-table {
  width: 100%;
  border-collapse: collapse;
  text-align: left;
}
.data-table th {
  background: #f8fafc;
  padding: 16px;
  font-size: 12px;
  text-transform: uppercase;
  color: #64748b;
  font-weight: 700;
  border-bottom: 1px solid #e2e8f0;
}
.data-table td {
  padding: 16px;
  border-bottom: 1px solid #f1f5f9;
  font-size: 14px;
}
.font-bold {
  font-weight: 700;
  color: #1e3a8a;
}
.nama-mhs {
  font-weight: 500;
}
.jurusan-text {
  font-weight: 600;
  font-size: 13px;
}
.prodi-text {
  font-size: 12px;
  color: #64748b;
}
.semester-badge {
  background: #eff6ff;
  color: #2563eb;
  padding: 5px 12px;
  border-radius: 8px;
  font-size: 11px;
  font-weight: 600;
}
.badge {
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  display: inline-block;
}
.badge-success {
  background-color: #f0fdf4;
  color: #16a34a;
}
.badge-warning {
  background-color: #fffbeb;
  color: #d97706;
}
.badge-danger {
  background-color: #fef2f2;
  color: #dc2626;
}
.btn-detail {
  background: white;
  border: 1px solid #e2e8f0;
  padding: 7px 14px;
  border-radius: 10px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  font-weight: 600;
  color: #64748b;
}
.btn-detail svg {
  width: 16px;
}
.btn-detail:hover {
  border-color: #3b82f6;
  color: #3b82f6;
  background: #eff6ff;
}
.empty-state {
  text-align: center;
  padding: 50px;
  color: #94a3b8;
}
.error-text {
  color: #ef4444;
}
.pagination {
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #f8fafc;
  border-top: 1px solid #e2e8f0;
}
.page-controls {
  display: flex;
  gap: 6px;
}
.control-btn {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  border: 1px solid #e2e8f0;
  background: white;
  cursor: pointer;
}
.control-btn.active {
  background: #1e3a8a;
  color: white;
  border-color: #1e3a8a;
}
.control-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>