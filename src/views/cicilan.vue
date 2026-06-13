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
        <button class="btn-add" @click="openModal">
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
                <button class="btn-action" @click="openDetail(item, index)">Detail</button>
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

    <!-- Modal Overlay -->
    <div v-if="showModalTambah" class="modal-overlay"></div>

    <!-- Modal Pop-up -->
    <div v-if="showModalTambah" class="modal-container">
      <div class="modal-content">
        <!-- Header -->
        <div class="modal-header">
          <div class="header-title">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="header-icon">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
            </svg>
            <h2>Tambah Data Cicilan</h2>
          </div>
          <button @click="closeModal" class="close-btn">×</button>
        </div>

        <!-- Form -->
        <form @submit.prevent="saveCicilan" class="modal-form">
          <div class="form-row">
            <div class="form-group">
              <label>NIM</label>
              <div class="input-wrapper">
                <input 
                  type="text" 
                  v-model="newCicilan.nim" 
                  placeholder="C030324077" 
                  required 
                />
                <button type="button" class="search-btn">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                  </svg>
                </button>
              </div>
            </div>
            <div class="form-group">
              <label>Nama Mahasiswa</label>
              <input 
                type="text" 
                v-model="newCicilan.nama" 
                placeholder="Budi Siregar"
                required 
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Nominal Potongan</label>
              <input 
                type="text" 
                v-model="newCicilan.potongan" 
                placeholder="100%" 
                required 
              />
            </div>
          </div>

          <!-- Buttons -->
          <div class="form-buttons">
            <button type="button" @click="closeModal" class="btn-batal">Batal</button>
            <button type="submit" class="btn-simpan">Simpan</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Detail Cicilan Modal -->
    <div v-if="showDetailModal" class="modal-overlay" @click.self="closeDetailModal"></div>
    <div v-if="showDetailModal" class="modal-container">
      <div class="modal-content">
        <div class="modal-header">
          <div class="header-title">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="header-icon">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
            </svg>
            <h2>Ubah Data Cicilan</h2>
          </div>
          <button @click="closeDetailModal" class="close-btn">×</button>
        </div>
        <form @submit.prevent="saveDetailChanges" class="modal-form">
          <div class="form-row">
            <div class="form-group">
              <label>NIM</label>
              <input type="text" v-model="editCicilan.nim" readonly />
            </div>
            <div class="form-group">
              <label>Nama Mahasiswa</label>
              <input type="text" v-model="editCicilan.nama" required />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Total UKT</label>
              <input type="text" v-model="editCicilan.total" required />
            </div>
            <div class="form-group">
              <label>Sisa Tagihan</label>
              <input type="text" v-model="editCicilan.sisa" required />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Jatuh Tempo</label>
              <input type="text" v-model="editCicilan.tempo" required />
            </div>
            <div class="form-group">
              <label>Status</label>
              <select v-model="editCicilan.status" required>
                <option value="Cicil">Cicil</option>
                <option value="Menunggak">Menunggak</option>
                <option value="Lunas">Lunas</option>
              </select>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Cicilan ke</label>
              <input type="text" v-model="editCicilan.tenor" required />
            </div>
          </div>
          <div class="form-buttons">
            <button type="button" class="btn-batal" @click="closeDetailModal">Batal</button>
            <button type="submit" class="btn-simpan">Simpan Perubahan</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, reactive, onMounted } from "vue";
import { useRouter } from "vue-router";
import axios from "axios"; // Import Axios

const router = useRouter();
const search = ref("");
const selectedStatus = ref("");
const showModalTambah = ref(false);
const showDetailModal = ref(false);

// State untuk menampung token Bearer dari dokumentasi API kamu
const API_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."; // Masukkan token lengkapmu di sini
const BASE_URL = "https://api-keuangan-4a.akufarish.my.id:8873/api/tagihan";

// Konfigurasi Header untuk Auth
const apiConfig = {
  headers: {
    'Accept': 'application/json',
    'Authorization': `Bearer ${API_TOKEN}`
  }
};

// State penampung data dari API
const tableData = ref([]);

const newCicilan = reactive({
  nim: "",
  nama: "",
  potongan: ""
});

const editCicilan = reactive({
  id: "", // Tambahkan ID untuk keperluan PUT/Update
  nim: "",
  nama: "",
  total: "",
  terbayar: "",
  sisa: "",
  tempo: "",
  status: "",
  tenor: ""
});

const selectedIndex = ref(-1);

// ==========================================
// 1. HIT API: GET DATA (tagihan.index)
// ==========================================
const fetchTagihan = async () => {
  try {
    const response = await axios.get(BASE_URL, apiConfig);
    // Asumsi format response API: { success: true, data: [...] }
    if (response.data && response.data.data) {
      tableData.value = response.data.data;
    }
  } catch (error) {
    console.error("Gagal mengambil data tagihan:", error);
    alert("Gagal memuat data dari server.");
  }
};

