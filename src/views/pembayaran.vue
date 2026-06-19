<template>
  <div class="main-content">
    <header class="topbar no-print">
      <div>
        <p class="breadcrumb">Manajemen Keuangan > History Pembayaran</p>
        <h1>History Pembayaran</h1>
        <p class="subtitle">
          Riwayat setiap transaksi pembayaran (lunas maupun cicilan) seluruh mahasiswa
        </p>
      </div>
    </header>

    <section class="filter-card no-print">
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

    <section class="table-card no-print">
      <div class="table-responsive">
        <div v-if="isLoading" class="empty-state">
          Memuat seluruh riwayat pembayaran mahasiswa, mohon tunggu sebentar...
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
              <th>Aksi</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, index) in dataTerfilter" :key="item.ID_TAGIHAN || index">
              <td>{{ index + 1 }}</td>
              <td class="font-bold">{{ item.nim }}</td>
              <td class="nama-mhs">{{ item.nama_mahasiswa }}</td>
              <td><span class="aktivitas-text">{{ labelAktivitas(item) }}</span></td>
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
              <td>
                <button @click="bukaModalDetail(item)" class="btn-detail">Detail</button>
              </td>
            </tr>
            <tr v-if="dataTerfilter && dataTerfilter.length === 0">
              <td colspan="10" class="empty-state">Riwayat pembayaran tidak ditemukan</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <div v-if="isModalOpen" class="modal-overlay" @click.self="tutupModalDetail">
      <div class="modal-content print-area">
        <div class="invoice-header">
          <div class="invoice-title">
            <h2>Bukti Pembayaran SIMPADU</h2>
            <p>No. Invoice: <strong>{{ detailTerpilih?.NO_INVOICE || '-' }}</strong></p>
          </div>
          <div class="invoice-logo no-print">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="logo-icon"><path stroke-linecap="round" stroke-linejoin="round" d="M12 21v-8.25M15.75 21v-8.25M8.25 21v-8.25M3 9l9-6 9 6m-1.5 12V10.332A48.36 48.36 0 0 0 12 9.75c-2.551 0-5.056.2-7.5.582V21M3 21h18M12 6.75h.008v.008H12V6.75Z" /></svg>
          </div>
        </div>

        <div class="invoice-body">
          <div class="info-row">
            <span class="label">Nama Mahasiswa</span>
            <span class="value">: {{ detailTerpilih?.nama_mahasiswa }}</span>
          </div>
          <div class="info-row">
            <span class="label">NIM</span>
            <span class="value">: {{ detailTerpilih?.nim }}</span>
          </div>
          <div class="info-row">
            <span class="label">Jenis Tagihan</span>
            <span class="value">: {{ detailTerpilih?.NAMA_TAGIHAN || '-' }}</span>
          </div>
          <div class="info-row">
            <span class="label">Pembayaran Ke</span>
            <span class="value">: {{ detailTerpilih?.NOMOR_CICILAN || '-' }} dari {{ detailTerpilih?.TOTAL_CICILAN || '-' }}</span>
          </div>
          <div class="info-row">
            <span class="label">Tanggal Bayar</span>
            <span class="value">: {{ formatTanggal(detailTerpilih?.TGL_BAYAR) || '-' }}</span>
          </div>
          <div class="info-row">
            <span class="label">Status</span>
            <span class="value">: <strong>{{ formatStatusBayar(detailTerpilih?.STATUS_BAYAR) }}</strong></span>
          </div>
        </div>

        <div class="invoice-footer">
          <div class="total-box">
            <span>Total Dibayar</span>
            <h3>{{ formatRupiah(detailTerpilih?.NOMINAL_CICILAN) }}</h3>
          </div>
        </div>

        <div class="invoice-signatures">
          <div class="signature-col">
            <p>Mahasiswa,</p>
            <div class="signature-space"></div>
            <p class="signature-name"><strong>{{ detailTerpilih?.nama_mahasiswa || '-' }}</strong></p>
          </div>
          <div class="signature-col">
            <p>Admin Keuangan,</p>
            <div class="signature-space"></div>
            <p class="signature-name"><strong>_____________________</strong></p>
          </div>
        </div>

        <div class="modal-actions no-print">
          <button @click="tutupModalDetail" class="btn-tutup">Tutup</button>
          <button @click="cetakInvoice" class="btn-cetak">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M6.75 12a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0ZM12.75 12a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0ZM18.75 12a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Z" /><path stroke-linecap="round" stroke-linejoin="round" d="M6.75 6.75h10.5M6.75 17.25h10.5M4.5 9h15m-15 4.5h15" /></svg>
            Cetak Bukti
          </button>
        </div>
      </div>
    </div>
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

