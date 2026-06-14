class HistoryPembayaran {
  final String id;
  final String nama;
  final String nim;
  final String tipe; // contoh: 'Cicilan ke-1', 'Pembayaran Lunas'
  final String nominal; // sudah diformat seperti 'Rp. 1.000.000,00'
  final String tanggal; // format 'dd/MM/yyyy'

  HistoryPembayaran({
    required this.id,
    required this.nama,
    required this.nim,
    required this.tipe,
    required this.nominal,
    required this.tanggal,
  });

  factory HistoryPembayaran.fromJson(Map<String, dynamic> json) {
    return HistoryPembayaran(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '-',
      nim: json['nim']?.toString() ?? '-',
      tipe: json['tipe']?.toString() ?? '-',
      nominal: json['nominal']?.toString() ?? '-',
      tanggal: json['tanggal']?.toString() ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nim': nim,
      'tipe': tipe,
      'nominal': nominal,
      'tanggal': tanggal,
    };
  }
}
