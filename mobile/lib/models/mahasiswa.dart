class Mahasiswa {
  final String id;
  final String nim;
  final String nama;
  final String prodi; // Atau prodi_id sesuai kebutuhan UI kamu
  final String ukt;

  Mahasiswa({
    required this.id,
    required this.nim,
    required this.nama,
    required this.prodi,
    required this.ukt,
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    return Mahasiswa(
      // 1. Ambil id_mahasiswa sebagai ID internal untuk keperluan update data
      id: json['id_mahasiswa'] ?? '',
      
      // 2. Ambil key 'nim' yang asli dari API untuk ditampilkan di kolom NIM
      nim: json['nim'] ?? '',
      
      // 3. FIX: Ubah dari json['nama'] menjadi json['nama_mahasiswa'] sesuai dokumentasi API
      nama: json['nama_mahasiswa'] ?? 'Tanpa Nama',
      
      // 4. Ambil data program studi (sesuaikan jika ada objek 'prodi' atau id biasa)
      prodi: json['prodi_id']?.toString() ?? json['kurikulum_kode'] ?? '-',
      
      // 5. Ambil id_keuangan_mhs atau kategori ukt yang dikirim backend keuangan
      ukt: json['id_keuangan_mhs'] ?? json['id_kategori'] ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_mahasiswa': id,
      'nim': nim,
      'nama_mahasiswa': nama,
      'id_keuangan_mhs': ukt,
    };
  }
}