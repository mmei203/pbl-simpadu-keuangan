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
        <input type="text" v-model="search" placeholder="Cari Nama, Invoice, atau NIM..." />
      </div>
      
      <div class="filter-group">
        <select v-model="selectedStatus">
          <option value="">Semua Status</option>
          <option value="LUNAS">Lunas</option>
          <option value="BELUM BAYAR">Belum Bayar</option>
          <option value="CICIL">Cicil</option>
        </select>
      </div>
    </section>

    <div v-if="isLoading" class="loading-state">Memuat dan mensinkronkan data mahasiswa...</div>

    <section class="table-card" v-else>
      <div class="table-responsive">
        <table class="data-table">
          <thead>
            <tr>
              <th>No</th>
              <th>No Invoice</th>
              <th>NIM</th>
              <th>Nama Mahasiswa</th>
              <th>Nama Tagihan</th>
              <th>Total Tagihan</th>
              <th>Nominal Cicilan</th>
              <th>Tenor</th>
              <th>Jatuh Tempo</th>
              <th>Status</th>
              <th>Aksi</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, index) in filteredData" :key="item.ID_TAGIHAN">
              <td>{{ index + 1 }}</td>
              <td class="font-bold">{{ item.NO_INVOICE }}</td>
              <td class="nim-text">{{ getMahasiswaInfo(item, 'nim') }}</td>
              <td class="nama-mhs">{{ getMahasiswaInfo(item, 'nama') }}</td>
              <td>{{ item.NAMA_TAGIHAN }}</td>
              <td class="total-tagihan">{{ formatRupiah(item.TOTAL_TAGIHAN) }}</td>
              <td>{{ formatRupiah(item.NOMINAL_CICILAN) }}</td>
              <td>
                <span class="tenor-badge">{{ item.NOMOR_CICILAN }} / {{ item.TOTAL_CICILAN }}</span>
              </td>
              <td class="tempo-text">{{ formatToDdMmYyyy(item.TGL_JATUH_TEMPO) }}</td>
              <td>
                <span class="badge status" :class="item.STATUS_BAYAR ? item.STATUS_BAYAR.toLowerCase().trim().replace(' ', '-') : ''">
                  {{ item.STATUS_BAYAR }}
                </span>
              </td>
              <td>
                <button class="btn-action" @click="openDetail(item, index)">Detail</button>
              </td>
            </tr>
            <tr v-if="filteredData.length === 0">
              <td colspan="11" class="empty-state">Data tidak ditemukan</td>
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

    <div v-if="showModalTambah" class="modal-overlay" @click="closeModal"></div>
    <div v-if="showModalTambah" class="modal-container">
      <div class="modal-content">
        <div class="modal-header">
          <div class="header-title">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="header-icon">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
            </svg>
            <h2>Tambah Data Cicilan</h2>
          </div>
          <button @click="closeModal" class="close-btn">×</button>
        </div>

        <form @submit.prevent="saveCicilan" class="modal-form">
          <div class="form-row">
            <div class="form-group">
              <label>Pilih Mahasiswa</label>
              <select v-model="newCicilan.id_keuangan_mhs" required>
                <option value="">-- Pilih Mahasiswa --</option>
                <option v-for="mhs in mahasiswaList" :key="mhs.id" :value="mhs.id_keuangan_mhs || 'KM001'">
                  {{ mhs.nim }} - {{ mhs.nama || mhs.nama_mahasiswa }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label>Nama Tagihan</label>
              <input type="text" v-model="newCicilan.nama_tagihan" placeholder="UKT Semester 1" required />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Nominal Cicilan</label>
              <input type="number" v-model="newCicilan.nominal_cicilan" placeholder="3900000" required />
            </div>
          </div>

          <div class="form-buttons">
            <button type="button" @click="closeModal" class="btn-batal">Batal</button>
            <button type="submit" class="btn-simpan">Simpan</button>
          </div>
        </form>
      </div>
    </div>

    <div v-if="showDetailModal" class="modal-overlay" @click="closeDetailModal"></div>
    <div v-if="showDetailModal" class="modal-container">
      <div class="modal-content">
        <div class="modal-header">
          <div class="header-title">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="header-icon">
              <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
            </svg>
            <h2>Ubah Data Cicilan</h2>
          </div>
          <button @click="closeDetailModal" class="close-btn">×</button>
        </div>
        <form @submit.prevent="saveDetailChanges" class="modal-form">
          <div class="form-row">
            <div class="form-group">
              <label>Nama Mahasiswa</label>
              <input type="text" v-model="editCicilan.nama_mahasiswa" readonly class="readonly-input" />
            </div>
            <div class="form-group">
              <label>No Invoice</label>
              <input type="text" v-model="editCicilan.no_invoice" readonly class="readonly-input" />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Nama Tagihan</label>
              <input type="text" v-model="editCicilan.nama_tagihan" required />
            </div>
            <div class="form-group">
              <label>Total Tagihan</label>
              <input type="number" v-model="editCicilan.total_tagihan" required />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Jatuh Tempo</label>
              <input type="date" v-model="editCicilan.tgl_jatuh_tempo" required />
            </div>
            <div class="form-group">
              <label>Status Bayar</label>
              <select v-model="editCicilan.status_bayar" required>
                <option value="LUNAS">LUNAS</option>
                <option value="BELUM BAYAR">BELUM BAYAR</option>
                <option value="CICIL">CICIL</option>
              </select>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Nomor Cicilan</label>
              <input type="number" v-model="editCicilan.nomor_cicilan" required />
            </div>
            <div class="form-group">
              <label>Total Kapasitas Tenor</label>
              <input type="number" v-model="editCicilan.total_cicilan" required />
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
import axios from "axios"; 

const search = ref("");
const selectedStatus = ref("");
const showModalTambah = ref(false);
const showDetailModal = ref(false);
const isLoading = ref(false);

const API_TOKEN = localStorage.getItem("token") || "";
const BASE_URL_TAGIHAN = "https://api-keuangan-4a.akufarish.my.id:8873/api/tagihan";
const BASE_URL_MAHASISWA = "https://api-mahasiswa-4a.akufarish.my.id:8874/api/mahasiswa";

const apiConfig = {
  headers: {
    'Accept': 'application/json',
    'Authorization': `Bearer ${API_TOKEN}`
  }
};

const tableData = ref([]);
const mahasiswaList = ref([]); 

const newCicilan = reactive({
  id_keuangan_mhs: "",
  nama_tagihan: "",
  nominal_cicilan: ""
});

const editCicilan = reactive({
  id_tagihan: "", 
  id_keuangan_mhs: "",
  no_invoice: "",
  nama_tagihan: "",
  nama_mahasiswa: "",
  nomor_cicilan: "",
  total_cicilan: "",
  nominal_cicilan: "",
  total_tagihan: "",
  tgl_jatuh_tempo: "",
  status_bayar: ""
});

const selectedIndex = ref(-1);

const getMahasiswaInfo = (item, type = 'nama') => {
  const idMhsFromTagihan = item.keuangan_mahasiswa?.ID_MAHASISWA;
  if (!idMhsFromTagihan) return type === 'nama' ? "Tidak Diketahui" : "-";

  const found = mahasiswaList.value.find(m => m.id === idMhsFromTagihan || m.id_mahasiswa === idMhsFromTagihan);
  
  if (found) {
    if (type === 'nama') return found.nama || found.nama_mahasiswa || "Tidak Diketahui";
    if (type === 'nim') return found.nim || "-";
  }
  return type === 'nama' ? `ID Mhs: ${idMhsFromTagihan.substring(0,8)}...` : "-";
};

const fetchDataFromServer = async () => {
  isLoading.value = true;
  try {
    const resMhs = await axios.get(BASE_URL_MAHASISWA, {
      ...apiConfig,
      params: { per_page: 150 }
    });
    if (resMhs.data && resMhs.data.data) {
      mahasiswaList.value = resMhs.data.data.data || resMhs.data.data || [];
    }

    const response = await axios.get(BASE_URL_TAGIHAN, apiConfig);
    if (response.data && response.data.data) {
      tableData.value = Array.isArray(response.data.data) ? response.data.data : [response.data.data];
    }
  } catch (error) {
    console.error("Gagal sinkronisasi data server:", error);
    alert("Gagal memuat data dari server backend.");
  } finally {
    isLoading.value = false;
  }
};

onMounted(() => {
  fetchDataFromServer();
});

const filteredData = computed(() => {
  return tableData.value.filter((item) => {
    const invoice = item.NO_INVOICE || "";
    const namaTagihan = item.NAMA_TAGIHAN || "";
    const namaMhsAsli = getMahasiswaInfo(item, 'nama');
    const nimMhsAsli = getMahasiswaInfo(item, 'nim');
    
    const matchesSearch = search.value
      ? (invoice + namaTagihan + namaMhsAsli + nimMhsAsli).toLowerCase().includes(search.value.toLowerCase())
      : true;
      
    // NORMALISASI FILTER STATUS: Trim whitespace & jadikan uppercase agar sinkron dengan v-model option
    let matchesStatus = true;
    if (selectedStatus.value) {
      const statusData = item.STATUS_BAYAR ? String(item.STATUS_BAYAR).trim().toUpperCase() : "";
      matchesStatus = statusData === selectedStatus.value;
    }
    
    return matchesSearch && matchesStatus;
  });
});

const saveCicilan = async () => {
  try {
    const payload = {
      ID_KEUANGAN_MHS: newCicilan.id_keuangan_mhs,
      NAMA_TAGIHAN: newCicilan.nama_tagihan,
      NOMINAL_CICILAN: newCicilan.nominal_cicilan,
      POTONGAN: 0
    };

    const response = await axios.post(BASE_URL_TAGIHAN, payload, apiConfig);
    
    if (response.status === 200 || response.status === 201) {
      alert("Data cicilan berhasil ditambahkan ke server!");
      closeModal();
      fetchDataFromServer(); 
    }
  } catch (error) {
    console.error("Gagal menyimpan data:", error);
    alert("Gagal menambahkan data cicilan.");
  }
};

const saveDetailChanges = async () => {
  try {
    const updateUrl = `${BASE_URL_TAGIHAN}/${editCicilan.id_tagihan}`;
    
    const payload = {
      NAMA_TAGIHAN: editCicilan.nama_tagihan,
      TOTAL_TAGIHAN: editCicilan.total_tagihan,
      TGL_JATUH_TEMPO: editCicilan.tgl_jatuh_tempo,
      STATUS_BAYAR: editCicilan.status_bayar,
      NOMOR_CICILAN: editCicilan.nomor_cicilan,
      TOTAL_CICILAN: editCicilan.total_cicilan,
      NOMINAL_CICILAN: editCicilan.nominal_cicilan,
      POTONGAN: 0
    };

    const response = await axios.put(updateUrl, payload, apiConfig);

    if (response.status === 200) {
      alert("Perubahan data cicilan berhasil disimpan di server!");
      closeDetailModal();
      fetchDataFromServer(); 
    }
  } catch (error) {
    console.error("Gagal memperbarui data:", error);
    alert("Gagal memperbarui data cicilan.");
  }
};

const formatRupiah = (angka) => {
  if (!angka) return "Rp 0";
  const format = parseFloat(angka).toLocaleString("id-ID");
  return `Rp ${format}`;
};

const formatToDdMmYyyy = (value) => {
  if (!value) return "-";
  const date = new Date(value);
  if (isNaN(date.getTime())) return value;
  const day = String(date.getDate()).padStart(2, '0');
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const year = date.getFullYear();
  return `${day}/${month}/${year}`;
};

const openDetail = (item, index) => {
  selectedIndex.value = index;
  Object.assign(editCicilan, {
    id_tagihan: item.ID_TAGIHAN, 
    id_keuangan_mhs: item.ID_KEUANGAN_MHS,
    no_invoice: item.NO_INVOICE,
    nama_tagihan: item.NAMA_TAGIHAN,
    nama_mahasiswa: getMahasiswaInfo(item, 'nama'),
    nomor_cicilan: item.NOMOR_CICILAN,
    total_cicilan: item.TOTAL_CICILAN,
    nominal_cicilan: item.NOMINAL_CICILAN,
    total_tagihan: Math.round(parseFloat(item.TOTAL_TAGIHAN || 0)),
    tgl_jatuh_tempo: item.TGL_JATUH_TEMPO ? item.TGL_JATUH_TEMPO.split('T')[0] : "", 
    status_bayar: item.STATUS_BAYAR
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
  newCicilan.id_keuangan_mhs = "";
  newCicilan.nama_tagihan = "";
  newCicilan.nominal_cicilan = "";
};
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

.main-content { padding: 25px; flex: 1; font-family: 'Poppins', sans-serif; background-color: #f8fafc; }
.topbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
.breadcrumb { font-size: 11px; color: #64748b; margin-bottom: 4px; }
.topbar h1 { font-size: 24px; font-weight: 700; color: #1e293b; letter-spacing: -0.5px; }
.subtitle { font-size: 13px; color: #64748b; }

.profile-section { display: flex; align-items: center; gap: 15px; }
.notif-btn { background: white; border: 1px solid #e2e8f0; width: 40px; height: 40px; border-radius: 10px; cursor: pointer; display: flex; align-items: center; justify-content: center; }
.profile-blue { background: #1e3a8a; color: white; padding: 8px 18px; border-radius: 12px; display: flex; align-items: center; gap: 12px; font-size: 13px; font-weight: 500; }
.profile-blue img { width: 28px; height: 28px; border-radius: 50%; }

.filter-card { background: white; padding: 18px 20px; border-radius: 16px; border: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; gap: 20px; }
.search-box { position: relative; flex: 1; max-width: 400px; }
.search-icon { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); width: 18px; color: #94a3b8; }
.search-box input { width: 100%; padding: 11px 15px 11px 42px; border: 1px solid #e2e8f0; border-radius: 12px; outline: none; font-size: 13px; font-family: 'Poppins', sans-serif; }
.filter-group { display: flex; gap: 12px; }
.filter-group select { padding: 10px 14px; border: 1px solid #e2e8f0; border-radius: 12px; font-size: 13px; font-family: 'Poppins', sans-serif; background: #f8fafc; cursor: pointer; }
.btn-add { background: #1e3a8a; color: white; border: none; padding: 10px 22px; border-radius: 12px; font-weight: 600; font-size: 13px; cursor: pointer; }

.table-card { background: white; border-radius: 16px; border: 1px solid #e2e8f0; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.03); }
.data-table { width: 100%; border-collapse: collapse; text-align: left; }
.data-table th { background: #f8fafc; padding: 16px; font-size: 12px; text-transform: uppercase; color: #64748b; font-weight: 700; border-bottom: 1px solid #e2e8f0; }
.data-table td { padding: 16px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
.font-bold { font-weight: 700; color: #1e3a8a; }
.nim-text { font-weight: 600; color: #64748b; }
.nama-mhs { font-weight: 600; color: #1e293b; }
.total-tagihan { color: #1e3a8a; font-weight: 600; }
.tenor-badge { background: #f1f5f9; padding: 4px 8px; border-radius: 6px; font-size: 12px; font-weight: 600; color: #1e3a8a; }
.tempo-text { font-size: 12px; color: #64748b; }

.badge { padding: 6px 12px; border-radius: 8px; font-size: 11px; font-weight: 700; display: inline-block; text-transform: uppercase; }
.status.cicil { background: #fefce8; color: #854d0e; border: 1px solid #fef08a; }
.status.belum-bayar { background: #fef2f2; color: #b91c1c; border: 1px solid #fee2e2; }
.status.lunas { background: #f0f9ff; color: #1e40af; border: 1px solid #e0f2fe; }

.btn-action { background: white; border: 1px solid #e2e8f0; padding: 7px 14px; border-radius: 10px; cursor: pointer; font-size: 12px; font-weight: 600; color: #64748b; }
.pagination { padding: 20px; display: flex; justify-content: space-between; align-items: center; background: #f8fafc; border-top: 1px solid #e2e8f0; }
.pagination p { font-size: 13px; color: #64748b; }
.control-btn { width: 36px; height: 36px; border-radius: 10px; border: 1px solid #e2e8f0; background: white; cursor: pointer; margin-left: 5px; }
.control-btn.active { background: #1e3a8a; color: white; border-color: #1e3a8a; }

.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.5); backdrop-filter: blur(4px); z-index: 999; }
.modal-container { position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); z-index: 1000; animation: slideDown 0.3s ease-in-out; }

@keyframes slideDown {
  from { transform: translate(-50%, -60%); opacity: 0; }
  to { transform: translate(-50%, -50%); opacity: 1; }
}

.modal-content { background: white; border-radius: 16px; box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15); width: 520px; max-width: 90vw; }
.modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; border-bottom: 1px solid #e2e8f0; }
.header-title { display: flex; align-items: center; gap: 12px; }
.header-icon { width: 20px; height: 20px; color: #1e3a8a; }
.modal-header h2 { font-size: 16px; font-weight: 700; color: #1e293b; margin: 0; }
.close-btn { background: none; border: none; font-size: 28px; color: #94a3b8; cursor: pointer; display: flex; align-items: center; justify-content: center; width: 32px; height: 32px; }
.close-btn:hover { color: #1e293b; }

.modal-form { padding: 24px; display: flex; flex-direction: column; gap: 16px; }
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.form-group { display: flex; flex-direction: column; gap: 8px; }
.form-group label { font-size: 13px; font-weight: 600; color: #1e293b; }
.form-group input, .form-group select { padding: 11px 14px; border: 1px solid #e2e8f0; border-radius: 8px; font-size: 13px; font-family: 'Poppins', sans-serif; outline: none; background-color: white; }
.form-group input:focus, .form-group select:focus { border-color: #1e3a8a; }
.readonly-input { background-color: #f8fafc !important; color: #64748b; cursor: not-allowed; border-style: dashed !important; }

.form-buttons { display: flex; gap: 12px; justify-content: flex-end; padding-top: 12px; border-top: 1px solid #e2e8f0; margin-top: 8px; }
.btn-batal { background-color: white; color: #64748b; border: 1px solid #e2e8f0; padding: 9px 24px; border-radius: 8px; font-weight: 600; cursor: pointer; font-size: 13px; }
.btn-batal:hover { background-color: #f8fafc; color: #1e293b; }
.btn-simpan { background-color: #1e3a8a; color: white; border: none; padding: 9px 24px; border-radius: 8px; font-weight: 600; cursor: pointer; font-size: 13px; }
.btn-simpan:hover { background-color: #1e40af; }

.loading-state, .empty-state { text-align: center; padding: 40px; font-size: 14px; color: #64748b; }

@media (max-width: 768px) {
  .modal-content { width: 90vw; max-width: 450px; }
  .form-row { grid-template-columns: 1fr; }
}
</style>