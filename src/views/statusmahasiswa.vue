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
                {{ item.nama }}
              </td>

              <td>
                <div class="jurusan-text">
                  {{ item.jurusan_clean }}
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
                    pembayaranClass(item.status_pembayaran),
                  ]"
                >
                  {{ item.status_pembayaran }}
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

    const [resMahasiswa, resProdi] = await Promise.all([
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
    ]);

    const resMhsBody = resMahasiswa.data;
    let listMahasiswa = [];

    if (resMhsBody) {
      if (resMhsBody.data && resMhsBody.data.data && Array.isArray(resMhsBody.data.data)) {
        listMahasiswa = resMhsBody.data.data;
        currentPage.value = resMhsBody.data.current_page || 1;
        lastPage.value = resMhsBody.data.last_page || 1;
        perPage.value = resMhsBody.data.per_page || 10;
      } else if (resMhsBody.data && Array.isArray(resMhsBody.data)) {
        listMahasiswa = resMhsBody.data;
      } else if (Array.isArray(resMhsBody)) {
        listMahasiswa = resMhsBody;
      }
    }

    const listProdi = resProdi.data?.data || resProdi.data || [];

    if (!Array.isArray(listMahasiswa) || listMahasiswa.length === 0) {
      dataMahasiswa.value = [];
      return;
    }

    const dataGabungan = listMahasiswa.map((mahasiswa) => {
      const targetProdiId = mahasiswa.PRODI_ID || mahasiswa.prodi_id;

      let rawJurusan = "";
      if (mahasiswa.jurusan && typeof mahasiswa.jurusan === 'object') {
        rawJurusan = mahasiswa.jurusan.name || mahasiswa.jurusan.nama || "";
      } else {
        rawJurusan = mahasiswa.nama_jurusan || mahasiswa.jurusan || "";
      }

      let rawProdi = "";
      if (mahasiswa.prodi && typeof mahasiswa.prodi === 'object') {
        rawProdi = mahasiswa.prodi.name || mahasiswa.prodi.nama || "";
      } else {
        rawProdi = mahasiswa.nama_prodi || mahasiswa.prodi || "";
      }

      // AMAN DARI ERROR: Dipastikan dikonversi ke String terlebih dahulu sebelum di-lowercase
      const gabunganTeksMentah = `${String(rawJurusan)} ${String(rawProdi)}`.toLowerCase();

      const prodiDitemukan = Array.isArray(listProdi) 
        ? listProdi.find((p) => String(p.id).trim() === String(targetProdiId).trim())
        : null;

      let finalJurusan = "";
      let finalProdi = "";

      if (prodiDitemukan) {
        finalJurusan = prodiDitemukan.nama_jurusan || prodiDitemukan.jurusan || "";
        finalProdi = prodiDitemukan.nama_prodi || prodiDitemukan.name || prodiDitemukan.nama || "";
      } else {
        if (gabunganTeksMentah.includes("informatika") || gabunganTeksMentah.includes("ti")) {
          finalJurusan = "Teknik Elektro";
          finalProdi = gabunganTeksMentah.includes("d4") ? "D4 Teknik Informatika" : "D3 Teknik Informatika";
        } else if (gabunganTeksMentah.includes("elektronika") || gabunganTeksMentah.includes("el")) {
          finalJurusan = "Teknik Elektro";
          finalProdi = "D3 Teknik Elektronika";
        } else if (gabunganTeksMentah.includes("listrik")) {
          finalJurusan = "Teknik Elektro";
          finalProdi = "D3 Teknik Listrik";
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

      let strJurusan = String(finalJurusan).toLowerCase().replace(/-/g, " ");
      let strProdi = String(finalProdi).toLowerCase().replace(/-/g, " ");

      if (strJurusan.includes("elektro") || strJurusan.includes("informatika")) {
        finalJurusan = "Teknik Elektro";
      } else if (strJurusan.includes("mesin")) {
        finalJurusan = "Teknik Mesin";
      } else if (strJurusan.includes("sipil")) {
        finalJurusan = "Teknik Sipil";
      } else {
        finalJurusan = "Teknik Elektro";
      }

      if (strProdi.includes("informatika") || strProdi.includes("ti")) {
        finalProdi = strProdi.includes("d4") ? "D4 Teknik Informatika" : "D3 Teknik Informatika";
      } else if (strProdi.includes("elektronika")) {
        finalProdi = "D3 Teknik Elektronika";
      } else if (strProdi.includes("listrik")) {
        finalProdi = "D3 Teknik Listrik";
      } else if (strProdi.includes("mesin")) {
        finalProdi = "D3 Teknik Mesin";
      } else if (strProdi.includes("sipil")) {
        finalProdi = "D3 Teknik Sipil";
      } else {
        finalProdi = "D3 Teknik Informatika";
      }

      return {
        ...mahasiswa,
        id: mahasiswa.id || mahasiswa.ID,
        nama: mahasiswa.NAMA || mahasiswa.nama || mahasiswa.nama_mahasiswa || "-",
        nim: mahasiswa.NIM || mahasiswa.nim || "-",
        semester: mahasiswa.SEMESTER || mahasiswa.semester || "1",
        jurusan_clean: finalJurusan,
        prodi_clean: finalProdi,
        status_pembayaran: mahasiswa.status_pembayaran || mahasiswa.pembayaran || "Belum Lunas"
      };
    });

    dataMahasiswa.value = dataGabungan;

    if (dataMahasiswa.value.length > 0) {
      loadKeuanganBackground();
    }
  } catch (error) {
    console.error("Gagal mengambil atau menggabungkan data:", error);
    if (error.response && error.response.status === 401) {
      errorMessage.value = "Sesi Anda telah habis (401). Silakan Logout lalu Login kembali ke aplikasi.";
    } else {
      errorMessage.value = "Gagal memuat data dari server akademik mahasiswa.";
    }
  } finally {
    isLoading.value = false;
  }
}

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

onMounted(() => {
  fetchDataMahasiswa();
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