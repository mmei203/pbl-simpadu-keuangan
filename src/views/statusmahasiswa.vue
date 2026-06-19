<template>
  <div class="main-content">
    <header class="topbar">
      <div>
        <p class="breadcrumb">Manajemen Keuangan > Status Mahasiswa</p>
        <h1>Status Keuangan Mahasiswa</h1>
        <p class="subtitle">
          Pantau status aktif dan kelancaran pembayaran mahasiswa secara real-time
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
          Memuat data status keuangan mahasiswa, mohon tunggu sebentar...
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
              <th>Status Aktif</th>
              <th>Pembayaran</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, index) in dataMahasiswa" :key="item.id || index">
              <td>{{ (currentPage - 1) * perPage + index + 1 }}</td>

              <td class="font-bold">{{ item.nim }}</td>

              <td class="nama-mhs">
                {{ item.nama_mahasiswa || item.nama }}
              </td>

              <td>
                <div class="jurusan-text">
                  {{ item.jurusan_clean?.name || item.jurusan_clean }}
                </div>
                <div class="prodi-text">
                  {{ item.prodi_clean }}
                </div>
              </td>

              <td>
                <span class="semester-badge">Smstr {{ item.semester }}</span>
              </td>

              <td>
                <span :class="['badge', statusAktifClass(item.status_aktif_kuliah)]">
                  {{ formatStatusAktif(item.status_aktif_kuliah) }}
                </span>
              </td>

              <td>
                <span :class="['badge', pembayaranClass(item.status_pembayaran)]">
                  {{ formatStatusPembayaran(item.status_pembayaran) }}
                </span>
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

