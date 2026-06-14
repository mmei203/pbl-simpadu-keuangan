<template>
  <div class="main-content">
    <header class="topbar">
      <div>
        <p class="breadcrumb">Manajemen Keuangan > Cicilan > Tambah</p>
        <h1>Tambah data cicilan mahasiswa</h1>
        <p class="subtitle">Kelola pengajuan cicilan pembayaran mahasiswa</p>
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

    <div class="modal-overlay" @click="closeModal"></div>

    <div class="modal-container">
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

        <form @submit.prevent="saveCicilan" class="form-wrapper">
          <div class="form-grid">
            
            <div class="form-group span-two">
              <label for="nim">NIM Mahasiswa</label>
              <div class="input-wrapper">
                <input 
                  type="text" 
                  id="nim" 
                  v-model="form.nim" 
                  placeholder="C030324077" 
                  required 
                />
                <button type="button" class="search-btn" @click="searchMahasiswaByNim">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                  </svg>
                </button>
              </div>
              <p v-if="errorMsg" class="error-text">{{ errorMsg }}</p>
            </div>

            <div class="form-group span-two">
              <label for="nama">Nama Lengkap</label>
              <input 
                type="text" 
                id="nama" 
                v-model="form.nama" 
                placeholder="Nama otomatis terisi saat NIM dicari"
                required 
              />
            </div>

            <div class="form-group">
              <label for="totalUkt">Total UKT (Rp)</label>
              <input 
                type="text" 
                id="totalUkt" 
                v-model="form.totalUkt" 
                placeholder="Contoh: 3500000" 
                required 
              />
            </div>

            <div class="form-group">
              <label for="terbayar">Terbayar (Rp)</label>
              <input 
                type="text" 
                id="terbayar" 
                v-model="form.terbayar" 
                placeholder="Contoh: 1750000" 
                required 
              />
            </div>

            <div class="form-group">
              <label for="potongan">Potongan / Diskon</label>
              <input 
                type="text" 
                id="potongan" 
                v-model="form.potongan" 
                placeholder="Contoh: 10% atau 500000" 
              />
              <small style="font-size: 10px; color: #64748b;">* Bisa isi persen (misal: 10) atau nominal Rupiah</small>
            </div>

            <div class="form-group">
              <label for="sisa">Sisa Tagihan (Otomatis)</label>
              <input 
                type="text" 
                id="sisa" 
                v-model="form.sisa" 
                placeholder="Sisa pembayaran"
                disabled
                class="readonly-input"
              />
              <small style="font-size: 10px; color: #94a3b8;">* Rumus: (Total UKT - Potongan) - Terbayar</small>
            </div>

            <div class="form-group">
              <label for="jatuhTempo">Tanggal Jatuh Tempo</label>
              <input 
                type="date" 
                id="jatuhTempo" 
                v-model="form.jatuhTempo" 
                required 
              />
            </div>

            <div class="form-group">
              <label for="metode">Metode Pembayaran</label>
              <select id="metode" v-model="form.metode" required>
                <option value="" disabled>Pilih Metode Pembayaran</option>
                <option value="BTN">BTN</option>
                <option value="Transfer Bank">Transfer Bank</option>
                <option value="E-Wallet">E-Wallet</option>
              </select>
            </div>

            <div class="form-group span-two">
              <label for="cicilanKe">Cicilan Ke-</label>
              <input 
                type="number" 
                id="cicilanKe" 
                v-model="form.cicilanKe" 
                placeholder="1" 
                min="1"
                required 
              />
            </div>
          </div>

          <div class="form-buttons">
            <button type="button" @click="closeModal" class="btn-batal">Batal</button>
            <button type="submit" class="btn-simpan">Simpan Data</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, watch } from "vue";
import { useRouter } from "vue-router";
import axios from "axios";

const router = useRouter();
const errorMsg = ref("");

const API_TOKEN = localStorage.getItem("token") || "";
const API_BASE = "https://api-keuangan-4a.akufarish.my.id:8873/api";
const BASE_URL = `${API_BASE}/tagihan`;
const MAHASISWA_URL = `${API_BASE}/keuangan-mahasiswa`;

const apiConfig = {
  headers: {
    'Accept': 'application/json',
    'Authorization': `Bearer ${API_TOKEN}`
  }
};

