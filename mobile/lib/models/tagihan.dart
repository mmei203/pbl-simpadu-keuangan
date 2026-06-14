class TagihanModel {
  final String id;
  final String idKeuanganMhs;
  final String nim;
  final String nama;
  final String prodi;
  final String status;
  final double totalTagihan;
  final double terbayar;
  final double sisa;
  final String? noInvoice;
  final String? namaTagihan;
  final int? nomorCicilan;
  final int? totalCicilan;
  final double? nominalCicilan;
  final double? potongan;
  final String? tglJatuhTempo;
  final String? tglTagihan;
  final String? tglBayar;

  TagihanModel({
    required this.id,
    required this.idKeuanganMhs,
    required this.nim,
    required this.nama,
    required this.prodi,
    required this.status,
    required this.totalTagihan,
    required this.terbayar,
    required this.sisa,
    this.noInvoice,
    this.namaTagihan,
    this.nomorCicilan,
    this.totalCicilan,
    this.nominalCicilan,
    this.potongan,
    this.tglJatuhTempo,
    this.tglTagihan,
    this.tglBayar,
  });

  factory TagihanModel.fromJson(Map<String, dynamic> json) {
    final mhs = json['keuangan_mahasiswa'] ?? {};

    final double total =
        double.tryParse(json['TOTAL_TAGIHAN']?.toString() ?? '0') ?? 0.0;
    final double nominalCicilan =
        double.tryParse(json['NOMINAL_CICILAN']?.toString() ?? '0') ?? 0.0;
    final int nomorCicilan =
        int.tryParse(json['NOMOR_CICILAN']?.toString() ?? '0') ?? 0;

    // Terbayar = nominal cicilan × cicilan ke
    final double terbayar = nominalCicilan * nomorCicilan;
    // Sisa = total - terbayar
    final double sisa = total - terbayar;

    return TagihanModel(
      id: json['ID_TAGIHAN']?.toString() ?? '',
      idKeuanganMhs: json['ID_KEUANGAN_MHS']?.toString() ?? '',
      nim: mhs['NIM']?.toString() ?? '-',
      nama: mhs['NAMA']?.toString() ?? '-',
      prodi: mhs['PRODI']?.toString() ?? '-',
      status: json['STATUS_BAYAR']?.toString() ?? 'belum',
      totalTagihan: total,
      terbayar: terbayar,
      sisa: sisa,
      noInvoice: json['NO_INVOICE']?.toString(),
      namaTagihan: json['NAMA_TAGIHAN']?.toString(),
      nomorCicilan: nomorCicilan == 0 ? null : nomorCicilan,
      totalCicilan: json['TOTAL_CICILAN'] != null
          ? int.tryParse(json['TOTAL_CICILAN'].toString())
          : null,
      nominalCicilan: nominalCicilan == 0 ? null : nominalCicilan,
      potongan: json['POTONGAN'] != null
          ? double.tryParse(json['POTONGAN'].toString())
          : null,
      tglJatuhTempo: json['TGL_JATUH_TEMPO']?.toString(),
      tglTagihan: json['TGL_TAGIHAN']?.toString(),
      tglBayar: json['TGL_BAYAR']?.toString(),
    );
  }
}