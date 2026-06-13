<template>
  <div class="main-content">
    <header class="topbar">
      <div>
        <p class="breadcrumb">Keuangan > History Pembayaran Mahasiswa</p>
        <h1>History Pembayaran Mahasiswa</h1>
        <p class="subtitle">Pantau transaksi masuk dan verifikasi pembayaran mahasiswa</p>
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
        <input type="text" v-model="search" placeholder="Cari ID Transaksi atau Nama..." />
      </div>
      
      <div class="filter-group">
        <select v-model="selectedMethod">
          <option value="">Semua Metode</option>
          <option value="VA">Virtual Account</option>
        </select>
        <select v-model="selectedStatus">
          <option value="">Semua Status</option>
          <option value="Berhasil">Berhasil</option>
          <option value="Proses">Proses</option>
          <option value="Gagal">Gagal</option>
        </select>
      </div>
    </section>

    <section class="table-card">
      <div class="table-responsive">
        <table class="data-table">
          <thead>
            <tr>
              <th>No</th>
              <th>ID Transaksi</th>
              <th>Nama Mahasiswa</th>
              <th>Metode</th>
              <th>Nominal</th>
              <th>Waktu</th>
              <th>Status</th>
              <th>Aksi</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, index) in filteredData" :key="item.id">
              <td>{{ index + 1 }}</td>
              <td class="id-text">#{{ item.id }}</td>
              <td>
                <div class="nama-mhs">{{ item.nama }}</div>
                <div class="nim-sub">{{ item.nim }}</div>
              </td>
              <td>
                <div class="method-chip">{{ item.metode }}</div>
              </td>
              <td class="nominal-text">{{ item.nominal }}</td>
              <td class="time-text">{{ item.waktu }}</td>
              <td>
                <span class="badge status" :class="item.status.toLowerCase()">
                  {{ item.status }}
                </span>
              </td>
              <td>
                <button class="btn-detail" @click="openKonfirmasi(item)">
                  Lihat Bukti
                </button>
              </td>
            </tr>
            <tr v-if="filteredData.length === 0">
              <td colspan="8" class="empty-state">Data transaksi tidak ditemukan</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="pagination">
        <p>Menampilkan {{ filteredData.length }} dari {{ tableData.length }} transaksi</p>
        <div class="page-controls">
          <button class="control-btn" disabled>&lt;</button>
          <button class="control-btn active">1</button>
          <button class="control-btn">2</button>
          <button class="control-btn">&gt;</button>
        </div>
      </div>
    </section>

    <!-- Modal Konfirmasi Pembayaran -->
    <div v-if="showModalKonfirmasi" class="modal-overlay"></div>
    <div v-if="showModalKonfirmasi" class="modal-container">
      <div class="modal-content">
        <div class="modal-header">
          <div class="header-title">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="header-icon">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
            </svg>
            <h2>Konfirmasi Pembayaran</h2>
          </div>
          <button @click="closeModal" class="close-btn">×</button>
        </div>

        <form @submit.prevent="saveKonfirmasi" class="modal-form">
          <div class="form-row">
            <div class="form-group">
              <label>NIM</label>
              <input type="text" v-model="selectedPembayaran.nim" required />
            </div>
            <div class="form-group">
              <label>Nama Mahasiswa</label>
              <input type="text" v-model="selectedPembayaran.nama" required />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Total Tagihan</label>
              <input type="text" v-model="selectedPembayaran.totalTagihan" required />
            </div>
            <div class="form-group">
              <label>Jumlah Bayar</label>
              <input type="text" v-model="selectedPembayaran.jumlahBayar" required />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Sisa Tagihan</label>
              <input type="text" v-model="selectedPembayaran.sisaTagihan" required />
            </div>
            <div class="form-group">
              <label>Metode pembayaran</label>
              <select v-model="selectedPembayaran.metode" required>
                <option value="BTN">BTN</option>
                <option value="Transfer Bank">Transfer Bank</option>
                <option value="VA">VA</option>
                <option value="E-Wallet">E-Wallet</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Tanggal</label>
              <input type="date" v-model="selectedPembayaran.tanggal" required />
            </div>
            <div class="form-group">
              <label>Status</label>
              <select v-model="selectedPembayaran.status" required>
                <option value="Berhasil">Berhasil</option>
                <option value="Proses">Proses</option>
                <option value="Gagal">Gagal</option>
              </select>
            </div>
          </div>

          <div class="form-buttons">
            <button type="button" @click="closeModal" class="btn-batal">Batal</button>
            <button type="submit" class="btn-simpan">Simpan</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, reactive } from "vue";