const form = reactive({
  nim: "",
  nama: "",
  jatuhTempo: "",
  totalUkt: "",
  terbayar: "",
  sisa: "",
  potongan: "",
  metode: "",
  cicilanKe: ""
});

const selectedMahasiswa = reactive({
  id: "",
  nama: "",
  nim: ""
});

const parseMahasiswaApiResponse = (response) => {
  const body = response.data;
  if (!body) return [];
  if (Array.isArray(body)) return body;
  if (body.data && Array.isArray(body.data)) return body.data;
  if (body.data && body.data.data && Array.isArray(body.data.data)) return body.data.data;
  return [];
};

const searchMahasiswaByNim = async () => {
  errorMsg.value = "";
  selectedMahasiswa.id = "";
  selectedMahasiswa.nama = "";
  selectedMahasiswa.nim = "";

  const nim = form.nim?.trim();
  if (!nim) {
    errorMsg.value = "Masukkan NIM mahasiswa terlebih dahulu.";
    return;
  }

  try {
    const response = await axios.get(MAHASISWA_URL, {
      headers: apiConfig.headers,
      params: { search: nim, page: 1 }
    });

    const candidates = parseMahasiswaApiResponse(response);
    if (!candidates.length) {
      errorMsg.value = "Mahasiswa tidak ditemukan.";
      return;
    }

    const exactMatch = candidates.find((item) => {
      const itemNim = String(item.nim || item.NIM || "").trim();
      return itemNim === nim;
    }) || candidates[0];

    selectedMahasiswa.id = exactMatch.ID_KEUANGAN_MHS || exactMatch.id || exactMatch.ID_MAHASISWA || "";
    selectedMahasiswa.nama = exactMatch.nama || exactMatch.NAMA || "";
    selectedMahasiswa.nim = exactMatch.nim || exactMatch.NIM || "";

    if (!selectedMahasiswa.id) {
      errorMsg.value = "ID keuangan mahasiswa tidak tersedia dalam data mahasiswa.";
      return;
    }

    form.nama = selectedMahasiswa.nama || form.nama;
  } catch (error) {
    console.error("Gagal mencari mahasiswa:", error);
    if (error.response?.status === 401) {
      errorMsg.value = "Token tidak valid. Silakan login ulang.";
    } else {
      errorMsg.value = "Gagal mencari mahasiswa. Periksa koneksi atau token.";
    }
  }
};

// --- CORE FIX: LOGIKA HITUNG OTOMATIS + COMPUTE DISKON PERSEN / NOMINAL ---
watch(
  () => [form.totalUkt, form.terbayar, form.potongan],
  () => {
    const total = parseFloat(form.totalUkt?.toString().replace(/[^0-9]/g, "") || 0);
    const terbayar = parseFloat(form.terbayar?.toString().replace(/[^0-9]/g, "") || 0);
    
    // Ambil input potongan murni angka
    const potonganRaw = form.potongan?.toString().trim() || "0";
    let nilaiPotonganRaw = parseFloat(potonganRaw.replace(/[^0-9]/g, "") || 0);

    let hitungPotongan = 0;

    // Jika input mengandung teks '%' ATAU nilainya di bawah/sama dengan 100, kita anggap itu PERSEN
    if (potonganRaw.includes('%') || (nilaiPotonganRaw > 0 && nilaiPotonganRaw <= 100)) {
      hitungPotongan = total * (nilaiPotonganRaw / 100);
    } else {
      // Jika di atas 100, langsung anggap nominal Rupiah utuh
      hitungPotongan = nilaiPotonganRaw;
    }

    // Rumus Akurat: Sisa tagihan adalah total UKT dikurangi nilai potongan lalu dikurangi jumlah terbayar
    const hasilSisa = (total - hitungPotongan) - terbayar;
    
    // Simpan hasilnya ke state form.sisa (Pastikan tidak menampilkan minus jika kelebihan)
    form.sisa = Math.max(hasilSisa, 0).toString();
  }
);

const formatDateForAPI = (date) => {
  if (!date) return "";
  return date.includes("T") ? date : `${date}T00:00:00`;
};