// Jalankan fungsi GET saat komponen pertama kali dibuka
onMounted(() => {
  fetchTagihan();
});

// Filter data (tetap berjalan di sisi client setelah data di-fetch)
const filteredData = computed(() => {
  return tableData.value.filter((item) => {
    const matchesSearch = search.value
      ? (item.nim + item.nama).toLowerCase().includes(search.value.toLowerCase())
      : true;
    const matchesStatus = selectedStatus.value ? item.status === selectedStatus.value : true;
    return matchesSearch && matchesStatus;
  });
});

// ==========================================
// 2. HIT API: POST DATA (tagihan.store)
// ==========================================
const saveCicilan = async () => {
  try {
    // Sesuaikan payload object ini dengan struktur parameter yang diminta oleh API POST kamu
    const payload = {
      nim: newCicilan.nim,
      nama: newCicilan.nama,
      potongan: newCicilan.potongan
    };

    const response = await axios.post(BASE_URL, payload, apiConfig);
    
    if (response.status === 200 || response.status === 201) {
      alert("Data cicilan berhasil ditambahkan ke server!");
      closeModal();
      fetchTagihan(); // Refresh tabel agar data baru muncul
    }
  } catch (error) {
    console.error("Gagal menyimpan data:", error);
    alert("Gagal menambahkan data cicilan.");
  }
};

// ==========================================
// 3. HIT API: PUT DATA (tagihan.update)
// ==========================================
const saveDetailChanges = async () => {
  try {
    // URL PUT biasanya membutuhkan ID di ujungnya, misal: /api/tagihan/1
    const updateUrl = `${BASE_URL}/${editCicilan.id}`;
    
    const payload = {
      nama: editCicilan.nama,
      total: editCicilan.total,
      sisa: editCicilan.sisa,
      tempo: editCicilan.tempo,
      status: editCicilan.status,
      tenor: editCicilan.tenor
    };

    const response = await axios.put(updateUrl, payload, apiConfig);

    if (response.status === 200) {
      alert("Perubahan data cicilan berhasil disimpan di server!");
      closeDetailModal();
      fetchTagihan(); // Refresh tabel
    }
  } catch (error) {
    console.error("Gagal memperbarui data:", error);
    alert("Gagal memperbarui data cicilan.");
  }
};

// Helper Format Tanggal (Sesuai kode lama kamu)
const formatToDdMmYyyy = (value) => {
  if (!value || value === "-") return "";
  const normalized = value.trim();
  const slashMatch = normalized.match(/^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})$/);
  if (slashMatch) return `${slashMatch[1].padStart(2, "0")}/${slashMatch[2].padStart(2, "0")}/${slashMatch[3]}`;
  
  const monthNames = { januari: "01", februari: "02", maret: "03", april: "04", mei: "05", juni: "06", juli: "07", agustus: "08", september: "09", oktober: "10", november: "11", desember: "12" };
  const parts = normalized.split(" ");
  if (parts.length === 3) {
    const [day, monthText, year] = parts;
    const month = monthNames[monthText.toLowerCase()];
    if (month) return `${day.padStart(2, "0")}/${month}/${year}`;
  }
  return normalized;
};

const openDetail = (item, index) => {
  selectedIndex.value = index;
  Object.assign(editCicilan, {
    id: item.id || "", // Pastikan API mengembalikan field 'id'
    nim: item.nim,
    nama: item.nama,
    total: item.total,
    terbayar: item.terbayar || "",
    sisa: item.sisa,
    tempo: formatToDdMmYyyy(item.tempo),
    status: item.status,
    tenor: item.tenor
  });
  showDetailModal.value = true;
};

const closeDetailModal = () => {
  showDetailModal.value = false;
  selectedIndex.value = -1;
};

const openModal = () => { showModalTambah.value = true; };
const closeModal = () => {
  showModalTambah.value = false;
  newCicilan.nim = "";
  newCicilan.nama = "";
  newCicilan.potongan = "";
};
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

/* MODAL CONTENT */
.modal-content {
  background: white;
  border-radius: 16px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
  width: 520px;
  max-width: 90vw;
}

/* MODAL HEADER */
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

.modal-body {
  padding: 24px;
  display: grid;
  gap: 16px;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  padding: 14px 18px;
  background: #f8fafc;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
}

.detail-row span {
  color: #64748b;
  font-size: 13px;
}

.detail-row strong {
  color: #1e293b;
  font-weight: 700;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 16px 24px 24px;
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

/* FORM */
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

/* Search Input */
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

/* BUTTONS */
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

/* RESPONSIVE */
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
}
</style>