const search = ref("");
const selectedMethod = ref("");
const selectedStatus = ref("");
const showModalKonfirmasi = ref(false);

const selectedPembayaran = reactive({
  nim: "",
  nama: "",
  totalTagihan: "",
  jumlahBayar: "",
  sisaTagihan: "",
  metode: "BTN",
  tanggal: "",
  status: "Berhasil"
});

const tableData = ref([
  { id: "TX9901", nim: "C030324077", nama: "Budi Siregar", metode: "VA", nominal: "Rp 1.500.000", waktu: "12 Mei 2026, 09:45", status: "Berhasil" },
  { id: "TX9902", nim: "C030324078", nama: "Siti Aminah", metode: "VA", nominal: "Rp 1.500.000", waktu: "12 Mei 2026, 10:20", status: "Proses" },
  { id: "TX9903", nim: "C030324079", nama: "Rudi Hartono", metode: "VA", nominal: "Rp 750.000", waktu: "11 Mei 2026, 14:15", status: "Berhasil" },
  { id: "TX9904", nim: "C030324080", nama: "Desi Wulandari", metode: "VA", nominal: "Rp 1.500.000", waktu: "11 Mei 2026, 16:30", status: "Gagal" },
  { id: "TX9905", nim: "C030324081", nama: "Ahmad Fauzi", metode: "VA", nominal: "Rp 2.000.000", waktu: "10 Mei 2026, 08:00", status: "Berhasil" },
]);

const filteredData = computed(() => {
  return tableData.value.filter((item) => {
    const matchesSearch = search.value
      ? (item.id + item.nama + item.nim).toLowerCase().includes(search.value.toLowerCase())
      : true;
    const matchesMethod = selectedMethod.value ? item.metode === selectedMethod.value : true;
    const matchesStatus = selectedStatus.value ? item.status === selectedStatus.value : true;
    return matchesSearch && matchesMethod && matchesStatus;
  });
});

const openKonfirmasi = (item) => {
  selectedPembayaran.nim = item.nim;
  selectedPembayaran.nama = item.nama;
  selectedPembayaran.totalTagihan = item.nominal;
  selectedPembayaran.jumlahBayar = item.nominal;
  selectedPembayaran.sisaTagihan = item.nominal;
  selectedPembayaran.metode = item.metode;
  selectedPembayaran.tanggal = "";
  selectedPembayaran.status = item.status;
  showModalKonfirmasi.value = true;
};

const closeModal = () => {
  showModalKonfirmasi.value = false;
  selectedPembayaran.nim = "";
  selectedPembayaran.nama = "";
  selectedPembayaran.totalTagihan = "";
  selectedPembayaran.jumlahBayar = "";
  selectedPembayaran.sisaTagihan = "";
  selectedPembayaran.metode = "BTN";
  selectedPembayaran.tanggal = "";
  selectedPembayaran.status = "Berhasil";
};

const saveKonfirmasi = () => {
  console.log("Konfirmasi Pembayaran Disimpan:", selectedPembayaran);
  alert("Data konfirmasi pembayaran berhasil disimpan!");
  closeModal();
};
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

.main-content {
  padding: 25px;
  flex: 1;
  font-family: 'Poppins', sans-serif;
}