const toNumber = (value) => {
  const numericString = String(value || "").replace(/[^0-9.-]/g, "");
  const parsed = parseFloat(numericString);
  return Number.isFinite(parsed) ? parsed : 0;
};

const saveCicilan = async () => {
  try {
    if (!form.nim || !form.nim.trim()) { alert("NIM harus diisi!"); return; }
    if (!form.nama || !form.nama.trim()) { alert("Nama Mahasiswa harus diisi!"); return; }
    if (!form.jatuhTempo) { alert("Jatuh Tempo harus diisi!"); return; }
    const totalUkt = toNumber(form.totalUkt);
    if (totalUkt <= 0) { alert("Total UKT harus diisi dengan nilai lebih dari 0!"); return; }
    const terbayar = toNumber(form.terbayar);
    if (terbayar < 0) { alert("Nilai Terbayar tidak boleh negatif!"); return; }
    if (!form.metode) { alert("Metode Pembayaran harus dipilih!"); return; }
    const cicilanKe = parseInt(form.cicilanKe, 10);
    if (!form.cicilanKe || !Number.isInteger(cicilanKe) || cicilanKe <= 0) { alert("Cicilan ke harus diisi dengan nilai bulat lebih dari 0!"); return; }
    if (!selectedMahasiswa.id) { alert("NIM mahasiswa tidak valid atau belum ditemukan. Cari dulu data mahasiswa."); return; }

    // Hitung ulang nominal potongan final untuk Payload API
    const total = totalUkt;
    const potonganRaw = form.potongan?.toString().trim() || "0";
    let nilaiPotonganRaw = parseFloat(potonganRaw.replace(/[^0-9]/g, "") || 0);
    const potongan = (potonganRaw.includes('%') || (nilaiPotonganRaw > 0 && nilaiPotonganRaw <= 100)) 
      ? total * (nilaiPotonganRaw / 100) 
      : nilaiPotonganRaw;

    const totalTagihan = Math.max(totalUkt - potongan, 0);
    const totalCicilan = 2;
    const nominalCicilan = totalCicilan > 0 ? Math.ceil(totalTagihan / totalCicilan) : totalTagihan;

    const payload = {
      ID_TAGIHAN: `TAG${Date.now().toString().slice(-15)}`.slice(0, 20),
      ID_KEUANGAN_MHS: selectedMahasiswa.id,
      NO_INVOICE: `INV-${form.nim.trim()}`.slice(0, 50),
      NAMA_TAGIHAN: `Tagihan Cicilan ${form.nama.trim()}`.slice(0, 50),
      NOMOR_CICILAN: cicilanKe,
      TOTAL_CICILAN: totalCicilan,
      NOMINAL_CICILAN: nominalCicilan,
      POTONGAN: potongan,
      TOTAL_TAGIHAN: totalTagihan,
      TGL_JATUH_TEMPO: formatDateForAPI(form.jatuhTempo),
      TGL_TAGIHAN: formatDateForAPI(new Date().toISOString().split("T")[0]),
      STATUS_BAYAR: "Belum Lunas",
      TGL_BAYAR: null
    };

    const response = await axios.post(BASE_URL, payload, apiConfig);
    if (response.status === 200 || response.status === 201) {
      alert("Data cicilan mahasiswa berhasil ditambahkan!");
      router.push("/cicilan");
    }
  } catch (error) {
    console.error("Gagal menyimpan cicilan:", error);
    if (error.response?.status === 401) {
      alert("Token tidak valid. Silakan login kembali.");
      router.push("/login");
    } else if (error.response?.data && error.response.data.errors) {
      const messages = Object.values(error.response.data.errors).flat().join("\n");
      alert(`Validasi gagal:\n${messages}`);
    } else {
      alert("Gagal menambahkan cicilan. Periksa kembali data.");
    }
  }
};

const closeModal = () => { router.push("/cicilan"); };
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

.main-content {
  padding: 25px;
  flex: 1;
  font-family: 'Poppins', sans-serif;
  background-color: #f8fafc;
  min-height: 100vh;
}

