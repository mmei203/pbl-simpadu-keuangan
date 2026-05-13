<template>
  <div class="main-content">
    <header class="topbar">
      <div>
        <p class="breadcrumb">Manajemen Keuangan > Beasiswa</p>
        <h1>Daftar Penerima Beasiswa</h1>
        <p class="subtitle">Monitoring data mahasiswa penerima bantuan beasiswa dan KIP-Kuliah</p>
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
        <select v-model="selectedBeasiswaFilter" class="filter-select">
          <option value="">Semua Beasiswa</option>
          <option value="KIP-Kuliah">KIP-Kuliah</option>
          <option value="Beasiswa Prestasi">Beasiswa Prestasi</option>
        </select>

        <select v-model="selectedProdi" class="filter-select">
          <option value="">Semua Prodi</option>
          <option value="Teknik Informatika">Teknik Informatika</option>
          <option value="Teknik Mesin">Teknik Mesin</option>
          <option value="Teknik Sipil">Teknik Sipil</option>
        </select>

        <button class="btn-add" type="button" @click="openAddModal">
          <span>+</span> Tambah Beasiswa
        </button>
      </div>
    </section>

    <div v-if="showAddModal" class="modal-overlay">
      <div class="modal-card">
        <div class="modal-header">
          <div class="header-title">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="header-icon">
              <path stroke-linecap="round" stroke-linejoin="round" d="M16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
            </svg>
            <h2>Tambah Data Beasiswa</h2>
          </div>
          <button class="close-btn" type="button" @click="closeAddModal">&times;</button>
        </div>
        <form @submit.prevent="saveAdd" class="modal-form">
          <div class="form-grid">
            <div class="form-group">
              <label for="add-nim">NIM</label>
              <input id="add-nim" type="text" v-model="addForm.nim"  required />
            </div>

            <div class="form-group">
              <label for="add-nama">Nama Mahasiswa</label>
              <input id="add-nama" type="text" v-model="addForm.nama" required />
            </div>

            <div class="form-group full-width">
              <label for="add-beasiswa">Pilih Beasiswa</label>
              <select id="add-beasiswa" v-model="addForm.jenis_beasiswa" required>
                <option value="" disabled>Pilih Jenis Beasiswa</option>
                <option value="KIP-Kuliah">KIP-Kuliah</option>
                <option value="Beasiswa Prestasi">Beasiswa Prestasi</option>
                <option value="Beasiswa Internal">Beasiswa Internal</option>
              </select>
            </div>

            <div class="form-group full-width">
              <label for="add-potongan">Nominal Potongan</label>
              <input id="add-potongan" type="text" v-model="addForm.potongan" placeholder="100%" required />
            </div>
          </div>

          <div class="modal-footer">
            <button type="button" class="btn-cancel" @click="closeAddModal">Batal</button>
            <button type="submit" class="btn-save">Simpan</button>
          </div>
        </form>
      </div>
    </div>

    <EditBeasiswa
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
              <th>Program Studi</th>
              <th>Jenis Beasiswa</th>
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
              <td>
                <span class="beasiswa-type">{{ item.jenis_beasiswa }}</span>
              </td>
              <td class="nominal-text">{{ item.nominal }}</td>
              <td>
                <span class="badge status" :class="item.status.toLowerCase()">
                  {{ item.status }}
                </span>
              </td>
              <td>
                <button class="btn-edit" @click="openEdit(item)">
                  Detail
                </button>
              </td>
            </tr>
            <tr v-if="filteredData.length === 0">
              <td colspan="8" class="empty-state">Data penerima beasiswa tidak ditemukan</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="pagination">
        <p>Menampilkan {{ filteredData.length }} data beasiswa</p>
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
import { ref, reactive, computed } from "vue";
import EditBeasiswa from "./editbeasiswa.vue";

const search = ref("");
const selectedBeasiswaFilter = ref(""); 
const selectedProdi = ref("");
const showEditModal = ref(false);
const selectedData = ref(null);
const showAddModal = ref(false);
const addForm = reactive({
  nim: "",
  nama: "",
  jenis_beasiswa: "",
  potongan: "100%"
});

const openEdit = (item) => {
  selectedData.value = { ...item };
  showEditModal.value = true;
};

const openAddModal = () => {
  showAddModal.value = true;
};

const closeAddModal = () => {
  showAddModal.value = false;
  Object.assign(addForm, { nim: "", nama: "", jenis_beasiswa: "", potongan: "100%" });
};