// State Modal
const isModalOpen = ref(false);
const detailTerpilih = ref(null);

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

    riwayatPembayaran.value = listTagihan.map((tagihan) => {
      const idMhs = String(tagihan.keuangan_mahasiswa?.ID_MAHASISWA || "").trim().toLowerCase();
      const infoMhs = mapMahasiswa[idMhs] || { nim: "-", nama_mahasiswa: "Mahasiswa Tidak Ditemukan" };

      return {
        ...tagihan,
        nim: infoMhs.nim,
        nama_mahasiswa: infoMhs.nama_mahasiswa,
      };
    });

    riwayatPembayaran.value.sort((a, b) => {
      const tglA = new Date(a.TGL_BAYAR || a.TGL_TAGIHAN || 0).getTime();
      const tglB = new Date(b.TGL_BAYAR || b.TGL_TAGIHAN || 0).getTime();
      return tglB - tglA;
    });

  } catch (error) {
    console.error("Gagal memuat history pembayaran global:", error);
    errorMessage.value = "Gagal memuat riwayat pembayaran mahasiswa.";
  } finally {
    isLoading.value = false;
  }
}

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

// Aksi Modal
const bukaModalDetail = (item) => {
  detailTerpilih.value = item;
  isModalOpen.value = true;
};

const tutupModalDetail = () => {
  isModalOpen.value = false;
  detailTerpilih.value = null;
};

const cetakInvoice = () => {
  window.print();
};

// Formatter
const formatTanggal = (tgl) => {
  if (!tgl) return "-";
  const date = new Date(tgl);
  if (isNaN(date.getTime())) return "-";
  return date.toLocaleDateString("id-ID", { day: "numeric", month: "short", year: "numeric" });
};

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

const formatRupiah = (nominal) => {
  const angka = Number(nominal || 0);
  if (isNaN(angka)) return "-";
  return "Rp " + angka.toLocaleString("id-ID");
};

