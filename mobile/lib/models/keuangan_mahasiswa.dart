class KeuanganMahasiswa {
  String idKeuanganMhs;
  String idKategori;
  String idMahasiswa;
  String semester;
  String beasiswa;
  String statusAktif;

  KeuanganMahasiswa({
    required this.idKeuanganMhs,
    required this.idKategori,
    required this.idMahasiswa,
    required this.semester,
    required this.beasiswa,
    required this.statusAktif,
  });

  factory KeuanganMahasiswa.fromJson(Map<String, dynamic> json) {
    return KeuanganMahasiswa(
      idKeuanganMhs: json['id_keuangan_mhs']?.toString() ?? '',
      idKategori: json['id_kategori']?.toString() ?? '',
      idMahasiswa: json['id_mahasiswa']?.toString() ?? '',
      semester: json['semester']?.toString() ?? '',
      beasiswa: json['beasiswa']?.toString() ?? '',
      statusAktif: json['status_aktif']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_keuangan_mhs': idKeuanganMhs,
      'id_kategori': idKategori,
      'id_mahasiswa': idMahasiswa,
      'semester': semester,
      'beasiswa': beasiswa,
      'status_aktif': statusAktif,
    };
  }
}
