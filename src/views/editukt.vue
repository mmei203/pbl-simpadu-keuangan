<template>
  <div v-if="showEditModal" class="modal-overlay">
    <div class="modal-card">
      <div class="modal-header">
        <div class="header-title">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="header-icon">
            <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
          </svg>
          <h2>Edit Data Pembayaran UKT</h2>
        </div>
        <button class="close-btn" @click="$emit('close')">&times;</button>
      </div>

      <form @submit.prevent="handleUpdate" class="modal-form">
        <div class="form-grid">
          <div class="form-group full-width">
            <label>Nama Mahasiswa</label>
            <input type="text" v-model="editForm.nama" readonly class="readonly-input" />
          </div>

          <div class="form-group">
            <label>NIM</label>
            <input type="text" v-model="editForm.nim" readonly class="readonly-input" />
          </div>

          <div class="form-group">
            <label>Program Studi</label>
            <input type="text" v-model="editForm.prodi" readonly class="readonly-input" />
          </div>

          <div class="form-group">
            <label>Semester</label>
            <input type="text" v-model="editForm.semester" readonly class="readonly-input" />
          </div>

          <div class="form-group full-width">
            <label>Golongan UKT</label>
            <!-- Loading state saat fetch kategori -->
            <div v-if="isLoadingKategori" class="loading-kategori">Memuat daftar golongan UKT...</div>
            <select v-else v-model="editForm.id_kategori_ukt" required>
              <option value="">Pilih Golongan UKT</option>
              <option
                v-for="kategori in listKategoriUkt"
                :key="kategori.ID_KATEGORI"
                :value="kategori.ID_KATEGORI"
              >
                {{ kategori.NAMA_KATEGORI }} — Rp {{ formatRupiah(kategori.NOMINAL) }}
              </option>
            </select>
          </div>
        </div>

        <div class="modal-footer">
          <button type="button" class="btn-cancel" @click="$emit('close')" :disabled="isUpdating">Batal</button>
          <button type="submit" class="btn-update" :disabled="isUpdating || isLoadingKategori">
            {{ isUpdating ? "Menyimpan..." : "Perbarui Pembayaran" }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { reactive, watch, ref } from "vue";
import axios from "axios";

const props = defineProps({
  showEditModal: Boolean,
  selectedData: Object
});

const emit = defineEmits(['close', 'update']);

const isUpdating        = ref(false);
const isLoadingKategori = ref(false);
const listKategoriUkt   = ref([]);

const editForm = reactive({
  id:              "",
  id_mahasiswa:    "",
  nama:            "",
  nim:             "",
  prodi:           "",
  semester:        "",
  id_kategori_ukt: "",
});

// Format angka ke Rupiah
const formatRupiah = (nominal) => {
  if (!nominal) return "0";
  return Number(nominal).toLocaleString("id-ID");
};

// Fetch daftar kategori UKT dari API
const fetchKategoriUkt = async () => {
  isLoadingKategori.value = true;
  try {
    const token = localStorage.getItem("token");
    const res = await axios.get(
      "https://api-keuangan-4a.akufarish.my.id:8873/api/kategori-ukt",
      {
        headers: {
          Accept: "application/json",
          ...(token && { Authorization: `Bearer ${token}` }),
        },
      }
    );

    // Handle berbagai struktur response
    const body = res.data;
    if (Array.isArray(body)) {
      listKategoriUkt.value = body;
    } else if (body.data && Array.isArray(body.data)) {
      listKategoriUkt.value = body.data;
    } else if (body.data?.data && Array.isArray(body.data.data)) {
      listKategoriUkt.value = body.data.data;
    } else {
      listKategoriUkt.value = [];
    }
  } catch (error) {
    console.error("Gagal fetch kategori UKT:", error);
    listKategoriUkt.value = [];
  } finally {
    isLoadingKategori.value = false;
  }
};

// Isi form saat modal dibuka & fetch kategori
watch(() => props.showEditModal, (isOpen) => {
  if (isOpen) {
    fetchKategoriUkt();
  }
});

watch(() => props.selectedData, (newVal) => {
  if (!newVal) return;

  console.log("editukt selectedData:", newVal);

  const idKeuangan =
    newVal.id           || newVal.ID           ||
    newVal.id_keuangan  || newVal.ID_KEUANGAN  ||
    newVal.keuangan_id;

  const idMhs =
    newVal.id_mahasiswa || newVal.ID_MAHASISWA ||
    newVal.mahasiswa_id || newVal.MAHASISWA_ID;

  Object.assign(editForm, {
    id:              idKeuangan || "",
    id_mahasiswa:    idMhs      || "",
    nama:            newVal.nama || newVal.nama_mahasiswa || newVal.NAMA || "",
    nim:             newVal.nim  || newVal.NIM  || "",
    prodi:           newVal.prodi?.name || newVal.prodi_clean || newVal.prodi || "",
    semester:        newVal.semester    || "",
    // Preset golongan yang sudah ada jika field id_kategori_ukt tersedia
    id_kategori_ukt: newVal.id_kategori_ukt || newVal.ID_KATEGORI_UKT || newVal.kategori_ukt_id || "",
  });
}, { immediate: true });

const handleUpdate = async () => {
  if (!editForm.id_kategori_ukt) {
    alert("Pilih golongan UKT terlebih dahulu.");
    return;
  }

  // Gunakan id keuangan atau id mahasiswa sebagai endpoint
  const idEndpoint = editForm.id || editForm.id_mahasiswa;
  if (!idEndpoint) {
    alert("ID data tidak ditemukan, tidak bisa update.");
    return;
  }

  isUpdating.value = true;
  try {
    const token = localStorage.getItem("token");

    await axios.put(
      `https://api-keuangan-4a.akufarish.my.id:8873/api/keuangan-mahasiswa/${idEndpoint}`,
      {
        id_kategori_ukt: editForm.id_kategori_ukt,
      },
      {
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
          ...(token && { Authorization: `Bearer ${token}` }),
        },
      }
    );

    alert("Golongan UKT berhasil diperbarui!");
    emit("update", { ...editForm });
  } catch (error) {
    console.error("Gagal update UKT:", error);
    const msg = error.response?.data?.message || "Gagal memperbarui data UKT. Coba lagi.";
    alert(`Error: ${msg}`);
  } finally {
    isUpdating.value = false;
  }
};
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

