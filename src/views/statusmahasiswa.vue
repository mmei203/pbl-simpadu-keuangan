<template>
  <div class="main-content">
    <header class="topbar">
      <div>
        <p class="breadcrumb">Manajemen Keuangan > Status Mahasiswa</p>
        <h1>Kelola Status</h1>
        <p class="subtitle">Pantau dan kelola status aktifitas akademik mahasiswa</p>
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
        <input type="text" v-model="search" placeholder="Cari Nama atau NIM..." />
      </div>
      
      <div class="filter-group">
        <select v-model="selectedJurusan">
          <option value="">Semua Jurusan</option>
          <option value="Elektro">Teknik Elektro</option>
          <option value="Mesin">Teknik Mesin</option>
          <option value="Sipil">Teknik Sipil</option>
        </select>
        <select v-model="selectedStatus">
          <option value="">Semua Status</option>
          <option value="Aktif">Aktif</option>
          <option value="Nonaktif">Nonaktif</option>
        </select>
      </div>
    </section>

    <EditData
      :showEditModal="showEditModal"
      :selectedData="selectedData"
      @close="showEditModal = false"
      @update="handleUpdate"
    />

    <section class="table-card">
      <div class="table-responsive">
        <table class="data-table">
          <thead>
            <tr>
              <th>No</th>
              <th>NIM</th>
              <th>Nama Mahasiswa</th>
              <th>Jurusan / Prodi</th>
              <th>Semester</th>
              <th>Status</th>
              <th>Pembayaran</th>
              <th>Aksi</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, index) in filteredData" :key="item.nim">
              <td>{{ index + 1 }}</td>
              <td class="font-bold">{{ item.nim }}</td>
              <td class="nama-mhs">{{ item.nama }}</td>
              <td>
                <div class="jurusan-text">{{ item.jurusan }}</div>
                <div class="prodi-text">{{ item.prodi }}</div>
              </td>
              <td><span class="semester-badge">Smstr {{ item.semester }}</span></td>
              <td>
                <span class="badge status" :class="item.status.toLowerCase()">
                  {{ item.status }}
                </span>
              </td>
              <td>
                <span class="badge payment" :class="item.pay.toLowerCase()">
                  {{ item.pay }}
                </span>
              </td>
              <td>
                <button class="btn-edit" @click="openEdit(item)">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
                  </svg>
                  Edit
                </button>
              </td>
            </tr>
            <tr v-if="filteredData.length === 0">
              <td colspan="8" class="empty-state">Data tidak ditemukan</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="pagination">
        <p>Menampilkan {{ filteredData.length }} dari {{ tableData.length }} data</p>
        <div class="page-controls">
          <button class="control-btn" disabled>&lt;</button>
          <button class="control-btn active">1</button>
          <button class="control-btn">2</button>
          <button class="control-btn">&gt;</button>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, computed } from "vue";
import EditData from "./editmahasiswa.vue";

const showEditModal = ref(false);
const selectedData = ref(null);
const search = ref("");
const selectedJurusan = ref("");
const selectedStatus = ref("");

const openEdit = (item) => {
  selectedData.value = { ...item };
  showEditModal.value = true;
};

const handleUpdate = (updatedItem) => {
  const index = tableData.value.findIndex((row) => row.nim === updatedItem.nim);
  if (index !== -1) {
    tableData.value[index] = { ...updatedItem };
  }
  showEditModal.value = false;
  selectedData.value = null;
};

const tableData = ref([
  { nim: "C030324077", nama: "Budi Siregar", jurusan: "Elektro", prodi: "Teknik Informatika", semester: "4", status: "Aktif", pay: "Lunas" },
  { nim: "C030324078", nama: "Siti Aminah", jurusan: "Elektro", prodi: "Teknik Informatika", semester: "4", status: "Nonaktif", pay: "Belum" },
  { nim: "C030324079", nama: "Rudi Hartono", jurusan: "Mesin", prodi: "Teknik Mesin", semester: "4", status: "Aktif", pay: "Lunas" },
  { nim: "C030324080", nama: "Desi Wulandari", jurusan: "Sipil", prodi: "Teknik Sipil", semester: "4", status: "Aktif", pay: "Lunas" },
  { nim: "C030324081", nama: "Ahmad Fauzi", jurusan: "Elektro", prodi: "Teknik Informatika", semester: "4", status: "Nonaktif", pay: "Belum" },
]);

const filteredData = computed(() => {
  return tableData.value.filter((item) => {
    const matchesSearch = search.value
      ? (item.nim + item.nama).toLowerCase().includes(search.value.toLowerCase())
      : true;
    const matchesJurusan = selectedJurusan.value ? item.jurusan === selectedJurusan.value : true;
    const matchesStatus = selectedStatus.value ? item.status === selectedStatus.value : true;
    return matchesSearch && matchesJurusan && matchesStatus;
  });
});
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

.main-content {
  padding: 25px;
  flex: 1;
  font-family: 'Poppins', sans-serif;
}

/* TOPBAR STYLE */
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
.btn-add {
  background: #1e3a8a; color: white; border: none; padding: 10px 22px;
  border-radius: 12px; font-weight: 600; font-size: 13px; cursor: pointer;
  display: flex; align-items: center; gap: 8px; transition: 0.3s;
}
.btn-add:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(30, 58, 138, 0.2); }

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
.font-bold { font-weight: 700; color: #1e3a8a; }
.nama-mhs { font-weight: 500; color: #1e293b; }

.jurusan-text { font-weight: 600; font-size: 13px; }
.prodi-text { font-size: 12px; color: #64748b; }

.semester-badge {
  background: #f1f5f9; color: #475569; padding: 5px 12px;
  border-radius: 8px; font-size: 11px; font-weight: 600;
}

/* BADGES MODERN */
.badge { padding: 6px 12px; border-radius: 8px; font-size: 11px; font-weight: 700; display: inline-block; }

.status.aktif { background: #e0e7ff; color: #4338ca; }
.status.nonaktif { background: #fee2e2; color: #b91c1c; }

.payment.lunas { background: #f0fdf4; color: #15803d; border: 1px solid #dcfce7; }
.payment.belum { background: #fff7ed; color: #9a3412; border: 1px solid #ffedd5; }

.btn-edit {
  background: white; border: 1px solid #e2e8f0; padding: 7px 14px;
  border-radius: 10px; cursor: pointer; display: flex; align-items: center;
  gap: 6px; font-size: 12px; font-family: 'Poppins', sans-serif; font-weight: 600; color: #64748b;
}
.btn-edit:hover { border-color: #3b82f6; color: #3b82f6; background: #eff6ff; }

.empty-state { text-align: center; padding: 50px; color: #94a3b8; }

/* PAGINATION */
.pagination {
  padding: 20px; display: flex; justify-content: space-between;
  align-items: center; background: #f8fafc; border-top: 1px solid #e2e8f0;
}
.pagination p { font-size: 13px; color: #64748b; }
.page-controls { display: flex; gap: 6px; }
.control-btn {
  width: 36px; height: 36px; display: flex; align-items: center;
  justify-content: center; border-radius: 10px; border: 1px solid #e2e8f0;
  background: white; cursor: pointer; font-size: 13px; transition: 0.2s;
}
.control-btn.active { background: #1e3a8a; color: white; border-color: #1e3a8a; font-weight: 600; }
.control-btn:disabled { opacity: 0.5; cursor: not-allowed; }
</style>