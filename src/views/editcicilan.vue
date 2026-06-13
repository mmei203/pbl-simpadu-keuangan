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
              <label for="nim">NIM</label>
              <input 
                type="text" 
                id="nim" 
                v-model="form.nim" 
                placeholder="C030324077" 
                required 
              />
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
              <label for="jatuh-tempo">Jatuh tempo</label>
              <input 
                type="date" 
                id="jatuh-tempo" 
                v-model="form.jatuhTempo" 
                required 
              />
            </div>
          </div>

          <div class="form-column">
            <div class="form-group">
              <label for="total-ukt">Total UKT</label>
              <input 
                type="text" 
                id="total-ukt" 
                v-model="form.totalUkt" 
                placeholder="Rp. 3.000.000" 
                required
              />
            </div>

            <div class="form-group">
              <label for="terbayar">Terbayar</label>
              <input 
                type="text" 
                id="terbayar" 
                v-model="form.terbayar" 
                placeholder="Rp. 1.500.000" 
                required
              />
            </div>

            <div class="form-group">
              <label for="sisa">Sisa</label>
              <input 
                type="text" 
                id="sisa" 
                v-model="form.sisa" 
                placeholder="Rp. 1.500.000" 
                required
              />
            </div>
          </div>

          <div class="form-column">
            <div class="form-group">
              <label for="metode">Metode pembayaran</label>
              <select id="metode" v-model="form.metode" required>
                <option value="BTN">BTN</option>
                <option value="Transfer Bank">Transfer Bank</option>
                <option value="VA">VA</option>
                <option value="E-Wallet">E-Wallet</option>
              </select>
            </div>

            <div class="form-group">
              <label for="cicilan-ke">Cicilan ke</label>
              <input 
                type="number" 
                id="cicilan-ke" 
                v-model="form.cicilanKe" 
                placeholder="2" 
                required
              />
            </div>
          </div>

        </div>

        <div class="form-footer">
          <button type="submit" class="btn-simpan">Simpan</button>
        </div>
      </form>
    </section>
  </div>
</template>

<script setup>
import { reactive } from "vue";

const props = defineProps({
  nim: {
    type: String,
    default: ""
  }
});

// Mengisi data default (Pre-filled) sesuai dengan contoh gambar ubahtele
const form = reactive({
  nim: props.nim || "C030324077",
  nama: "Budi Siregar",
  jatuhTempo: "2027-01-23", // Format YYYY-MM-DD agar dibaca oleh input type="date"
  totalUkt: "Rp. 3.000.000",
  terbayar: "Rp. 1.500.000",
  sisa: "Rp. 1.500.000",
  metode: "BTN",
  cicilanKe: 2
});

const updateCicilan = () => {
  console.log("Data Cicilan Berhasil Diperbarui:", form);
  alert("Perubahan data cicilan berhasil disimpan!");
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
  margin-bottom: 35px;
}
.breadcrumb { font-size: 12px; color: #64748b; margin-bottom: 5px; }
.topbar h1 { font-size: 26px; font-weight: 700; color: #1e293b; margin: 0; letter-spacing: -0.5px; }
.subtitle { font-size: 14px; color: #64748b; margin-top: 2px; }

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

/* FORM CARD */
.form-card {
  background: transparent;
}

/* 3-COLUMN GRID LAYOUT */
.form-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 30px;
  margin-bottom: 25px;
}

.form-column {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group label {
  font-size: 14px;
  font-weight: 500;
  color: #1e293b;
}

.form-group input, .form-group select {
  padding: 12px 16px;
  border: 1px solid #e2e8f0;
  border-radius: 10px;
  background-color: white;
  font-size: 14px;
  font-family: 'Poppins', sans-serif;
  color: #334155;
  outline: none;
  transition: border-color 0.2s;
}

.form-group input:focus, .form-group select:focus {
  border-color: #1e3a8a;
}

/* BUTTON ACTION */
.form-footer {
  margin-top: 10px;
}

.btn-simpan {
  background-color: #1e3a8a;
  color: white;
  border: none;
  padding: 10px 32px;
  border-radius: 8px;
  font-weight: 600;
  font-size: 14px;
  cursor: pointer;
  transition: background 0.2s;
}

.btn-simpan:hover {
  background-color: #1e40af;
}

/* Responsive Breakpoints */
@media (max-width: 1024px) {
  .form-grid { grid-template-columns: repeat(2, 1fr); gap: 25px; }
}
@media (max-width: 640px) {
  .form-grid { grid-template-columns: 1fr; gap: 20px; }
}
</style>