.modal-overlay {
  position: fixed; top: 0; left: 0; width: 100%; height: 100%;
  background: rgba(15, 23, 42, 0.7); backdrop-filter: blur(5px);
  display: flex; align-items: center; justify-content: center; z-index: 9999;
  font-family: 'Poppins', sans-serif;
}
.modal-card {
  background: white; width: 90%; max-width: 600px;
  border-radius: 20px; overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  animation: slideUp 0.3s ease-out;
}
@keyframes slideUp {
  from { transform: translateY(30px); opacity: 0; }
  to   { transform: translateY(0);    opacity: 1; }
}
.modal-header {
  padding: 22px 25px; border-bottom: 1px solid #f1f5f9;
  display: flex; justify-content: space-between; align-items: center;
  background: #f8fafc;
}
.header-title { display: flex; align-items: center; gap: 12px; }
.header-icon  { width: 22px; color: #1e3a8a; }
.modal-header h2 { font-size: 18px; font-weight: 700; color: #1e293b; margin: 0; }
.close-btn { background: none; border: none; font-size: 28px; color: #94a3b8; cursor: pointer; }
.modal-form { padding: 25px; }
.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }
.full-width { grid-column: span 2; }
.form-group { display: flex; flex-direction: column; gap: 8px; }
.form-group label { font-size: 13px; font-weight: 600; color: #475569; }
.form-group input, .form-group select {
  padding: 12px 14px; border: 1.5px solid #e2e8f0; border-radius: 12px;
  font-size: 14px; font-family: 'Poppins', sans-serif; outline: none; transition: 0.2s;
  background-color: #ffffff;
}
.form-group input:focus, .form-group select:focus {
  border-color: #1e3a8a; box-shadow: 0 0 0 4px rgba(30, 58, 138, 0.08);
}
.readonly-input { background-color: #f8fafc !important; color: #64748b; cursor: not-allowed; border-style: dashed !important; }
.loading-kategori {
  padding: 12px 14px; border: 1.5px dashed #e2e8f0; border-radius: 12px;
  font-size: 13px; color: #94a3b8; background: #f8fafc;
}
.modal-footer { margin-top: 35px; display: flex; justify-content: flex-end; gap: 12px; }
.btn-cancel {
  padding: 12px 25px; border: 1.5px solid #e2e8f0; background: white;
  border-radius: 12px; color: #64748b; font-weight: 600; cursor: pointer; transition: 0.2s;
}
.btn-update {
  padding: 12px 30px; background: #1e3a8a; color: white; border: none;
  border-radius: 12px; font-weight: 600; cursor: pointer; transition: 0.3s;
}
.btn-update:hover { background: #1e40af; transform: translateY(-1px); }
.btn-cancel:hover { background: #f8fafc; color: #1e293b; }
.btn-update:disabled, .btn-cancel:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }
</style>