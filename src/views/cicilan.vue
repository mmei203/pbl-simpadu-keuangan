<template>
  <div class="main-content">
    <header class="topbar">
      <div>
        <p class="breadcrumb">Keuangan > Cicilan Mahasiswa</p>
        <h1>Data Cicilan</h1>
        <p class="subtitle">Monitoring progres pembayaran cicilan UKT mahasiswa (Maks. 2 Kali)</p>
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
        <input type="text" v-model="search" placeholder="Cari NIM atau Nama..." />
      </div>
      
      <div class="filter-group">
        <select v-model="selectedStatus">
          <option value="">Semua Status</option>
          <option value="Cicil">Cicil</option>
          <option value="Menunggak">Menunggak</option>
          <option value="Lunas">Lunas</option>
        </select>
        <button class="btn-add">
          <span>+</span> Pengajuan Cicilan
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
              <th>Total UKT</th>
              <th>Sisa Tagihan</th>
              <th>Tenor</th>
              <th>Jatuh Tempo</th>
              <th>Status</th>
              <th>Aksi</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, index) in filteredData" :key="item.nim">
              <td>{{ index + 1 }}</td>
              <td class="font-bold">{{ item.nim }}</td>
              <td class="nama-mhs">{{ item.nama }}</td>
              <td>{{ item.total }}</td>
              <td class="sisa-tagihan">{{ item.sisa }}</td>
              <td>
                <span class="tenor-badge">{{ item.tenor }}</span>
              </td>
              <td class="tempo-text">{{ item.tempo }}</td>
              <td>
                <span class="badge status" :class="item.status.toLowerCase()">
                  {{ item.status }}
                </span>
              </td>
              <td>
                <button class="btn-action">Detail</button>
              </td>
            </tr>
            <tr v-if="filteredData.length === 0">
              <td colspan="9" class="empty-state">Data tidak ditemukan</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="pagination">
        <p>Menampilkan {{ filteredData.length }} data cicilan</p>
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
const selectedStatus = ref("");

const tableData = ref([
  { nim: "C030324001", nama: "Muhammad Riadin Zidan", total: "Rp 3.500.000", sisa: "Rp 1.750.000", tenor: "1 / 2", tempo: "15 Mei 2026", status: "Cicil" },
  { nim: "C030324015", nama: "Nazar Fadilah", total: "Rp 3.500.000", sisa: "Rp 3.500.000", tenor: "0 / 2", tempo: "12 Mei 2026", status: "Menunggak" },
  { nim: "C030324022", nama: "Aditya Rahman", total: "Rp 2.000.000", sisa: "Rp 0", tenor: "2 / 2", tempo: "-", status: "Lunas" },
  { nim: "C030324056", nama: "Siti Rahmah", total: "Rp 3.500.000", sisa: "Rp 1.750.000", tenor: "1 / 2", tempo: "20 Mei 2026", status: "Cicil" },
  { nim: "C030324090", nama: "Fajar Shidiq", total: "Rp 3.500.000", sisa: "Rp 3.500.000", tenor: "0 / 2", tempo: "10 Mei 2026", status: "Menunggak" },
]);

const filteredData = computed(() => {
  return tableData.value.filter((item) => {
    const matchesSearch = search.value
      ? (item.nim + item.nama).toLowerCase().includes(search.value.toLowerCase())
      : true;
    const matchesStatus = selectedStatus.value ? item.status === selectedStatus.value : true;
    return matchesSearch && matchesStatus;
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
.topbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
.breadcrumb { font-size: 11px; color: #64748b; margin-bottom: 4px; }
.topbar h1 { font-size: 24px; font-weight: 700; color: #1e293b; letter-spacing: -0.5px; }
.subtitle { font-size: 13px; color: #64748b; }

.profile-section { display: flex; align-items: center; gap: 15px; }
.notif-btn { background: white; border: 1px solid #e2e8f0; width: 40px; height: 40px; border-radius: 10px; cursor: pointer; display: flex; align-items: center; justify-content: center; }
.profile-blue { background: #1e3a8a; color: white; padding: 8px 18px; border-radius: 12px; display: flex; align-items: center; gap: 12px; font-size: 13px; font-weight: 500; }
.profile-blue img { width: 28px; height: 28px; border-radius: 50%; }

/* FILTER */
.filter-card { background: white; padding: 18px 20px; border-radius: 16px; border: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; gap: 20px; }
.search-box { position: relative; flex: 1; max-width: 400px; }
.search-icon { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); width: 18px; color: #94a3b8; }
.search-box input { width: 100%; padding: 11px 15px 11px 42px; border: 1px solid #e2e8f0; border-radius: 12px; outline: none; font-size: 13px; font-family: 'Poppins', sans-serif; }
.filter-group { display: flex; gap: 12px; }
.filter-group select { padding: 10px 14px; border: 1px solid #e2e8f0; border-radius: 12px; font-size: 13px; font-family: 'Poppins', sans-serif; background: #f8fafc; cursor: pointer; }
.btn-add { background: #1e3a8a; color: white; border: none; padding: 10px 22px; border-radius: 12px; font-weight: 600; font-size: 13px; cursor: pointer; }

/* TABLE */
.table-card { background: white; border-radius: 16px; border: 1px solid #e2e8f0; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.03); }
.data-table { width: 100%; border-collapse: collapse; text-align: left; }
.data-table th { background: #f8fafc; padding: 16px; font-size: 12px; text-transform: uppercase; color: #64748b; font-weight: 700; border-bottom: 1px solid #e2e8f0; }
.data-table td { padding: 16px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
.font-bold { font-weight: 700; color: #1e3a8a; }
.nama-mhs { font-weight: 500; color: #1e293b; }
.sisa-tagihan { color: #b91c1c; font-weight: 600; }
.tenor-badge { background: #f1f5f9; padding: 4px 8px; border-radius: 6px; font-size: 12px; font-weight: 600; color: #1e3a8a; }
.tempo-text { font-size: 12px; color: #64748b; }

/* BADGES */
.badge { padding: 6px 12px; border-radius: 8px; font-size: 11px; font-weight: 700; display: inline-block; text-transform: uppercase; }
.status.cicil { background: #fefce8; color: #854d0e; border: 1px solid #fef08a; }
.status.menunggak { background: #fef2f2; color: #b91c1c; border: 1px solid #fee2e2; }
.status.lunas { background: #f0f9ff; color: #1e40af; border: 1px solid #e0f2fe; }

.btn-action { background: white; border: 1px solid #e2e8f0; padding: 7px 14px; border-radius: 10px; cursor: pointer; font-size: 12px; font-weight: 600; color: #64748b; }

/* PAGINATION */
.pagination { padding: 20px; display: flex; justify-content: space-between; align-items: center; background: #f8fafc; border-top: 1px solid #e2e8f0; }
.pagination p { font-size: 13px; color: #64748b; }
.control-btn { width: 36px; height: 36px; border-radius: 10px; border: 1px solid #e2e8f0; background: white; cursor: pointer; margin-left: 5px; }
.control-btn.active { background: #1e3a8a; color: white; border-color: #1e3a8a; }
</style>