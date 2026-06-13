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

    <!-- Overlay Blur -->
    <div class="modal-overlay"></div>

    <!-- Modal Pop-up Form -->
    <div class="modal-container">
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
        <form @submit.prevent="saveCicilan" class="form-wrapper">
          
          <div class="form-group">
            <label for="nim">NIM</label>
            <div class="input-wrapper">
              <input 
                type="text" 
                id="nim" 
                v-model="form.nim" 
                placeholder="C030324077" 
                required 
              />
              <button type="button" class="search-btn">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                </svg>
              </button>
            </div>
            <p v-if="errorMsg" class="error-text">Mahasiswa tidak ditemukan</p>
          </div>

          <div class="form-group">
            <label for="nama">Nama Mahasiswa</label>
            <input 
              type="text" 
              id="nama" 
              v-model="form.nama" 
              placeholder="Budi Siregar"
              required 
            />
          </div>

          <div class="form-group">
            <label for="totalUkt">Total UKT</label>
            <input 
              type="text" 
              id="totalUkt" 
              v-model="form.totalUkt" 
              placeholder="Rp 3.500.000" 
              required 
            />
          </div>

          <div class="form-group">
            <label for="terbayar">Terbayar</label>
            <input 
              type="text" 
              id="terbayar" 
              v-model="form.terbayar" 
              placeholder="Rp 1.750.000" 
              required 
            />
          </div>

          <div class="form-group">
            <label for="sisa">Sisa</label>
            <input 
              type="text" 
              id="sisa" 
              v-model="form.sisa" 
              placeholder="Sisa pembayaran"
              disabled
              class="readonly-input"
            />
          </div>

          <div class="form-group">
            <label for="jatuhTempo">Jatuh Tempo</label>
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

          <div class="form-group">
            <label for="cicilanKe">Cicilan ke</label>
            <input 
              type="number" 
              id="cicilanKe" 
              v-model="form.cicilanKe" 
              placeholder="1" 
              required 
            />
          </div>

          <!-- Buttons -->
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
import { reactive, ref } from "vue";
import { useRouter } from "vue-router";

const router = useRouter();
const errorMsg = ref(false);

const form = reactive({
  nim: "",
  nama: "",
  jatuhTempo: "",
  totalUkt: "",
  terbayar: "",
  sisa: "",
  metode: "",
  cicilanKe: ""
});

const saveCicilan = () => {
  console.log("Data Cicilan Disimpan:", form);
  alert("Data cicilan mahasiswa berhasil disimpan!");
  router.push("/cicilan");
};

const closeModal = () => {
  router.push("/cicilan");
};
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

/* TOPBAR */
.topbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 40px;
}
.breadcrumb { font-size: 12px; color: #64748b; margin-bottom: 5px; }
.topbar h1 { font-size: 26px; font-weight: 700; color: #1e293b; letter-spacing: -0.5px; margin: 0; }
.subtitle { font-size: 14px; color: #64748b; margin: 2px 0 0 0; }

/* PROFILE SECTION */
.profile-section { display: flex; align-items: center; gap: 15px; }
.notif-btn {
  background: white; border: 1px solid #e2e8f0; width: 42px; height: 42px;
  border-radius: 12px; cursor: pointer; display: flex; align-items: center; justify-content: center;
}
.profile-blue {
  background: #1e3a8a; color: white; padding: 8px 18px;
  border-radius: 12px; display: flex; align-items: center; gap: 12px; font-size: 13px; font-weight: 500;
}
.profile-blue img { width: 30px; height: 30px; border-radius: 50%; border: 2px solid rgba(255,255,255,0.2); }

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
  width: 500px;
  max-width: 90vw;
  overflow: hidden;
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
.form-wrapper {
  padding: 24px;
  display: flex;
  flex-direction: column;
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

.readonly-input {
  background-color: #f8fafc;
  color: #94a3b8;
  cursor: not-allowed;
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

.error-text {
  font-size: 11px;
  color: #ef4444;
  margin: 2px 0 0 5px;
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

  .form-wrapper {
    padding: 20px;
  }

  .modal-header {
    padding: 18px 20px;
  }

  .modal-header h2 {
    font-size: 15px;
  }
}
</style>