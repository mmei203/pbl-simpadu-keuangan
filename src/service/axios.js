import axios from "axios";

// Buat instance khusus untuk API Keuangan (Port 8873)
const apiKeuangan = axios.create({
  baseURL: "https://api-keuangan-4a.akufarish.my.id:8873/api",
  headers: {
    "Accept": "application/json",
  }
});

// Gunakan interceptor agar token hanya disuntikkan ke instance ini saja
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

export default apiKeuangan;