const saveAdd = () => {
  tableData.value.unshift({
    nim: addForm.nim,
    nama: addForm.nama,
    prodi: "",
    nominal: addForm.potongan,
    status: "Proses",
    jenis_beasiswa: addForm.jenis_beasiswa,
    potongan: addForm.potongan
  });
  alert("Data penerima beasiswa berhasil disimpan!");
  closeAddModal();
};

const handleUpdate = (updatedItem) => {
  const index = tableData.value.findIndex((row) => row.nim === updatedItem.nim);
  if (index !== -1) {
    tableData.value[index] = { ...tableData.value[index], ...updatedItem };
  }
  showEditModal.value = false;
  selectedData.value = null;
};

const tableData = ref([
  { nim: "C030324001", nama: "Aditya Pratama", prodi: "Teknik Informatika", nominal: "Rp 4.200.000", status: "Cair", jenis_beasiswa: "KIP-Kuliah", potongan: "100%" },
  { nim: "C030324025", nama: "Citra Kirana", prodi: "Teknik Informatika", nominal: "Rp 4.200.000", status: "Cair", jenis_beasiswa: "KIP-Kuliah", potongan: "100%" },
  { nim: "C030324045", nama: "Budi Santoso", prodi: "Teknik Sipil", nominal: "Rp 4.200.000", status: "Proses", jenis_beasiswa: "KIP-Kuliah", potongan: "100%" },
  { nim: "C030324099", nama: "Siti Fatimah", prodi: "Teknik Mesin", nominal: "Rp 4.200.000", status: "Cair", jenis_beasiswa: "KIP-Kuliah", potongan: "100%" },
  { nim: "C030324110", nama: "Rahmat Dani", prodi: "Teknik Informatika", nominal: "Rp 4.200.000", status: "Pending", jenis_beasiswa: "KIP-Kuliah", potongan: "100%" },
]);

const filteredData = computed(() => {
  return tableData.value.filter((item) => {
    const matchesSearch = search.value
      ? (item.nim + item.nama).toLowerCase().includes(search.value.toLowerCase())
      : true;
    const matchesProdi = selectedProdi.value ? item.prodi === selectedProdi.value : true;
    const matchesBeasiswa = selectedBeasiswaFilter.value ? item.jenis_beasiswa === selectedBeasiswaFilter.value : true;
    return matchesSearch && matchesProdi && matchesBeasiswa;
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
.beasiswa-type { font-weight: 500; color: #475569; }
.nominal-text { font-weight: 600; color: #15803d; }

.modal-overlay {
  position: fixed; top: 0; left: 0; width: 100%; height: 100%;
  background: rgba(15, 23, 42, 0.7); backdrop-filter: blur(5px);
  display: flex; align-items: center; justify-content: center; z-index: 1000;
  font-family: 'Poppins', sans-serif;
}

.modal-card {
  background: white; width: 90%; max-width: 520px;
  border-radius: 20px; overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
}

.modal-header {
  padding: 20px 24px; border-bottom: 1px solid #f1f5f9;
  display: flex; justify-content: space-between; align-items: center;
  background: #f8fafc;
}

.header-title { display: flex; align-items: center; gap: 12px; }
.header-icon { width: 22px; color: #1e3a8a; }
.modal-header h2 { font-size: 17px; font-weight: 700; margin: 0; color: #1e293b; }
.close-btn { background: none; border: none; font-size: 28px; color: #94a3b8; cursor: pointer; }

.modal-form { padding: 24px; }

.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }
.full-width { grid-column: span 2; }

.form-group { display: flex; flex-direction: column; gap: 8px; }
.form-group label { font-size: 13px; font-weight: 600; color: #475569; }

.form-group input, .form-group select {
  padding: 12px 14px; border: 1.5px solid #e2e8f0; border-radius: 12px;
  font-size: 14px; outline: none; transition: 0.2s;
}

.form-group input:focus, .form-group select:focus {
  border-color: #1e3a8a; box-shadow: 0 0 0 4px rgba(30, 58, 138, 0.08);
}

.modal-footer {
  display: flex; justify-content: flex-end; gap: 12px; padding-top: 12px;
}

.btn-cancel {
  padding: 11px 24px; border-radius: 10px; border: 1.5px solid #e2e8f0;
  background: white; color: #64748b; font-weight: 600; cursor: pointer;
}

.btn-save {
  padding: 11px 24px; border-radius: 10px; border: none;
  background: #1e3a8a; color: white; font-weight: 600; cursor: pointer;
}

.btn-save:hover { background: #1e40af; transform: translateY(-1px); }

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