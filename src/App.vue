<template>
  <div class="dashboard-layout">
    <aside v-if="!isLoginPage" class="sidebar" :class="{ collapsed: isCollapsed }">
      <div class="logo-section">
        <div class="logo-circle">
          <img src="/ICONSIMPADU.png" alt="Logo" fonts="" />
        </div>
        <h2 v-if="!isCollapsed">SIMPADU</h2>
        <button class="toggle-btn-inline" @click="isCollapsed = !isCollapsed">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
          </svg>
        </button>
      </div>

      <nav class="menu">
        <div v-for="item in menus" :key="item.name">
          <button
            v-if="!item.children"
            class="menu-item"
            :class="{ active: activeMenu === item.name }"
            @click="handleMenuClick(item)"
          >
            <span class="icon-wrapper" v-html="item.icon"></span>
            <span v-if="!isCollapsed" class="menu-text">{{ item.name }}</span>
          </button>

          <div v-else>
            <button
              class="menu-item"
              :class="{ active: openDropdown === item.name || isSubMenuActive(item) }"
              @click="toggleDropdown(item.name)"
            >
              <span class="icon-wrapper" v-html="item.icon"></span>
              <span v-if="!isCollapsed" class="menu-text">{{ item.name }}</span>
              <span v-if="!isCollapsed" class="arrow" :class="{ open: openDropdown === item.name }">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" style="width: 12px;"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" /></svg>
              </span>
            </button>
            
            <div v-if="openDropdown === item.name && !isCollapsed" class="sub-menu-container">
              <button 
                v-for="sub in item.children" 
                :key="sub.name"
                class="sub-item"
                :class="{ active: route.path === sub.path }"
                @click="handleSubMenuClick(sub)"
              >
                <span class="sub-icon" v-if="sub.icon" v-html="sub.icon"></span>
                {{ sub.name }}
              </button>
            </div>
          </div>
        </div>
      </nav>

      <button class="logout-btn" @click="showLogoutModal = true">
        <span class="icon-wrapper">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 9V5.25A2.25 2.25 0 0 1 10.5 3h6a2.25 2.25 0 0 1 2.25 2.25v13.5A2.25 2.25 0 0 1 16.5 21h-6a2.25 2.25 0 0 1-2.25-2.25V15m-3 0-3-3m0 0 3-3m-3 3H15" />
          </svg>
        </span>
        <span v-if="!isCollapsed">Logout</span>
      </button>
    </aside>

    <main class="main-container">
      <router-view />
    </main>

    <Transition name="fade">
      <div v-if="showLogoutModal" class="modal-overlay" @click.self="showLogoutModal = false">
        <div class="modal-content">
          <div class="modal-icon">⚠️</div>
          <h3>Konfirmasi Keluar</h3>
          <p>Apakah Anda yakin ingin logout?</p>
          <div class="modal-actions">
            <button class="btn-cancel" @click="showLogoutModal = false">Batal</button>
            <button class="btn-confirm" @click="confirmLogout">Ya, Logout</button>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup>
import { ref, computed } from "vue";
import { useRouter, useRoute } from "vue-router";

const router = useRouter();
const route = useRoute();
const isCollapsed = ref(false);
const activeMenu = ref("Dashboard");
const openDropdown = ref("Manajemen"); 
const showLogoutModal = ref(false);

const isLoginPage = computed(() => route.path === "/login" || route.path === "/");

const handleMenuClick = (item) => {
  activeMenu.value = item.name;
  router.push(item.path);
};

const handleSubMenuClick = (sub) => {
  router.push(sub.path);
};

const toggleDropdown = (name) => {
  openDropdown.value = openDropdown.value === name ? null : name;
};

const isSubMenuActive = (item) => {
  return item.children?.some(sub => route.path === sub.path);
};

const confirmLogout = () => {
  showLogoutModal.value = false;
  router.push("/login");
};

