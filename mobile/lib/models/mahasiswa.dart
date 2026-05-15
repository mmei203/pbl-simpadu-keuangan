class Mahasiswa {
  final String nim;
  final String nama;
  final String jurusan;
  final String status; // Bisa diisi UKT, Status, atau Beasiswa tergantung kebutuhan

  Mahasiswa({
    required this.nim,
    required this.nama,
    required this.jurusan,
    required this.status,
  });
}

// Dummy Data
List<Mahasiswa> dummyMahasiswa = List.generate(
  20,
  (index) => Mahasiswa(
    nim: "C030324122",
    nama: "Budi",
    jurusan: "Elektro",
    status: "UKT ${index % 3 + 1}",
  ),
);