// Helper: jeda/delay sederhana dalam milidetik
function tunggu(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// Jalankan banyak async task SATU PER SATU (sequential), dengan jeda kecil antar request.
// Ini paling aman dari rate limit dibanding paralel/batch.
async function jalankanSequential(items, taskFn, jedaMs = 120) {
  const hasil = [];
  for (const item of items) {
    const r = await taskFn(item);
    hasil.push(r);
    if (jedaMs > 0) await tunggu(jedaMs);
  }
  return hasil;
}

// Ambil status aktif untuk SATU mahasiswa, dengan AUTO-RETRY kalau kena 429 (Too Many Requests).
// Pakai exponential backoff: percobaan ke-1 nunggu ~800ms, ke-2 ~1600ms, ke-3 ~3200ms, dst.
// Kalau tetap gagal setelah maxRetry percobaan, atau errornya BUKAN 429 (mis. 404), langsung return null.
async function fetchStatusAktif(idMahasiswa, headersConfig, maxRetry = 4) {
  let percobaan = 0;

  while (percobaan <= maxRetry) {
    try {
      const res = await apiKeuangan.get(
        `https://api-keuangan-4a.akufarish.my.id:8873/api/status-aktif/${idMahasiswa}`,
        { headers: headersConfig, timeout: 10000 }
      );

      const body = res.data;
      if (!body?.success || !body?.data) return null;

      return body.data; // { ID_MAHASISWA, STATUS_AKTIF, SEMESTER, BEASISWA, KATEGORI_UKT, NOMINAL_UKT }
    } catch (error) {
      const statusCode = error?.response?.status;

      // Kalau kena 429, tunggu makin lama tiap percobaan, lalu coba lagi
      if (statusCode === 429 && percobaan < maxRetry) {
        const delayMs = 800 * Math.pow(2, percobaan); // 800ms, 1600ms, 3200ms, 6400ms...
        console.warn(`429 untuk mahasiswa ${idMahasiswa}, retry ke-${percobaan + 1} setelah ${delayMs}ms`);
        await tunggu(delayMs);
        percobaan++;
        continue;
      }

      // Error selain 429 (mis. 404 mahasiswa tidak ada datanya), atau sudah habis jatah retry
      console.warn(`Gagal ambil status-aktif untuk mahasiswa ${idMahasiswa}:`, error?.message);
      return null;
    }
  }

  return null;
}

// Ambil SEMUA data tagihan sekaligus (list, bukan per-mahasiswa).
// Tiap baris tagihan punya nested object keuangan_mahasiswa.ID_MAHASISWA untuk matching ke mahasiswa.
async function fetchAllTagihan(headersConfig) {
  try {
    const res = await apiKeuangan.get(
      `https://api-keuangan-4a.akufarish.my.id:8873/api/tagihan`,
      { headers: headersConfig, timeout: 10000 }
    );
    const body = res.data;
    const list = body?.data || [];
    return Array.isArray(list) ? list : [];
  } catch (error) {
    console.warn("Gagal ambil data tagihan:", error?.message);
    return [];
  }
}

// Cari tagihan TERBARU milik satu mahasiswa (berdasarkan TGL_TAGIHAN paling baru).
// Mahasiswa bisa punya banyak baris tagihan (cicilan), jadi kita ambil 1 yang paling relevan.
// Matching ID dibuat case-insensitive (toLowerCase) untuk jaga-jaga beda kapitalisasi UUID.
function cariTagihanTerbaru(listTagihan, idMahasiswa) {
  const idTarget = String(idMahasiswa).trim().toLowerCase();

  const milikMahasiswaIni = listTagihan.filter((t) => {
    const idDariTagihan = String(t.keuangan_mahasiswa?.ID_MAHASISWA || "").trim().toLowerCase();
    return idDariTagihan === idTarget;
  });

  if (milikMahasiswaIni.length === 0) return null;

  // Urutkan berdasarkan TGL_TAGIHAN, paling baru di depan
  milikMahasiswaIni.sort((a, b) => {
    const tglA = new Date(a.TGL_TAGIHAN || 0).getTime();
    const tglB = new Date(b.TGL_TAGIHAN || 0).getTime();
    return tglB - tglA;
  });

  return milikMahasiswaIni[0];
}

async function fetchDataMahasiswa() {
  isLoading.value = true;
  errorMessage.value = "";
  try {
    const token = localStorage.getItem("token") || localStorage.getItem("access_token");
    const headersConfig = {
      Accept: "application/json",
      ...(token && { Authorization: `Bearer ${token}` }),
    };

    // 1. Fetch data mahasiswa & prodi dulu (data utama buat tabel)
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
    const listProdi = resProdi.data?.data || resProdi.data || [];

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

    // 2. Hit endpoint status-aktif/{id} SATU-SATU (sequential, dengan jeda + auto-retry kalau 429)
    //    supaya tidak kena rate limit dari server. /api/tagihan tetap dihit sekali saja, paralel.
    // PENTING: field ID asli dari API mahasiswa namanya "id_mahasiswa" (bukan "id"/"ID")
    const [statusAktifResults, listTagihan] = await Promise.all([
      jalankanSequential(listMahasiswa, (mhs) => {
        const idMhs = String(mhs.id_mahasiswa || "").trim();
        return fetchStatusAktif(idMhs, headersConfig);
      }, 120),
      fetchAllTagihan(headersConfig),
    ]);

    // 3. Gabungkan data mahasiswa + status aktif, SKIP kalau fetch status-aktif-nya gagal (null)
    const hasilGabungan = [];

    listMahasiswa.forEach((mahasiswa, idx) => {
      const statusData = statusAktifResults[idx];

      // Sesuai kesepakatan: kalau gagal fetch, mahasiswa ini tidak ditampilkan
      if (!statusData) return;

      const mhsIdAkademik = String(mahasiswa.id_mahasiswa || "").trim();

      // Cari tagihan terbaru milik mahasiswa ini dari list tagihan
      const tagihanTerbaru = cariTagihanTerbaru(listTagihan, mhsIdAkademik);

      // Logika Klasifikasi Jurusan & Prodi
      // Field aslinya: jurusan_id, prodi_id (angka, lowercase) — tidak ada nested object jurusan/prodi
      const targetProdiId = mahasiswa.prodi_id;
      let rawJurusan = mahasiswa.nama_jurusan || "";
      let rawProdi = mahasiswa.nama_prodi || "";
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

      hasilGabungan.push({
        ...mahasiswa,
        id: mhsIdAkademik,
        nama: mahasiswa.nama_mahasiswa || mahasiswa.nama || mahasiswa.NAMA || "-",
        nim: mahasiswa.nim || mahasiswa.NIM || "-",
        semester: statusData.SEMESTER || mahasiswa.SEMESTER || mahasiswa.semester || "1",
        jurusan_clean: finalJurusan,
        prodi_clean: finalProdi,
        status_aktif_kuliah: statusData.STATUS_AKTIF || "Tidak Aktif",
        status_pembayaran: tagihanTerbaru?.STATUS_BAYAR || "Belum Lunas",
      });
    });

    dataMahasiswa.value = hasilGabungan;

    console.log("Jumlah data tagihan yang berhasil di-fetch:", listTagihan.length);
    console.log("Data Berhasil Disinkronkan (status-aktif per mahasiswa):", dataMahasiswa.value);

  } catch (error) {
    console.error("Gagal memuat data:", error);
    errorMessage.value = "Gagal memuat sinkronisasi data mahasiswa atau status keuangan.";
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

// Formatter Teks Status Aktif Kuliah
const formatStatusAktif = (status) => {
  const s = String(status || "").toLowerCase().trim();
  if (s === "aktif" || s === "active" || s === "1" || s === "true") return "Aktif";
  return "Tidak Aktif";
};

// Formatter Teks Status Pembayaran
const formatStatusPembayaran = (status) => {
  const s = String(status || "").toLowerCase().trim();
  if (s === "lunas" || s === "paid") return "Lunas";
  if (s === "cicilan" || s === "cicil") return "Cicilan";
  return "Belum Lunas";
};

// Class Styling Badge Status Pembayaran
const pembayaranClass = (statusBayar) => {
  const b = String(statusBayar || "").toLowerCase().trim();
  if (b === "lunas" || b === "paid") return "badge-success";
  if (b === "cicilan" || b === "cicil") return "badge-warning";
  return "badge-danger";
};

// Class Styling Badge Status Aktif Kuliah
const statusAktifClass = (statusAktif) => {
  const s = String(statusAktif || "").toLowerCase().trim();
  if (s === "aktif" || s === "active" || s === "1" || s === "true") return "badge-primary";
  return "badge-danger";
};

onMounted(() => {
  fetchDataMahasiswa();
});
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
.badge { padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-block; text-align: center; min-width: 95px; }
.badge-primary { background-color: #eff6ff; color: #2563eb; }
.badge-success { background-color: #f0fdf4; color: #16a34a; }
.badge-warning { background-color: #fffbeb; color: #d97706; }
.badge-danger { background-color: #fef2f2; color: #dc2626; }
.empty-state { text-align: center; padding: 50px; color: #94a3b8; }
.error-text { color: #ef4444; }
.pagination { padding: 20px; display: flex; justify-content: space-between; align-items: center; background: #f8fafc; border-top: 1px solid #e2e8f0; }
.page-controls { display: flex; gap: 6px; }
.control-btn { width: 36px; height: 36px; border-radius: 10px; border: 1px solid #e2e8f0; background: white; cursor: pointer; }
.control-btn.active { background: #1e3a8a; color: white; border-color: #1e3a8a; }
.control-btn:disabled { opacity: 0.5; cursor: not-allowed; }
</style>