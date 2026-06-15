import axios from "axios";

// Buat instance khusus untuk API Keuangan (Port 8873)
const apiKeuangan = axios.create({
  baseURL: "https://api-keuangan-4a.akufarish.my.id:8873/api",
  headers: {
    "Accept": "application/json",
  }
});

// Buat instance khusus untuk API Mahasiswa (Port 8874)
const apiMahasiswa = axios.create({
  baseURL: "https://api-mahasiswa-4a.akufarish.my.id:8874/api",
  headers: {
    "Accept": "application/json",
  }
});

const apiAktif = axios.create({
  baseURL: "https://api-keuangan-4a.akufarish.my.id:8873/api/status-aktif/{id_mahasiswa}",
  headers: {
    "Accept": "application/json",
  }
});


// Gunakan interceptor agar token hanya disuntikkan ke instance keuangan saja
apiKeuangan.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("token");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

export { apiKeuangan, apiMahasiswa };
export default apiKeuangan;