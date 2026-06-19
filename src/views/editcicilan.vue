<template>
  <div class="main-content">
    <header class="topbar">
      <div>
        <p class="breadcrumb">Manajemen Keuangan > Cicilan > Ubah</p>
        <h1>Ubah Cicilan</h1>
        <p class="subtitle">Kelola perubahan skema cicilan pembayaran mahasiswa</p>
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

    <section class="form-card">
      <form @submit.prevent="updateCicilan">
        <div class="form-grid">
          
          <div class="form-column">
            <div class="form-group">
              <label for="invoice">No Invoice</label>
              <input type="text" id="invoice" v-model="form.NO_INVOICE" readonly class="readonly-input" />
            </div>
            
            <div class="form-group">
              <label for="nama-tagihan">Nama Tagihan</label>
              <input type="text" id="nama-tagihan" v-model="form.NAMA_TAGIHAN" required />
            </div>

            <div class="form-group">
              <label for="jatuh-tempo">Jatuh Tempo</label>
              <input type="date" id="jatuh-tempo" v-model="form.TGL_JATUH_TEMPO" required />
            </div>
          </div>

          <div class="form-column">
            <div class="form-group">
              <label for="total-tagihan">Total Tagihan</label>
              <input type="number" id="total-tagihan" v-model="form.TOTAL_TAGIHAN" required />
            </div>

            <div class="form-group">
              <label for="nominal-cicilan">Nominal Cicilan</label>
              <input type="number" id="nominal-cicilan" v-model="form.NOMINAL_CICILAN" required />
            </div>

            <div class="form-group">
              <label for="status-bayar">Status Bayar</label>
              <select id="status-bayar" v-model="form.STATUS_BAYAR" required>
                <option value="LUNAS">LUNAS</option>
                <option value="BELUM BAYAR">BELUM BAYAR</option>
                <option value="CICIL">CICIL</option>
              </select>
            </div>
          </div>

          <div class="form-column">
            <div class="form-group">
              <label for="cicilan-ke">Cicilan Ke (Nomor Cicilan)</label>
              <input type="number" id="cicilan-ke" v-model="form.NOMOR_CICILAN" required />
            </div>

            <div class="form-group">
              <label for="total-cicilan">Total Kapasitas Tenor</label>
              <input type="number" id="total-cicilan" v-model="form.TOTAL_CICILAN" required />
            </div>
          </div>

        </div>

        <div class="form-footer">
          <button type="submit" class="btn-simpan">Simpan Perubahan</button>
        </div>
      </form>
    </section>
  </div>
</template>

<script setup>
import { reactive, onMounted } from "vue";
import axios from "axios";

const props = defineProps({
  idTagihan: {
    type: String,
    required: true
  }
});

const API_TOKEN = localStorage.getItem("token") || "";
const BASE_URL_TAGIHAN = "https://api-keuangan-4a.akufarish.my.id:8873/api/tagihan";

const apiConfig = {
  headers: {
    'Accept': 'application/json',
    'Authorization': `Bearer ${API_TOKEN}`
  }
};

const form = reactive({
  ID_TAGIHAN: "",
  NO_INVOICE: "",
  NAMA_TAGIHAN: "",
  TGL_JATUH_TEMPO: "",
  TOTAL_TAGIHAN: 0,
  NOMINAL_CICILAN: 0,
  STATUS_BAYAR: "BELUM BAYAR",
  NOMOR_CICILAN: 1,
  TOTAL_CICILAN: 2
});

