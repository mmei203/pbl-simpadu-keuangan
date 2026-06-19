<template>
  <div class="main-content">
    <header class="topbar">
      <div>
        <p class="breadcrumb">Manajemen Keuangan > History Pembayaran</p>
        <h1>History Pembayaran</h1>
        <p class="subtitle">
          Riwayat setiap transaksi pembayaran (lunas maupun cicilan) seluruh mahasiswa
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
          placeholder="Cari Nama atau NIM..."
        />
      </div>

      <div class="filter-group">
        <select v-model="selectedStatus">
          <option value="">Semua Status</option>
          <option value="LUNAS">Lunas</option>
          <option value="CICIL">Cicilan</option>
          <option value="BELUM BAYAR">Belum Bayar</option>
        </select>
      </div>
    </section>

    <section class="table-card">
      <div class="table-responsive">

        <div v-if="isLoading" class="empty-state">
          Memuat riwayat pembayaran mahasiswa, mohon tunggu sebentar...
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
              <th>Aktivitas</th>
              <th>Nama Tagihan</th>
              <th>Cicilan</th>
              <th>Nominal</th>
              <th>Tanggal</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, index) in dataTerfilter" :key="item.ID_TAGIHAN || index">
              <td>{{ index + 1 }}</td>

              <td class="font-bold">{{ item.nim }}</td>

              <td class="nama-mhs">{{ item.nama_mahasiswa }}</td>

              <td>
                <span class="aktivitas-text">{{ labelAktivitas(item) }}</span>
              </td>

              <td>{{ item.NAMA_TAGIHAN || "-" }}</td>

              <td>
                <span class="cicilan-badge">
                  {{ item.NOMOR_CICILAN || "-" }}/{{ item.TOTAL_CICILAN || "-" }}
                </span>
              </td>

              <td class="nominal-text">{{ formatRupiah(item.NOMINAL_CICILAN) }}</td>

              <td>{{ formatTanggal(item.TGL_BAYAR || item.TGL_TAGIHAN) }}</td>

              <td>
                <span :class="['badge', statusBayarClass(item.STATUS_BAYAR)]">
                  {{ formatStatusBayar(item.STATUS_BAYAR) }}
                </span>
              </td>
            </tr>
            <tr v-if="dataTerfilter && dataTerfilter.length === 0">
              <td colspan="9" class="empty-state">Riwayat pembayaran tidak ditemukan</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import apiKeuangan from "../service/axios";
import axios from "axios";

const search = ref("");
const selectedStatus = ref("");

const isLoading = ref(false);
const errorMessage = ref("");

// Data mentah hasil join tagihan + mahasiswa (belum difilter search/status)
const riwayatPembayaran = ref([]);

async function fetchHistoryPembayaran() {
  isLoading.value = true;
  errorMessage.value = "";
  try {
    const token = localStorage.getItem("token") || localStorage.getItem("access_token");
    const headersConfig = {
      Accept: "application/json",
      ...(token && { Authorization: `Bearer ${token}` }),
    };

    // Ambil semua tagihan (riwayat transaksi) + semua mahasiswa (untuk join nama/NIM), paralel
    const [resTagihan, resMahasiswa] = await Promise.all([
      apiKeuangan.get(`https://api-keuangan-4a.akufarish.my.id:8873/api/tagihan`, {
        headers: headersConfig,
        timeout: 10000,
      }),
      axios.get(`https://api-mahasiswa-4a.akufarish.my.id:8874/api/mahasiswa`, {
        headers: headersConfig,
        timeout: 10000,
        params: { per_page: 150 },
      }),
    ]);

    const listTagihan = resTagihan.data?.data || [];
    const resMhsBody = resMahasiswa.data;
    const listMahasiswa = resMhsBody?.data?.data || resMhsBody?.data || resMhsBody || [];

    if (!Array.isArray(listTagihan)) {
      riwayatPembayaran.value = [];
      return;
    }

    // Buat lookup map ID_MAHASISWA -> { nim, nama } biar pencarian nama/NIM cepat (bukan .find() berulang)
    const mapMahasiswa = {};
    if (Array.isArray(listMahasiswa)) {
      listMahasiswa.forEach((mhs) => {
        const id = String(mhs.id_mahasiswa || "").trim().toLowerCase();
        if (id) {
          mapMahasiswa[id] = {
            nim: mhs.nim || mhs.NIM || "-",
            nama_mahasiswa: mhs.nama_mahasiswa || mhs.nama || mhs.NAMA || "-",
          };
        }
      });
    }

    // Setiap baris tagihan = satu transaksi/cicilan -> ini yang jadi 1 baris di history
    riwayatPembayaran.value = listTagihan.map((tagihan) => {
      const idMhs = String(tagihan.keuangan_mahasiswa?.ID_MAHASISWA || "").trim().toLowerCase();
      const infoMhs = mapMahasiswa[idMhs] || { nim: "-", nama_mahasiswa: "Mahasiswa Tidak Ditemukan" };

      return {
        ...tagihan,
        nim: infoMhs.nim,
        nama_mahasiswa: infoMhs.nama_mahasiswa,
      };
    });

    // Urutkan riwayat dari TGL_BAYAR/TGL_TAGIHAN paling baru ke paling lama
    riwayatPembayaran.value.sort((a, b) => {
      const tglA = new Date(a.TGL_BAYAR || a.TGL_TAGIHAN || 0).getTime();
      const tglB = new Date(b.TGL_BAYAR || b.TGL_TAGIHAN || 0).getTime();
      return tglB - tglA;
    });

  } catch (error) {
    console.error("Gagal memuat history pembayaran:", error);
    errorMessage.value = "Gagal memuat riwayat pembayaran mahasiswa.";
  } finally {
    isLoading.value = false;
  }
}