const formatStatusBayar = (status) => {
  const s = String(status || "").toUpperCase().trim();
  if (s === "LUNAS") return "Lunas";
  if (s === "CICIL") return "Cicilan";
  return "Belum Bayar";
};

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
.search-box input { width: 100%; padding: 11px 15px 11px 42px; border: 1px solid #e2e8f0; border-radius: 12px; outline: none; font-size: 13px; font-family: "Poppins", sans-serif; }
.filter-group { display: flex; gap: 12px; }
.filter-group select { padding: 10px 14px; border: 1px solid #e2e8f0; border-radius: 12px; font-size: 13px; background: #f8fafc; font-family: "Poppins", sans-serif; cursor: pointer; }
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
.empty-state { text-align: center; padding: 50px; color: #94a3b8; font-size: 14px; }
.error-text { color: #ef4444; }

/* Tombol Aksi */
.btn-detail { background: #eff6ff; color: #2563eb; border: 1px solid #bfdbfe; padding: 6px 14px; border-radius: 8px; font-size: 12px; font-weight: 600; cursor: pointer; transition: 0.2s; font-family: "Poppins", sans-serif; }
.btn-detail:hover { background: #2563eb; color: white; }

/* Modal Styling */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(15, 23, 42, 0.6); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 20px; }
.modal-content { background: white; width: 100%; max-width: 500px; border-radius: 20px; padding: 30px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1); position: relative; }
.invoice-header { display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 2px dashed #e2e8f0; padding-bottom: 20px; margin-bottom: 20px; }
.invoice-title h2 { font-size: 18px; font-weight: 700; color: #1e293b; margin: 0 0 5px 0; }
.invoice-title p { font-size: 13px; color: #64748b; margin: 0; }
.logo-icon { width: 40px; height: 40px; color: #1e3a8a; }
.invoice-body { display: flex; flex-direction: column; gap: 12px; margin-bottom: 25px; }
.info-row { display: grid; grid-template-columns: 140px 1fr; font-size: 14px; }
.info-row .label { color: #64748b; }
.info-row .value { color: #1e293b; font-weight: 500; }
.invoice-footer { background: #f8fafc; padding: 15px 20px; border-radius: 12px; margin-bottom: 25px; border: 1px solid #f1f5f9; }
.total-box { display: flex; justify-content: space-between; align-items: center; }
.total-box span { font-size: 14px; color: #64748b; font-weight: 500; }
.total-box h3 { font-size: 20px; color: #1e3a8a; margin: 0; font-weight: 700; }

/* Tambahan CSS Kolom Tanda Tangan */
.invoice-signatures { display: flex; justify-content: space-between; margin-top: 35px; padding: 0 5px; margin-bottom: 15px; }
.signature-col { text-align: center; width: 180px; font-size: 13px; color: #334155; }
.signature-space { height: 65px; }
.signature-name { font-size: 13px; color: #1e293b; border-top: 1px solid transparent; }

.modal-actions { display: flex; gap: 10px; justify-content: flex-end; }
.btn-tutup { background: white; color: #64748b; border: 1px solid #e2e2f0; padding: 10px 18px; border-radius: 10px; font-weight: 600; cursor: pointer; }
.btn-tutup:hover { background: #f8fafc; }
.btn-cetak { background: #1e3a8a; color: white; border: none; padding: 10px 20px; border-radius: 10px; font-weight: 600; display: flex; align-items: center; gap: 8px; cursor: pointer; }
.btn-cetak svg { width: 18px; height: 18px; }
.btn-cetak:hover { background: #172554; }
</style>

<style>
/* CSS GLOBAL KHUSUS PRINT - MEMAKSA 1 HALAMAN CLEAN & ANTI-BUG DUPLIKAT */
@media print {
  html, body {
    height: 100% !important;
    overflow: hidden !important;
    margin: 0 !important;
    padding: 0 !important;
    background: #fff !important;
    -webkit-print-color-adjust: exact !important;
    print-color-adjust: exact !important;
  }

  /* Sembunyikan TOTAL seluruh elemen di aplikasi web */
  body * {
    visibility: hidden !important;
  }
  
  /* TAMPILKAN HANYA area invoice (.print-area) beserta isinya */
  .print-area, .print-area * {
    visibility: visible !important;
  }
  
  /* Sembunyikan elemen no-print bawaan web secara total */
  .no-print, .modal-actions, .topbar, .filter-card, .table-card {
    display: none !important;
    visibility: hidden !important;
  }

  /* Reset layouting modal overlay agar tidak fixed/melayang saat dicetak */
  .modal-overlay {
    position: static !important;
    display: block !important;
    padding: 0 !important;
    margin: 0 !important;
    background: none !important;
  }
  
  /* Tarik area invoice pas ke posisi pojok kiri atas kertas cetak */
  .print-area {
    position: absolute !important;
    left: 0 !important;
    top: 0 !important;
    width: 100% !important;
    max-width: 100% !important;
    height: auto !important;
    max-height: 100% !important;
    margin: 0 !important;
    padding: 20px !important;
    box-shadow: none !important;
    border: none !important;
    page-break-inside: avoid !important;
    break-inside: avoid !important;
  }
}
</style>