const fetchDetailCicilan = async () => {
  try {
    const response = await axios.get(`${BASE_URL_TAGIHAN}/${props.idTagihan}`, apiConfig);
    if (response.data && response.data.data) {
      const item = response.data.data;
      Object.assign(form, {
        ID_TAGIHAN: item.ID_TAGIHAN,
        NO_INVOICE: item.NO_INVOICE,
        NAMA_TAGIHAN: item.NAMA_TAGIHAN,
        TGL_JATUH_TEMPO: item.TGL_JATUH_TEMPO ? item.TGL_JATUH_TEMPO.split('T')[0] : "",
        TOTAL_TAGIHAN: Math.round(parseFloat(item.TOTAL_TAGIHAN || 0)),
        NOMINAL_CICILAN: Math.round(parseFloat(item.NOMINAL_CICILAN || 0)),
        STATUS_BAYAR: item.STATUS_BAYAR,
        NOMOR_CICILAN: item.NOMOR_CICILAN,
        TOTAL_CICILAN: item.TOTAL_CICILAN
      });
    }
  } catch (error) {
    console.error("Gagal memuat detail cicilan:", error);
  }
};

onMounted(() => {
  if (props.idTagihan) {
    fetchDetailCicilan();
  }
});

const updateCicilan = async () => {
  try {
    const payload = {
      NAMA_TAGIHAN: form.NAMA_TAGIHAN,
      TOTAL_TAGIHAN: form.TOTAL_TAGIHAN,
      TGL_JATUH_TEMPO: form.TGL_JATUH_TEMPO,
      STATUS_BAYAR: form.STATUS_BAYAR,
      NOMOR_CICILAN: form.NOMOR_CICILAN,
      TOTAL_CICILAN: form.TOTAL_CICILAN,
      NOMINAL_CICILAN: form.NOMINAL_CICILAN,
      POTONGAN: 0
    };

    const response = await axios.put(`${BASE_URL_TAGIHAN}/${form.ID_TAGIHAN}`, payload, apiConfig);

    if (response.status === 200) {
      alert("Perubahan data cicilan berhasil disimpan di server!");
    }
  } catch (error) {
    console.error("Data Cicilan Gagal Diperbarui:", error);
    alert("Gagal memperbarui data cicilan.");
  }
};
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

.main-content { padding: 25px; flex: 1; font-family: 'Poppins', sans-serif; background-color: #f8fafc; min-height: 100vh; }
.topbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 35px; }
.breadcrumb { font-size: 12px; color: #64748b; margin-bottom: 5px; }
.topbar h1 { font-size: 26px; font-weight: 700; color: #1e293b; margin: 0; letter-spacing: -0.5px; }
.subtitle { font-size: 14px; color: #64748b; margin-top: 2px; }

.profile-section { display: flex; align-items: center; gap: 15px; }
.notif-btn { background: white; border: 1px solid #e2e8f0; width: 42px; height: 42px; border-radius: 12px; cursor: pointer; display: flex; align-items: center; justify-content: center; }
.profile-blue { background: #1e3a8a; color: white; padding: 8px 18px; border-radius: 12px; display: flex; align-items: center; gap: 12px; font-size: 13px; font-weight: 500; }
.profile-blue img { width: 30px; height: 30px; border-radius: 50%; border: 2px solid rgba(255,255,255,0.2); }

.form-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 30px; margin-bottom: 25px; }
.form-column { display: flex; flex-direction: column; gap: 18px; }
.form-group { display: flex; flex-direction: column; gap: 8px; }
.form-group label { font-size: 14px; font-weight: 500; color: #1e293b; }
.form-group input, .form-group select { padding: 12px 16px; border: 1px solid #e2e8f0; border-radius: 10px; background-color: white; font-size: 14px; font-family: 'Poppins', sans-serif; color: #334155; outline: none; }
.form-group input:focus, .form-group select:focus { border-color: #1e3a8a; }
.readonly-input { background-color: #f8fafc !important; color: #64748b; cursor: not-allowed; border-style: dashed !important; }
.btn-simpan { background-color: #1e3a8a; color: white; border: none; padding: 10px 32px; border-radius: 8px; font-weight: 600; font-size: 14px; cursor: pointer; }
.btn-simpan:hover { background-color: #1e40af; }

@media (max-width: 1024px) { .form-grid { grid-template-columns: repeat(2, 1fr); gap: 25px; } }
@media (max-width: 640px) { .form-grid { grid-template-columns: 1fr; gap: 20px; } }
</style>