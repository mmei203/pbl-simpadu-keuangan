<template>
  <div class="app-container">
    <div class="login-page">
      <div class="login-card">
        <div class="login-image">
          <img src="/POLIBAN.jpg" alt="Foto Universitas" @error="(e) => e.target.src = 'https://images.unsplash.com/photo-1541339907198-e08759df9a13?q=80&w=1000&auto=format&fit=crop'" />
          <div class="image-overlay">
            <h2>SIMPADU</h2>
            <p>Sistem Keuangan Politeknik Negeri Banjarmasin</p>
          </div>
        </div>

        <div class="login-form-container">
          <div class="form-header">
            <div class="logo-wrapper">
              <img src="/ICONSIMPADU.png" alt="Logo" class="main-logo" @error="(e) => e.target.src = 'https://via.placeholder.com/60'" />
            </div>
            <h1>Selamat Datang</h1>
            <p>PORTAL ADMIN KEUANGAN</p>
          </div>

          <div v-if="errorMessage" class="error-alert">
            {{ errorMessage }}
          </div>

          <form @submit.prevent="handleLogin" class="login-form">
            <div class="input-group">
              <label>Username</label>
              <div class="input-wrapper">
                <span class="icon">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="input-icon-svg">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z" />
                  </svg>
                </span>
                <input type="text" v-model="payload.email" placeholder="Masukkan username admin" required />
              </div>
            </div>

            <div class="input-group">
              <label>Password</label>
              <div class="input-wrapper">
                <span class="icon">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="input-icon-svg">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z" />
                  </svg>
                </span>
                <input :type="showPassword ? 'text' : 'password'" v-model="payload.password" placeholder="Masukkan password" required />
                
                <button type="button" class="toggle-eye" @click="showPassword = !showPassword">
                  <svg v-if="showPassword" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="eye-icon-svg">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                  </svg>
                  <svg v-else xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="eye-icon-svg">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88" />
                  </svg>
                </button>
              </div>
            </div>

            <button type="submit" class="btn-masuk" :disabled="isLoading">
              <span v-if="!isLoading">Masuk sebagai Admin</span>
              <span v-else class="loader"></span>
            </button>
          </form>
          <div class="footer-note">© 2026 SIMPADU - POLIBAN</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import axios from 'axios';
import { reactive, ref } from 'vue';
import { useRouter } from 'vue-router'; 

const router = useRouter();
const isLoading = ref(false);
const errorMessage = ref('');

const username = ref('');
const password = ref('');
const showPassword = ref(false);

const ADMIN_DUMMY = {
  user: 'admin',
  pass: 'admin123'
};

const payload = reactive({
  email: "",
  password: "",
});

const handleLogin = () => {
  isLoading.value = true;
  errorMessage.value = '';
  axios.post('https://be.karlearn.site/api/auth/login', payload)
    .then(response => {
      console.log("Login Berhasil!", response.data);
      localStorage.setItem('token', response.data.data.access_token); // Simpan token jika diperlukan
      router.push('/dashboard').catch(err => {
        console.error("Gagal pindah halaman:", err);
      });
    })
    .catch(error => {
      console.error("Login Gagal:", error);
      errorMessage.value = "Username atau Password Admin salah!";
    })
    .finally(() => {
      isLoading.value = false;
    });

  // Simulasi loading 1 detik
  // setTimeout(() => {
  //   if (username.value === ADMIN_DUMMY.user && password.value === ADMIN_DUMMY.pass) {
  //     console.log("Login Berhasil!");
  //     // Pastikan di router/index.js ada path '/dashboard'
  //     router.push('/dashboard').catch(err => {
  //       console.error("Gagal pindah halaman:", err);
  //     });
  //   } else {
  //     errorMessage.value = "Username atau Password Admin salah!";
  //   }
  //   isLoading.value = false;
  // }, 1000);

};
</script>

<style scoped>
* { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }

.login-page { height: 100vh; display: flex; align-items: center; justify-content: center; background: #f0f4f8; }
.login-card { width: 900px; height: 550px; display: flex; background: white; border-radius: 20px; box-shadow: 0 20px 40px rgba(0,0,0,0.1); overflow: hidden; }

.login-image { flex: 1.2; position: relative; background: #1e3a8a; }
.login-image img { width: 100%; height: 100%; object-fit: cover; opacity: 0.6; }
.image-overlay { position: absolute; bottom: 40px; left: 30px; color: white; }

.login-form-container { flex: 1; padding: 40px; display: flex; flex-direction: column; justify-content: center; }
.form-header { text-align: center; margin-bottom: 30px; }
.main-logo { width: 60px; margin-bottom: 10px; }

.error-alert { background: #fef2f2; color: #ef4444; padding: 10px; border-radius: 8px; font-size: 12px; text-align: center; margin-bottom: 15px; border: 1px solid #fee2e2; }

.input-group { margin-bottom: 15px; }
.input-group label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 5px; color: #334155; }
.input-wrapper { position: relative; display: flex; align-items: center; }
.input-wrapper input { width: 100%; padding: 12px 45px 12px 42px; border: 1.5px solid #e2e8f0; border-radius: 10px; outline: none; transition: 0.3s; }
.input-wrapper input:focus { border-color: #1e3a8a; box-shadow: 0 0 0 3px rgba(30, 58, 138, 0.1); }
.input-wrapper .icon { position: absolute; left: 12px; display: flex; align-items: center; }
.input-icon-svg { width: 20px; height: 20px; color: #64748b; }

.toggle-eye { position: absolute; right: 12px; background: none; border: none; cursor: pointer; display: flex; color: #94a3b8; }
.eye-icon-svg { width: 20px; height: 20px; }

.btn-masuk { background: #1e3a8a; color: white; padding: 12px; border: none; border-radius: 10px; cursor: pointer; font-weight: 600; margin-top: 10px; transition: 0.3s; width: 100%; }
.btn-masuk:hover { background: #162a63; transform: translateY(-1px); }
.btn-masuk:disabled { opacity: 0.7; cursor: not-allowed; }

.loader { width: 20px; height: 20px; border: 2px solid #FFF; border-bottom-color: transparent; border-radius: 50%; display: inline-block; animation: rotation 1s linear infinite; }
@keyframes rotation { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }

.footer-note { text-align: center; margin-top: 20px; font-size: 11px; color: #94a3b8; }
</style>