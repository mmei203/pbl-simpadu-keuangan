<template>
  <div class="main-content">
    <header class="topbar">
      <div>
        <p class="breadcrumb">Beranda > Notifikasi</p>
        <h1>Pusat Notifikasi</h1>
        <p class="subtitle">Pantau aktivitas dan pembaruan sistem terbaru</p>
      </div>

      <div class="profile-section">
        <button class="notif-btn active">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" d="M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0" />
          </svg>
          <span class="badge-dot"></span>
        </button>
        <div class="profile-blue">
          <img src="https://i.pravatar.cc/100" alt="profile" />
          <span>Admin Keuangan</span>
        </div>
      </div>
    </header>

    <section class="notification-container">
      <div class="notif-header">
        <h2>Semua Notifikasi</h2>
        <button class="btn-mark-read" @click="markAllAsRead">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4">
            <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5" />
          </svg>
          Tandai semua dibaca
        </button>
      </div>

      <div class="notif-list">
        <h3 class="time-label">Hari Ini</h3>
        
        <div 
          v-for="item in todayNotifs" 
          :key="item.id" 
          class="notif-card" 
          :class="{ unread: !item.isRead }"
        >
          <div class="icon-box" :class="item.type">
            <svg v-if="item.type === 'payment'" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 18.75a60.07 60.07 0 0115.797 2.101c.727.198 1.453-.342 1.453-1.096V18.75M3.75 4.5v.75A.75.75 0 013 6h-.75m0 0v-.375c0-.621.504-1.125 1.125-1.125H20.25M2.25 6v9m18-10.5v.75c0 .414.336.75.75.75h.75m-1.5-1.5h.375c.621 0 1.125.504 1.125 1.125v9.75c0 .621-.504 1.125-1.125 1.125h-.375m1.5-1.5H21a.75.75 0 00-.75.75v.75m0 0H3.75m0 0h-.375a1.125 1.125 0 01-1.125-1.125V15m1.5 1.5v-.75A.75.75 0 003 15h-.75M15 10.5a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
            <svg v-else-if="item.type === 'warning'" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
            <svg v-else xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M11.25 11.25l.041-.02a.75.75 0 011.063.852l-.708 2.836a.75.75 0 001.063.853l.041-.021M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9-3.75h.008v.008H12V8.25z" />
            </svg>
          </div>
          <div class="notif-content">
            <h4>{{ item.title }}</h4>
            <p>{{ item.message }}</p>
            <span class="time">{{ item.time }}</span>
          </div>
          <div v-if="!item.isRead" class="unread-indicator"></div>
        </div>

        <h3 class="time-label">Kemarin</h3>
        
        <div 
          v-for="item in yesterdayNotifs" 
          :key="item.id" 
          class="notif-card" 
          :class="{ unread: !item.isRead }"
        >
          <div class="icon-box" :class="item.type">
            <svg v-if="item.type === 'payment'" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 18.75a60.07 60.07 0 0115.797 2.101c.727.198 1.453-.342 1.453-1.096V18.75M3.75 4.5v.75A.75.75 0 013 6h-.75m0 0v-.375c0-.621.504-1.125 1.125-1.125H20.25M2.25 6v9m18-10.5v.75c0 .414.336.75.75.75h.75m-1.5-1.5h.375c.621 0 1.125.504 1.125 1.125v9.75c0 .621-.504 1.125-1.125 1.125h-.375m1.5-1.5H21a.75.75 0 00-.75.75v.75m0 0H3.75m0 0h-.375a1.125 1.125 0 01-1.125-1.125V15m1.5 1.5v-.75A.75.75 0 003 15h-.75M15 10.5a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
            <svg v-else xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M11.25 11.25l.041-.02a.75.75 0 011.063.852l-.708 2.836a.75.75 0 001.063.853l.041-.021M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9-3.75h.008v.008H12V8.25z" />
            </svg>
          </div>
          <div class="notif-content">
            <h4>{{ item.title }}</h4>
            <p>{{ item.message }}</p>
            <span class="time">{{ item.time }}</span>
          </div>
        </div>

      </div>
    </section>
  </div>
</template>

<script setup>
import { ref } from "vue";

// Data dummy notifikasi untuk hari ini
const todayNotifs = ref([
  {
    id: 1,
    type: "payment", // payment, warning, info
    title: "Pembayaran UKT Berhasil",
    message: "Mahasiswa Budi Siregar (C030324077) telah melakukan pembayaran UKT sebesar Rp 1.500.000.",
    time: "10:30 WITA",
    isRead: false
  },
  {
    id: 2,
    type: "warning",
    title: "Tenggat Waktu Cicilan",
    message: "Terdapat 5 mahasiswa yang melewati batas waktu pembayaran cicilan bulan ini.",
    time: "09:15 WITA",
    isRead: false
  },
  {
    id: 3,
    type: "info",
    title: "Pengajuan Beasiswa Baru",
    message: "Siti Fatimah (C030324099) mengajukan pendaftaran KIP-Kuliah.",
    time: "08:00 WITA",
    isRead: true
  }
]);

