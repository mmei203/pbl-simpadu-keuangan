class Mahasiswa {
  final String id;
  final String nim;
  final String nama;
  final String prodi;
  String ukt; // Tambahkan properti ini untuk menampung data dari API Keuangan

  Mahasiswa({
    required this.id,
    required this.nim,
    required this.nama,
    required this.prodi,
    this.ukt = '-', // Default strip jika data keuangan belum gabung
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    return Mahasiswa(
      id: json['id'] ?? '',
      nim: json['nim'] ?? '',
      nama: json['nama'] ?? '',
      prodi: json['prodi'] ?? '',
    );
  }
}