/* TOPBAR STYLE */
.topbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}
.breadcrumb { font-size: 12px; color: #64748b; margin-bottom: 5px; text-align: left; }
.topbar h1 { font-size: 24px; font-weight: 700; color: #1e293b; margin: 0; text-align: left; }
.subtitle { font-size: 14px; color: #64748b; margin-top: 2px; text-align: left; }

.profile-section { display: flex; align-items: center; gap: 15px; }
.notif-btn {
  background: white; border: 1px solid #e2e8f0; width: 42px; height: 42px;
  border-radius: 12px; cursor: pointer; display: flex; align-items: center; justify-content: center;
}
.profile-blue {
  background: #1e3a8a; color: white; padding: 8px 18px;
  border-radius: 12px; display: flex; align-items: center; gap: 12px; font-size: 13px; font-weight: 500;
}
.profile-blue img { width: 30px; height: 30px; border-radius: 50%; }

/* BLUR BACKGROUND OVERLAY */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(15, 23, 42, 0.4);
  backdrop-filter: blur(6px);
  z-index: 999;
}

/* MODAL BOX CONTAINER */
.modal-container {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* CONTAINER UTAMA */
.modal-content {
  background: white;
  border-radius: 16px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
  width: 650px;
  max-width: 90vw;
  max-height: 85vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  animation: scaleUp 0.25s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes scaleUp {
  from { transform: scale(0.95); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 18px 24px;
  border-bottom: 1px solid #f1f5f9;
  background: white;
}

.header-title { display: flex; align-items: center; gap: 10px; }
.header-icon { width: 20px; height: 20px; color: #1e3a8a; }
.modal-header h2 { font-size: 16px; font-weight: 700; color: #0f172a; margin: 0; }
.close-btn { background: none; border: none; font-size: 24px; color: #94a3b8; cursor: pointer; }
.close-btn:hover { color: #475569; }

/* WRAPPER FORM + SCROLL BAR INTEGRATED */
.form-wrapper {
  padding: 24px;
  overflow-y: auto;
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* SISTEM DUA KOLOM GRID */
.form-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
  text-align: left;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
  align-items: flex-start;
}

/* Element Yang Memakan 2 Kolom Penuh */
.span-two {
  grid-column: span 2;
}

.form-group label {
  font-size: 12px;
  font-weight: 600;
  color: #344155;
}

.form-group input, .form-group select {
  width: 100%;
  box-sizing: border-box;
  padding: 10px 14px;
  border: 1px solid #cbd5e1;
  border-radius: 8px;
  font-size: 13px;
  font-family: 'Poppins', sans-serif;
  outline: none;
  background-color: #ffffff;
  color: #0f172a;
  text-align: left;
  transition: all 0.2s;
}

.form-group input:focus, .form-group select:focus {
  border-color: #1e3a8a;
  box-shadow: 0 0 0 3px rgba(30, 58, 138, 0.1);
}

.readonly-input {
  background-color: #f8fafc !important;
  color: #64748b !important;
  border-color: #e2e8f0 !important;
  cursor: not-allowed;
}

/* Search Wrapper NIM */
.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
  width: 100%;
}
.input-wrapper input { padding-right: 40px; }
.search-btn {
  position: absolute;
  right: 12px;
  background: none;
  border: none;
  color: #64748b;
  cursor: pointer;
  display: flex;
  align-items: center;
}
.search-btn:hover { color: #1e3a8a; }
.search-btn svg { width: 16px; height: 16px; }

.error-text { font-size: 11px; color: #ef4444; margin-top: 4px; }

/* FOOTER BUTTONS */
.form-buttons {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  padding-top: 16px;
  border-top: 1px solid #f1f5f9;
  background: white;
  width: 100%;
}

.btn-batal {
  background: #f1f5f9; color: #475569; border: none;
  padding: 10px 22px; border-radius: 8px; font-weight: 600; cursor: pointer; font-size: 13px;
}
.btn-batal:hover { background: #e2e8f0; color: #1e293b; }

.btn-simpan {
  background: #1e3a8a; color: white; border: none;
  padding: 10px 22px; border-radius: 8px; font-weight: 600; cursor: pointer; font-size: 13px;
}
.btn-simpan:hover { background: #1d4ed8; }

/* RESPONSIVE LAYOUT */
@media (max-width: 640px) {
  .form-grid { grid-template-columns: 1fr; }
  .span-two { grid-column: span 1; }
  .modal-content { width: 95vw; }
}
</style>