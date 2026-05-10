<template>
  <div class="main-content">
    <header class="topbar">
      <div>
        <p class="breadcrumb">Manajemen Keuangan > KIP-Kuliah</p>
        <h1>Daftar Penerima KIP</h1>
        <p class="subtitle">Monitoring data mahasiswa penerima bantuan KIP-Kuliah</p>
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
        <input type="text" v-model="search" placeholder="Cari Nama atau NIM Mahasiswa..." />
      </div>
      
      <div class="filter-group">
        <select v-model="selectedBeasiswa" class="filter-select disabled-select">
          <option value="KIP-Kuliah">KIP-Kuliah</option>
        </select>

        <select v-model="selectedProdi" class="filter-select">
          <option value="">Semua Prodi</option>
          <option value="Teknik Informatika">Teknik Informatika</option>
          <option value="Teknik Mesin">Teknik Mesin</option>
          <option value="Teknik Sipil">Teknik Sipil</option>
        </select>

        <button class="btn-add">
          <span>+</span> Tambah Mahasiswa
        </button>
      </div>
    </section>

    <section class="table-card">
      <div class="table-responsive">
        <table class="data-table">
          <thead>
            <tr>
              <th>No</th>
              <th>NIM</th>
              <th>Nama Mahasiswa</th>
              <th>Program Studi</th>
              <th>Bantuan Dana</th>
              <th>Status</th>
              <th>Aksi</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, index) in filteredData" :key="item.nim">
              <td>{{ index + 1 }}</td>
              <td class="font-bold">{{ item.nim }}</td>
              <td class="nama-mhs">{{ item.nama }}</td>
              <td>{{ item.prodi }}</td>
              <td class="nominal-text">{{ item.nominal }}</td>
              <td>
                <span class="badge status" :class="item.status.toLowerCase()">
                  {{ item.status }}
                </span>
              </td>
              <td>
                <button class="btn-edit">
                  Detail
                </button>
              </td>
            </tr>
            <tr v-if="filteredData.length === 0">
              <td colspan="7" class="empty-state">Data penerima KIP tidak ditemukan</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="pagination">
        <p>Menampilkan {{ filteredData.length }} data KIP-Kuliah</p>
        <div class="page-controls">
          <button class="control-btn" disabled>&lt;</button>
          <button class="control-btn active">1</button>
          <button class="control-btn">&gt;</button>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, computed } from "vue";

const search = ref("");
const selectedBeasiswa = ref("KIP-Kuliah"); // Default langsung ke KIP
const selectedProdi = ref("");

const tableData = ref([
  { nim: "C030324001", nama: "Aditya Pratama", prodi: "Teknik Informatika", nominal: "Rp 4.200.000", status: "Cair" },
  { nim: "C030324025", nama: "Citra Kirana", prodi: "Teknik Informatika", nominal: "Rp 4.200.000", status: "Cair" },
  { nim: "C030324045", nama: "Budi Santoso", prodi: "Teknik Sipil", nominal: "Rp 4.200.000", status: "Proses" },
  { nim: "C030324099", nama: "Siti Fatimah", prodi: "Teknik Mesin", nominal: "Rp 4.200.000", status: "Cair" },
  { nim: "C030324110", nama: "Rahmat Dani", prodi: "Teknik Informatika", nominal: "Rp 4.200.000", status: "Pending" },
]);

const filteredData = computed(() => {
  return tableData.value.filter((item) => {
    const matchesSearch = search.value
      ? (item.nim + item.nama).toLowerCase().includes(search.value.toLowerCase())
      : true;
    const matchesProdi = selectedProdi.value ? item.prodi === selectedProdi.value : true;
    return matchesSearch && matchesProdi;
  });
});
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

.main-content {
  padding: 25px;
  flex: 1;
  font-family: 'Poppins', sans-serif;
  background-color: #f8fafc;
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

.filter-group { display: flex; gap: 12px; }
.filter-select {
  padding: 10px 14px; border: 1px solid #e2e8f0; border-radius: 12px;
  font-size: 13px; font-family: 'Poppins', sans-serif; background: #f8fafc; cursor: pointer; color: #475569;
}
.disabled-select {
  background: #f1f5f9;
  cursor: not-allowed;
  font-weight: 600;
  color: #1e3a8a;
}

.btn-add {
  background: #1e3a8a; color: white; border: none; padding: 10px 22px;
  border-radius: 12px; font-weight: 600; font-size: 13px; cursor: pointer;
  display: flex; align-items: center; gap: 8px; transition: 0.3s;
}

/* TABLE STYLE */
.table-card {
  background: white; border-radius: 16px; border: 1px solid #e2e8f0;
  overflow: hidden;
}
.data-table { width: 100%; border-collapse: collapse; text-align: left; }
.data-table th {
  background: #f8fafc; padding: 16px; font-size: 12px;
  text-transform: uppercase; color: #64748b; font-weight: 700;
  border-bottom: 1px solid #e2e8f0;
}
.data-table td { padding: 16px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
.font-bold { font-weight: 700; color: #1e3a8a; }
.nama-mhs { font-weight: 500; color: #1e293b; }
.nominal-text { font-weight: 600; color: #15803d; }

/* BADGES */
.badge { padding: 6px 12px; border-radius: 8px; font-size: 11px; font-weight: 700; display: inline-block; text-transform: uppercase; }
.status.cair { background: #f0fdf4; color: #15803d; border: 1px solid #dcfce7; }
.status.proses { background: #eff6ff; color: #2563eb; border: 1px solid #dbeafe; }
.status.pending { background: #fff7ed; color: #9a3412; border: 1px solid #ffedd5; }

.btn-edit {
  background: white; border: 1px solid #e2e8f0; padding: 7px 14px;
  border-radius: 10px; cursor: pointer; font-size: 12px; font-weight: 600; color: #64748b;
}

/* PAGINATION */
.pagination {
  padding: 20px; display: flex; justify-content: space-between;
  align-items: center; background: #f8fafc; border-top: 1px solid #e2e8f0;
}
.pagination p { font-size: 13px; color: #64748b; }
.page-controls { display: flex; gap: 6px; }
.control-btn {
  width: 36px; height: 36px; border-radius: 10px; border: 1px solid #e2e8f0;
  background: white; cursor: pointer; display: flex; align-items: center; justify-content: center;
}
.control-btn.active { background: #1e3a8a; color: white; border-color: #1e3a8a; }
</style>