import 'dart:math';

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

int random = Random().nextInt(4);

// Dummy Data UKT
List<Mahasiswa> dummyUKT = List.generate(
  20,
  (index) => Mahasiswa(
    nim: "C030324122",
    nama: "Budi",
    jurusan: "Elektro",
    status: "UKT ${index % 3 + 1}",
  ),
);


// dummy data beasiswa
List<Mahasiswa> dummyBeasiswa = List.generate(
  10,
  (index) => Mahasiswa(
    nim: "C030324122",
    nama: "Mhs $index",
    jurusan: "Elektro",
    status: "KIP",
  ),
);


// dummy data status
List<Mahasiswa> dummyStatus = List.generate(
  20,
  (index) => Mahasiswa(
    nim: "C030324122",
    nama: "Mhs $index",
    jurusan: "Elektro",
    status: index % 2 == 0? 'Aktif' : 'Nonaktif',
  ),
);

// dummy data status pembayaran
List<Mahasiswa> dummyPembayaran = List.generate(
  20,
  (index) => Mahasiswa(
    nim: "C030324122",
    nama: "Mhs $index",
    jurusan: "Elektro",
    status: index % 3 == 0? 'Lunas' : 'Belum',
  ),
);

List<Mahasiswa> dummyCicilan = List.generate(
  20,
  (index) => Mahasiswa(
    nim: "C030324122",
    nama: "Mhs $index",
    jurusan: "Elektro",
    status: '$random',
  ),
);