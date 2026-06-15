class Mahasiswa {
  final String id;
  final String nim;
  final String nama;
  final String prodi;
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
      id: json['id_mahasiswa'] ?? '',
      nim: json['nim'] ?? '',
      nama: json['nama_mahasiswa'] ?? 'Tanpa Nama',
      prodi: json['prodi_id']?.toString() ?? json['kurikulum_kode'] ?? '-',
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
