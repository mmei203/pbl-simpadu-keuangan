class Tagihan {
  String idTagihan;
  String idKeuanganMhs;
  String noInvoice;
  String namaTagihan;
  int nomorCicilan;
  int totalCicilan;
  double nominalCicilan;
  double potongan;
  double totalTagihan;
  String tglJatuhTempo;
  String tglTagihan;
  String statusBayar;
  String tglTransaksi;

  Tagihan({
    required this.idTagihan,
    required this.idKeuanganMhs,
    required this.noInvoice,
    required this.namaTagihan,
    required this.nomorCicilan,
    required this.totalCicilan,
    required this.nominalCicilan,
    required this.potongan,
    required this.totalTagihan,
    required this.tglJatuhTempo,
    required this.tglTagihan,
    required this.statusBayar,
    required this.tglTransaksi,
  });

  factory Tagihan.fromJson(Map<String, dynamic> json) {
    return Tagihan(
      idTagihan: json['id_tagihan']?.toString() ?? '',
      idKeuanganMhs: json['id_keuangan_mhs']?.toString() ?? '',
      noInvoice: json['no_invoice']?.toString() ?? '',
      namaTagihan: json['nama_tagihan']?.toString() ?? '',
      nomorCicilan: int.tryParse(json['nomor_cicilan']?.toString() ?? '') ?? 0,
      totalCicilan: int.tryParse(json['total_cicilan']?.toString() ?? '') ?? 0,
      nominalCicilan:
          double.tryParse(json['nominal_cicilan']?.toString() ?? '') ?? 0.0,
      potongan: double.tryParse(json['potongan']?.toString() ?? '') ?? 0.0,
      totalTagihan:
          double.tryParse(json['total_tagihan']?.toString() ?? '') ?? 0.0,
      tglJatuhTempo: json['tgl_jatuh_tempo']?.toString() ?? '',
      tglTagihan: json['tgl_tagihan']?.toString() ?? '',
      statusBayar: json['status_bayar']?.toString() ?? '',
      tglTransaksi: json['tgl_transaksi']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_tagihan': idTagihan,
      'id_keuangan_mhs': idKeuanganMhs,
      'no_invoice': noInvoice,
      'nama_tagihan': namaTagihan,
      'nomor_cicilan': nomorCicilan,
      'total_cicilan': totalCicilan,
      'nominal_cicilan': nominalCicilan,
      'potongan': potongan,
      'total_tagihan': totalTagihan,
      'tgl_jatuh_tempo': tglJatuhTempo,
      'tgl_tagihan': tglTagihan,
      'status_bayar': statusBayar,
      'tgl_transaksi': tglTransaksi,
    };
  }
}
