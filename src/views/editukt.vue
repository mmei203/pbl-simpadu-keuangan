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
            <input type="text" v-model="editForm.prodi_nama" readonly class="readonly-input" />
          </div>

          <div class="form-group full-width">
            <label>Golongan UKT (Maksimal Golongan 5)</label>
            <div v-if="isLoadingKategori" class="loading-kategori">Memuat daftar golongan UKT...</div>
            <select v-else v-model="editForm.id_kategori_ukt" required>
              <option value="">Pilih Golongan UKT</option>
              <option
                v-for="kategori in filteredKategoriUkt"
                :key="kategori.ID_KATEGORI || kategori.id"
                :value="kategori.ID_KATEGORI || kategori.id"
              >
                {{ kategori.GOLONGAN_UKT || kategori.golongan_ukt }} — Rp {{ formatRupiah(kategori.NOMINAL_UKT || kategori.NOMINAL || kategori.nominal) }}
              </option>
            </select>
            <p v-if="filteredKategoriUkt.length === 0 && !isLoadingKategori" class="info-helper">
              *Tidak ada golongan 1-5 yang pas untuk prodi ID: {{ editForm.prodi_id || 'Kosong' }}.
            </p>
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
import { reactive, watch, ref, computed } from "vue";
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
  prodi_nama:      "",
  prodi_id:        "",
  semester:        "",
  id_kategori_ukt: "",
});

const formatRupiah = (nominal) => {
  if (!nominal) return "0";
  return Number(nominal).toLocaleString("id-ID");
};

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
    console.error("Gagal fetch master kategori UKT:", error);
    listKategoriUkt.value = [];
  } finally {
    isLoadingKategori.value = false;
  }
};

const filteredKategoriUkt = computed(() => {
  if (!listKategoriUkt.value || listKategoriUkt.value.length === 0) return [];

  return listKategoriUkt.value.filter((kategori) => {
    const namaGolongan = String(kategori.GOLONGAN_UKT || kategori.golongan_ukt || "").toLowerCase();
    
    const idProdiKategori = String(kategori.ID_PRODI || kategori.id_prodi || "").trim();
    const idProdiMahasiswa = String(editForm.prodi_id || "").trim();

    const matchAngka = namaGolongan.match(/\d+/);
    const angkaGolongan = matchAngka ? parseInt(matchAngka[0], 10) : null;

    const lolosGolongan = angkaGolongan !== null && angkaGolongan <= 5;
    const lolosProdi = !idProdiMahasiswa || idProdiKategori === idProdiMahasiswa;

    return lolosGolongan && lolosProdi;
  });
});

watch(() => props.showEditModal, (isOpen) => {
  if (isOpen) {
    fetchKategoriUkt();
  }
});

watch(() => props.selectedData, (newVal) => {
  if (!newVal) return;

  console.log("editukt menangkap selectedData:", newVal);

  // Sesuaikan bagian ini agar mendeteksi ID_KEUANGAN_MHS terlebih dahulu
  const idKeuangan =
    newVal.ID_KEUANGAN_MHS ||
    newVal.id_keuangan_mhs ||
    newVal.keuangan_id     ||
    newVal.id_keuangan     ||
    newVal.ID_KEUANGAN     ||
    null;

  const idMhs =
    newVal.id_mahasiswa || newVal.ID_MAHASISWA || newVal.mahasiswa_id || "";

  // Sisa kode ke bawah tetap sama...
  const prodiIdDidapat = newVal.id_prodi || newVal.prodi_id || newVal.PRODI_ID || newVal.prodi?.id || "";
  const prodiNamaDidapat = newVal.prodi_clean || newVal.prodi?.nama || newVal.prodi?.name || newVal.prodi || "Teknik Informatika";

  Object.assign(editForm, {
    id:              idKeuangan || "",
    id_mahasiswa:    idMhs      || "",
    nama:            newVal.nama || newVal.NAMA || "",
    nim:             newVal.nim  || newVal.NIM  || "",
    prodi_nama:      prodiNamaDidapat,
    prodi_id:        prodiIdDidapat,
    semester:        newVal.semester || "1",
    id_kategori_ukt: newVal.id_kategori_ukt || newVal.ID_KATEGORI_UKT || newVal.ID_KATEGORI || "",
  });
}, { immediate: true });

