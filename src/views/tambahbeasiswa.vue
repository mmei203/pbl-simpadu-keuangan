<template>
  <div class="main-content">
    <header class="topbar">
      <div>
        <p class="breadcrumb">Manajemen Keuangan > Beasiswa > Tambah</p>
        <h1>Tambah data penerima beasiswa</h1>
        <p class="subtitle">Kelola beasiswa mahasiswa baru</p>
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
      <form @submit.prevent="saveData">
        <div class="form-container">
          
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
              <button type="button" class="search-inline-btn">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                </svg>
              </button>
            </div>
            <p v-if="nimNotFound" class="error-text">Mahasiswa tidak ditemukan</p>
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
            <label for="beasiswa">Pilih Beasiswa</label>
            <select id="beasiswa" v-model="form.jenis_beasiswa" required>
              <option value="" disabled>Pilih Jenis Beasiswa</option>
              <option value="KIP-Kuliah">KIP-Kuliah</option>
              <option value="Beasiswa Prestasi">Beasiswa Prestasi</option>
              <option value="Beasiswa Internal">Beasiswa Internal</option>
            </select>
          </div>

          <div class="form-group">
            <label for="potongan">Nominal Potongan</label>
            <input 
              type="text" 
              id="potongan" 
              v-model="form.potongan" 
              placeholder="100%" 
              required 
            />
          </div>

          <div class="form-actions">
            <button type="submit" class="btn-simpan">Simpan</button>
          </div>

        </div>
      </form>
    </section>
  </div>
</template>

<script setup>
import { reactive, ref } from "vue";
import { useRouter } from "vue-router";

const router = useRouter();
const nimNotFound = ref(false); // Sesuai foto ada label "Mahasiswa tidak ditemukan"

const form = reactive({
  nim: "",
  nama: "",
  jenis_beasiswa: "",
  potongan: "100%"
});

const saveData = () => {
  console.log("Menyimpan data beasiswa:", form);
  alert("Data penerima beasiswa berhasil disimpan!");
  router.push("/beasiswa");
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

/* FORM CARD */
.form-card {
  max-width: 500px; /* Sesuai foto, form-nya tidak melebar full */
  margin-left: 0;
}

.form-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
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
  font-size: 14px;
  font-family: 'Poppins', sans-serif;
  outline: none;
  background-color: white;
  transition: border-color 0.2s;
}

.readonly-input {
  background-color: #f8fafc;
  color: #64748b;
  cursor: not-allowed;
}

.form-group input:focus, .form-group select:focus {
  border-color: #1e3a8a;
}

/* NIM Search Input */
.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.input-wrapper input {
  width: 100%;
  padding-right: 45px;
}

.search-inline-btn {
  position: absolute;
  right: 12px;
  background: none;
  border: none;
  color: #94a3b8;
  cursor: pointer;
  display: flex;
  align-items: center;
}

.search-inline-btn svg {
  width: 18px;
  height: 18px;
}

.error-text {
  font-size: 11px;
  color: #ef4444;
  margin: 2px 0 0 5px;
}

/* BUTTON SIMPAN */
.form-actions {
  margin-top: 10px;
}

.btn-simpan {
  background-color: #1e3a8a;
  color: white;
  border: none;
  padding: 10px 35px;
  border-radius: 8px;
  font-weight: 600;
  font-size: 14px;
  cursor: pointer;
  transition: background 0.3s;
}

.btn-simpan:hover {
  background-color: #1e40af;
}
</style>