const menus = [
  { 
    name: "Dashboard", 
    path: "/dashboard",
    icon: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25" /></svg>` 
  },
  { 
    name: "Manajemen", 
    icon: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6.042A8.967 8.967 0 0 0 6 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 0 1 6 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 0 1 6-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0 0 18 18a8.967 8.967 0 0 0-6 2.292m0-14.25v14.25" /></svg>`,
    children: [
      { name: "Status Mahasiswa", path: "/status-mahasiswa", icon: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 3.077 16.2M15 19.128L15.39 15.75M3.077 16.2a12.318 12.318 0 0 1-.896-2.153m5.921-10.9a6.375 6.375 0 1 0-7.5 6.375" /></svg>` },
      { name: "UKT", path: "/ukt", icon: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 8.25h19.5M2.25 9h19.5m-16.5 5.25h6m-6 2.25h3m-3.75 3h15a2.25 2.25 0 0 0 2.25-2.25V6.75A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25v10.5A2.25 2.25 0 0 0 4.5 19.5Z" /></svg>` },
      { name: "Beasiswa", path: "/beasiswa", icon: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M4.26 10.147a60.436 60.436 0 0 0-2.633.156A10.25 10.25 0 0 1 19.668 19H3.75l.577-21.927m19.31 0c.58.232 1.159.479 1.738.726a10.25 10.25 0 0 1-17.313-7.987m0 0a20.055 20.055 0 0 1 1.738-.726" /></svg>` },
      { name: "Cicilan", path: "/cicilan", icon: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 8.25h19.5M2.25 9h19.5m-16.5 5.25h6m-6 2.25h3m-3.75 3h15a2.25 2.25 0 0 0 2.25-2.25V6.75A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25v10.5A2.25 2.25 0 0 0 4.5 19.5Z" /></svg>` }
    ]
  },
  { 
    name: "Pembayaran",
    path: "/pembayaran",
    icon: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 8.25h19.5M2.25 9h19.5m-16.5 5.25h6m-6 2.25h3m-3.75 3h15a2.25 2.25 0 0 0 2.25-2.25V6.75A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25v10.5A2.25 2.25 0 0 0 4.5 19.5Z" /></svg>`
  },
];
</script>

<style>
/* ... CSS sama seperti sebelumnya ... */
.dashboard-layout { display: flex; min-height: 100vh; background: #f4f7fa;}
.sidebar { width: 240px; background: #1e3a8a; color: white; padding: 20px ; padding-bottom: 9px;  display: flex; flex-direction: column; transition: 0.3s; flex-shrink: 0; }
.sidebar.collapsed { width: 80px; }
.logo-section { display: flex; align-items: center; gap: 10px; margin-bottom: 30px; padding: 0 10px; }
.logo-circle { min-width: 32px; height: 32px; border-radius: 8px; overflow: hidden; }
.logo-circle img { width: 100%; height: 100%; object-fit: cover; }
.toggle-btn-inline { background: none; border: none; color: white; cursor: pointer; margin-left: auto; }
.menu { display: flex; flex-direction: column; gap: 9px; flex: 1; }
.menu-item { background: transparent; border: none; color: #cbd5e1; padding: 12px 15px; border-radius: 12px; display: flex; align-items: center; gap: 12px; cursor: pointer; width: 100%; transition: 0.2s; font-size: 13px; }
.menu-item:hover, .menu-item.active { background: rgba(255, 255, 255, 0.1); color: white; }
.icon-wrapper { width: 20px; display: flex; justify-content: center; }
.icon-wrapper svg { width: 20px; height: 20px; }
.arrow { margin-left: auto; transition: 0.3s; }
.arrow.open { transform: rotate(180deg); }
.sub-menu-container { padding-left: 35px; display: flex; flex-direction: column; gap: 5px; margin: 5px 0 10px; }
.sub-item { background: none; border: none; color: #cbd5e1; text-align: left; font-size: 12px; padding: 8px; cursor: pointer; border-radius: 8px; transition: 0.2s; display: flex; align-items: center; gap: 8px; }
.sub-icon { width: 16px; height: 16px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.sub-icon svg { width: 16px; height: 16px; }
.sub-item:hover, .sub-item.active { color: white; background: rgba(255,255,255,0.1); }
.main-container { flex: 1; overflow-y: auto; }
.logout-btn { margin-top: auto; background: rgba(255, 255, 255, 0.05); border: none; color: #fca5a5; padding: 12px; border-radius: 12px; display: flex; gap: 12px; cursor: pointer; }
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 1000; }
.modal-content { background: white; padding: 25px; border-radius: 15px; text-align: center; color: #333; width: 300px; }
.modal-actions { display: flex; gap: 10px; margin-top: 20px; }
.btn-cancel { flex: 1; padding: 8px; border-radius: 8px; border: 1px solid #ddd; cursor: pointer; }
.btn-confirm { flex: 1; padding: 8px; border-radius: 8px; border: none; background: #ef4444; color: white; cursor: pointer; }
</style>