const handleUpdate = async () => {
  if (!editForm.id_kategori_ukt) {
    alert("Pilih golongan UKT terlebih dahulu.");
    return;
  }

  // Jika editForm.id kosong, gunakan id_mahasiswa atau nim agar request tetap terkirim ke API
  const idEndpoint = editForm.id || editForm.id_mahasiswa || editForm.nim;
  if (!idEndpoint) {
    alert("ID Data tidak ditemukan. Mohon cek baris mahasiswa kembali.");
    return;
  }

  isUpdating.value = true;
  try {
    const token = localStorage.getItem("token");

    const payload = {
      id_mahasiswa:    editForm.id_mahasiswa,
      nim:             editForm.nim,
      id_kategori_ukt: editForm.id_kategori_ukt,
      ID_KATEGORI_UKT: editForm.id_kategori_ukt,
      id_kategori:     editForm.id_kategori_ukt,
      ID_KATEGORI:     editForm.id_kategori_ukt
    };

    // Catatan: Ganti URL di bawah ini ke `/api/kategori-ukt/${idEndpoint}` jika backend meminta endpoint tersebut
    await axios.put(
      `https://api-keuangan-4a.akufarish.my.id:8873/api/keuangan-mahasiswa/${idEndpoint}`,
      payload,
      {
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
          ...(token && { Authorization: `Bearer ${token}` }),
        },
      }
    );

    alert("Golongan UKT berhasil diperbarui!");
    emit("update");
  } catch (error) {
    console.error("Gagal update UKT:", error);
    const msg = error.response?.data?.message || "Gagal memperbarui data UKT ke server API.";
    alert(`Error: ${msg}\n\nSilakan cek tab Network (F12) untuk melihat detail error.`);
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
  background: white; width: 95%; max-width: 530px;
  border-radius: 20px; overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  animation: slideUp 0.25s ease-out;
}
@keyframes slideUp {
  from { transform: translateY(20px); opacity: 0; }
  to   { transform: translateY(0);    opacity: 1; }
}
.modal-header {
  padding: 20px 25px; border-bottom: 1px solid #f1f5f9;
  display: flex; justify-content: space-between; align-items: center;
  background: #f8fafc;
}
.header-title { display: flex; align-items: center; gap: 12px; }
.header-icon  { width: 22px; color: #1e3a8a; }
.modal-header h2 { font-size: 16px; font-weight: 700; color: #1e293b; margin: 0; }
.close-btn { background: none; border: none; font-size: 26px; color: #94a3b8; cursor: pointer; line-height: 1; }
.modal-form { padding: 25px; }
.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.full-width { grid-column: span 2; }
.form-group { display: flex; flex-direction: column; gap: 6px; }
.form-group label { font-size: 12px; font-weight: 600; color: #475569; }
.form-group input, .form-group select {
  padding: 10px 14px; border: 1.5px solid #e2e8f0; border-radius: 12px;
  font-size: 13px; font-family: 'Poppins', sans-serif; outline: none; transition: 0.2s;
  background-color: #ffffff; color: #1e293b;
}
.form-group input:focus, .form-group select:focus {
  border-color: #1e3a8a; box-shadow: 0 0 0 4px rgba(30, 58, 138, 0.08);
}
.readonly-input { background-color: #f8fafc !important; color: #64748b; cursor: not-allowed; border-style: dashed !important; font-weight: 500; }
.loading-kategori {
  padding: 11px 14px; border: 1.5px dashed #e2e8f0; border-radius: 12px;
  font-size: 12px; color: #94a3b8; background: #f8fafc;
}
.info-helper { font-size: 11px; color: #ef4444; margin: 4px 0 0 2px; font-weight: 500; }
.modal-footer { margin-top: 30px; display: flex; justify-content: flex-end; gap: 12px; }
.btn-cancel {
  padding: 10px 22px; border: 1.5px solid #e2e8f0; background: white;
  border-radius: 12px; color: #64748b; font-weight: 600; cursor: pointer; transition: 0.2s; font-size: 13px;
}
.btn-update {
  padding: 10px 26px; background: #1e3a8a; color: white; border: none;
  border-radius: 12px; font-weight: 600; cursor: pointer; transition: 0.2s; font-size: 13px;
}
.btn-update:hover { background: #1e40af; }
.btn-cancel:hover { background: #f8fafc; color: #1e293b; }
.btn-update:disabled, .btn-cancel:disabled { opacity: 0.6; cursor: not-allowed; }
</style>