// Filter di frontend: search by nama/NIM + filter status, dari data yang sudah di-fetch sekali
const dataTerfilter = computed(() => {
  let hasil = riwayatPembayaran.value;

  if (search.value.trim()) {
    const keyword = search.value.trim().toLowerCase();
    hasil = hasil.filter((item) => {
      const nama = String(item.nama_mahasiswa || "").toLowerCase();
      const nim = String(item.nim || "").toLowerCase();
      return nama.includes(keyword) || nim.includes(keyword);
    });
  }

  if (selectedStatus.value) {
    hasil = hasil.filter((item) => {
      const status = String(item.STATUS_BAYAR || "").trim().toUpperCase();
      return status === selectedStatus.value;
    });
  }

  return hasil;
});

// Format tanggal jadi "15 Jun 2026", kalau tanggal kosong/null tampilkan "-"
const formatTanggal = (tgl) => {
  if (!tgl) return "-";
  const date = new Date(tgl);
  if (isNaN(date.getTime())) return "-";
  return date.toLocaleDateString("id-ID", { day: "numeric", month: "short", year: "numeric" });
};

// Label aktivitas naratif untuk satu baris histori:
// - Kalau TGL_BAYAR ada -> ini histori "pembayaran diterima" (uang sudah masuk)
// - Kalau TGL_BAYAR kosong -> ini histori "tagihan diterbitkan", belum ada pembayaran
// Dipakai supaya tabel tidak menyesatkan (tidak bilang "dibayar" padahal cuma tagihan baru terbit)
const labelAktivitas = (item) => {
  const sudahBayar = !!item.TGL_BAYAR;
  const isCicilan = Number(item.TOTAL_CICILAN) > 1;

  if (sudahBayar) {
    return isCicilan
      ? `Bayar cicilan ke-${item.NOMOR_CICILAN || "?"}`
      : "Pembayaran diterima";
  }
  return "Tagihan diterbitkan";
};

// Format angka jadi Rupiah, contoh: 3900000 -> "Rp 3.900.000"
const formatRupiah = (nominal) => {
  const angka = Number(nominal || 0);
  if (isNaN(angka)) return "-";
  return "Rp " + angka.toLocaleString("id-ID");
};

// Formatter Teks Status Pembayaran
const formatStatusBayar = (status) => {
  const s = String(status || "").toUpperCase().trim();
  if (s === "LUNAS") return "Lunas";
  if (s === "CICIL") return "Cicilan";
  return "Belum Bayar";
};

// Class Styling Badge Status Pembayaran
const statusBayarClass = (status) => {
  const s = String(status || "").toUpperCase().trim();
  if (s === "LUNAS") return "badge-success";
  if (s === "CICIL") return "badge-warning";
  return "badge-danger";
};

onMounted(() => {
  fetchHistoryPembayaran();
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
.nominal-text { font-weight: 600; color: #1e293b; }
.aktivitas-text { font-size: 13px; color: #334155; font-weight: 500; }
.cicilan-badge { background: #f1f5f9; color: #475569; padding: 4px 10px; border-radius: 8px; font-size: 12px; font-weight: 600; }
.badge { padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-block; text-align: center; min-width: 95px; }
.badge-success { background-color: #f0fdf4; color: #16a34a; }
.badge-warning { background-color: #fffbeb; color: #d97706; }
.badge-danger { background-color: #fef2f2; color: #dc2626; }
.empty-state { text-align: center; padding: 50px; color: #94a3b8; }
.error-text { color: #ef4444; }
</style>