/* TOPBAR */
.topbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}
.breadcrumb { font-size: 11px; color: #64748b; margin-bottom: 4px; }
.topbar h1 { font-size: 24px; font-weight: 700; color: #1e293b; letter-spacing: -0.5px; }
.subtitle { font-size: 13px; color: #64748b; }

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
  border-radius: 12px; outline: none; font-size: 13px; font-family: 'Poppins', sans-serif;
}
.search-box input:focus { border-color: #3b82f6; box-shadow: 0 0 0 4px rgba(59,130,246,0.08); }

.filter-group { display: flex; gap: 12px; }
.filter-group select {
  padding: 10px 14px; border: 1px solid #e2e8f0; border-radius: 12px;
  font-size: 13px; font-family: 'Poppins', sans-serif; background: #f8fafc; cursor: pointer; color: #475569;
}


/* TABLE STYLE */
.table-card {
  background: white; border-radius: 16px; border: 1px solid #e2e8f0;
  overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.03);
}
.data-table { width: 100%; border-collapse: collapse; text-align: left; }
.data-table th {
  background: #f8fafc; padding: 16px; font-size: 12px;
  text-transform: uppercase; color: #64748b; font-weight: 700;
  border-bottom: 1px solid #e2e8f0; letter-spacing: 0.5px;
}
.data-table td { padding: 16px; border-bottom: 1px solid #f1f5f9; font-size: 14px; color: #334155; }

.id-text { font-family: 'Courier New', Courier, monospace; font-weight: 700; color: #64748b; font-size: 13px; }
.nama-mhs { font-weight: 600; color: #1e293b; }
.nim-sub { font-size: 11px; color: #94a3b8; margin-top: 2px; }

.method-chip { background: #f1f5f9; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 500; display: inline-block; }
.nominal-text { font-weight: 700; color: #1e293b; }
.time-text { font-size: 12px; color: #64748b; }

/* BADGES */
.badge { padding: 6px 12px; border-radius: 8px; font-size: 11px; font-weight: 700; display: inline-block; }
.status.berhasil { background: #f0fdf4; color: #15803d; }
.status.proses { background: #eff6ff; color: #2563eb; }
.status.gagal { background: #fee2e2; color: #b91c1c; }

.btn-detail {
  background: white; border: 1px solid #e2e8f0; padding: 7px 14px;
  border-radius: 10px; cursor: pointer; font-size: 12px; font-weight: 600; color: #1e3a8a;
}
.btn-detail:hover { background: #f1f5f9; }

.empty-state { text-align: center; padding: 50px; color: #94a3b8; }

/* PAGINATION */
.pagination {
  padding: 20px; display: flex; justify-content: space-between;
  align-items: center; background: #f8fafc; border-top: 1px solid #e2e8f0;
}
.pagination p { font-size: 13px; color: #64748b; }
.page-controls { display: flex; gap: 6px; }
.control-btn {
  width: 36px; height: 36px; border-radius: 10px; border: 1px solid #e2e8f0;
  background: white; cursor: pointer; font-size: 13px;
}
.control-btn.active { background: #1e3a8a; color: white; border-color: #1e3a8a; }
/* MODAL OVERLAY */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  z-index: 999;
}

/* MODAL CONTAINER */
.modal-container {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 1000;
  animation: slideDown 0.3s ease-in-out;
}

@keyframes slideDown {
  from {
    transform: translate(-50%, -60%);
    opacity: 0;
  }
  to {
    transform: translate(-50%, -50%);
    opacity: 1;
  }
}

.modal-content {
  background: white;
  border-radius: 16px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
  width: 520px;
  max-width: 90vw;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  border-bottom: 1px solid #e2e8f0;
}

.header-title {
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-icon {
  width: 20px;
  height: 20px;
  color: #1e3a8a;
}

.modal-header h2 {
  font-size: 16px;
  font-weight: 700;
  color: #1e293b;
  margin: 0;
  padding: 0;
}

.close-btn {
  background: none;
  border: none;
  font-size: 28px;
  color: #94a3b8;
  cursor: pointer;
  padding: 0;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: color 0.2s;
}

.close-btn:hover {
  color: #1e293b;
}

.modal-form {
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group label {
  font-size: 13px;
  font-weight: 600;
  color: #1e293b;
}

.form-group input, .form-group select {
  padding: 11px 14px;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  font-size: 13px;
  font-family: 'Poppins', sans-serif;
  outline: none;
  background-color: white;
  transition: border-color 0.2s;
}

.form-group input:focus, .form-group select:focus {
  border-color: #1e3a8a;
}

.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.input-wrapper input {
  width: 100%;
  padding-right: 40px;
}

.search-btn {
  position: absolute;
  right: 10px;
  background: none;
  border: none;
  color: #94a3b8;
  cursor: pointer;
  display: flex;
  align-items: center;
  padding: 0;
}

.search-btn svg {
  width: 16px;
  height: 16px;
}

.form-buttons {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  padding-top: 12px;
  border-top: 1px solid #e2e8f0;
  margin-top: 8px;
}

.btn-batal {
  background-color: white;
  color: #64748b;
  border: 1px solid #e2e8f0;
  padding: 9px 24px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  font-size: 13px;
  transition: all 0.2s;
}

.btn-batal:hover {
  background-color: #f8fafc;
  color: #1e293b;
  border-color: #cbd5e1;
}

.btn-simpan {
  background-color: #1e3a8a;
  color: white;
  border: none;
  padding: 9px 24px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  font-size: 13px;
  transition: background-color 0.2s;
}

.btn-simpan:hover {
  background-color: #1e40af;
}

@media (max-width: 768px) {
  .modal-content {
    width: 90vw;
    max-width: 450px;
  }

  .form-row {
    grid-template-columns: 1fr;
  }

  .modal-form {
    padding: 20px;
  }

  .modal-header {
    padding: 18px 20px;
  }
}</style>