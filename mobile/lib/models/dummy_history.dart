class HistoryPembayaran {
  final String nama;
  final String nim;
  final String tipe; // 'Cicilan ke-1', 'Pembayaran Lunas', dll
  final String nominal;
  final String tanggal;

  HistoryPembayaran({
    required this.nama,
    required this.nim,
    required this.tipe,
    required this.nominal,
    required this.tanggal,
  });
}

List<HistoryPembayaran> dummyHistory = [
  HistoryPembayaran(
    nama: 'Udin',
    nim: 'C030324122',
    tipe: 'Cicilan ke-1',
    nominal: 'Rp. 1.500.000,00',
    tanggal: '23/01/2026',
  ),
  HistoryPembayaran(
    nama: 'Udin',
    nim: 'C030324122',
    tipe: 'Cicilan ke-2',
    nominal: 'Rp. 3.000.000,00',
    tanggal: '30/01/2026',
  ),
  HistoryPembayaran(
    nama: 'Udin',
    nim: 'C030324122',
    tipe: 'Pembayaran Lunas',
    nominal: 'Rp. 3.600.000,00',
    tanggal: '10/02/2026',
  ),
  HistoryPembayaran(
    nama: 'Budi',
    nim: 'C030324122',
    tipe: 'Pembayaran Lunas',
    nominal: 'Rp. 3.000.000,00',
    tanggal: '10/02/2026',
  ),
  HistoryPembayaran(
    nama: 'Jubaidah',
    nim: 'C030324122',
    tipe: 'Cicilan ke-1',
    nominal: 'Rp. 1.000.000,00',
    tanggal: '10/02/2026',
  ),
];