// Data dummy notifikasi kemarin
const yesterdayNotifs = ref([
  {
    id: 4,
    type: "payment",
    title: "Konfirmasi Pembayaran Manual",
    message: "Admin telah mengonfirmasi pembayaran sisa tagihan dari Aditya Pratama.",
    time: "Kemarin, 14:20 WITA",
    isRead: true
  },
  {
    id: 5,
    type: "info",
    title: "Pembaruan Sistem Selesai",
    message: "Maintenance database keuangan semester ganjil telah selesai dilakukan.",
    time: "Kemarin, 23:00 WITA",
    isRead: true
  }
]);

const markAllAsRead = () => {
  todayNotifs.value.forEach(notif => notif.isRead = true);
  yesterdayNotifs.value.forEach(notif => notif.isRead = true);
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

.profile-section { display: flex; align-items: center; gap: 15px; }
.notif-btn {
  background: white; border: 1px solid #e2e8f0; width: 42px; height: 42px;
  border-radius: 12px; cursor: pointer; display: flex; align-items: center; justify-content: center;
  position: relative;
}
.notif-btn.active .badge-dot {
  position: absolute; top: 10px; right: 12px; width: 8px; height: 8px;
  background-color: #ef4444; border-radius: 50%;
}
.profile-blue {
  background: #1e3a8a; color: white; padding: 8px 18px;
  border-radius: 12px; display: flex; align-items: center; gap: 12px; font-size: 13px; font-weight: 500;
}
.profile-blue img { width: 30px; height: 30px; border-radius: 50%; border: 2px solid rgba(255,255,255,0.2); }

/* NOTIFICATION CONTAINER */
.notification-container {
  background: white;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  max-width: 800px; /* Lebar maksimal agar enak dibaca */
  padding: 25px 30px;
}

.notif-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
  border-bottom: 1px solid #f1f5f9;
  padding-bottom: 15px;
}

.notif-header h2 {
  font-size: 18px;
  font-weight: 600;
  color: #1e293b;
  margin: 0;
}

.btn-mark-read {
  display: flex;
  align-items: center;
  gap: 6px;
  background: none;
  border: none;
  color: #3b82f6;
  font-size: 13px;
  font-weight: 500;
  font-family: 'Poppins', sans-serif;
  cursor: pointer;
  transition: color 0.2s;
}
.btn-mark-read:hover { color: #2563eb; }
.btn-mark-read svg { width: 16px; height: 16px; }

/* LIST NOTIFICATION */
.time-label {
  font-size: 13px;
  font-weight: 600;
  color: #64748b;
  margin: 20px 0 15px 0;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.notif-card {
  display: flex;
  align-items: flex-start;
  gap: 16px;
  padding: 16px;
  border-radius: 12px;
  margin-bottom: 12px;
  background-color: white;
  border: 1px solid transparent;
  transition: all 0.2s ease;
}

.notif-card:hover {
  background-color: #f8fafc;
}

.notif-card.unread {
  background-color: #eff6ff;
  border-color: #dbeafe;
}

/* IKON STATUS */
.icon-box {
  width: 42px;
  height: 42px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.icon-box svg { width: 22px; height: 22px; }

.icon-box.payment { background-color: #dcfce7; color: #15803d; }
.icon-box.warning { background-color: #fef08a; color: #a16207; }
.icon-box.info { background-color: #e0e7ff; color: #4338ca; }

/* KONTEN NOTIF */
.notif-content {
  flex: 1;
}

.notif-content h4 {
  font-size: 14px;
  font-weight: 600;
  color: #1e293b;
  margin: 0 0 4px 0;
}

.notif-content p {
  font-size: 13px;
  color: #475569;
  margin: 0 0 8px 0;
  line-height: 1.5;
}

.notif-content .time {
  font-size: 11px;
  color: #94a3b8;
  font-weight: 500;
}

/* DOT UNREAD */
.unread-indicator {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background-color: #3b82f6;
  margin-top: 6px;
  flex-shrink: 0;
}

/* RESPONSIVE */
@media (max-width: 640px) {
  .notification-container { padding: 15px; }
  .notif-card { flex-direction: column; gap: 10px; position: relative; }
  .unread-indicator { position: absolute; top: 16px; right: 16px; }
}
</style>