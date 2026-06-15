import 'package:flutter/material.dart';
import 'package:mobile/models/tagihan.dart';
import 'package:mobile/services/pembayaran_service.dart';
import 'package:mobile/services/history_service.dart';
import 'package:mobile/models/history.dart';

class PembayaranProvider with ChangeNotifier {
  final PembayaranService _service = PembayaranService();
  List<TagihanModel> _tagihanList = [];
  bool _isLoading = false;

  List<TagihanModel> get listTagihan =>
      _tagihanList;
  bool get isLoading => _isLoading;

  int get totalMahasiswa => _tagihanList.length;
  int get jumlahSudahBayar => _tagihanList
      .where((t) => t.status.trim().toLowerCase() == 'lunas')
      .length;
  int get jumlahSedangCicil => _tagihanList
      .where((t) => t.status.trim().toLowerCase() == 'cicilan')
      .length;
  int get jumlahBelumBayar => _tagihanList
      .where(
        (t) =>
            t.status.trim().toLowerCase() == 'belum bayar' ||
            t.status.trim().toLowerCase() == 'belum',
      )
      .length;

  Future<void> fetchTagihan() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tagihanList = await _service.getTagihanData();
    } catch (e) {
      debugPrint("Error fetching: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> simpanPembayaran(
    String idTagihan,
    Map<String, dynamic> data,
  ) async {
    bool sukses = await _service.updatePembayaranData(idTagihan, data);
    if (sukses) {
      TagihanModel? target;
      try {
        target = _tagihanList.firstWhere((t) => t.id == idTagihan);
      } catch (e) {
        target = null;
      }

      String nama = target?.nama ?? '-';
      String nim = target?.nim ?? '-';

      String tipe = 'Perubahan Data';
      if (data.containsKey('STATUS_BAYAR') || data.containsKey('status')) {
        tipe =
            data['STATUS_BAYAR']?.toString() ??
            data['status']?.toString() ??
            tipe;
      } else if (target?.nomorCicilan != null) {
        tipe = 'Cicilan ke-${target!.nomorCicilan}';
      }

      String nominal = '-';
      if (data.containsKey('nominal')) {
        nominal = data['nominal'].toString();
      } else if (target?.nominalCicilan != null) {
        nominal = 'Rp. ${target!.nominalCicilan!.toStringAsFixed(0)}';
      }

      final now = DateTime.now();
      final tanggal =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

      try {
        final history = HistoryPembayaran(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nama: nama,
          nim: nim,
          tipe: tipe,
          nominal: nominal,
          tanggal: tanggal,
        );
        await HistoryService().add(history);
      } catch (e) {
        debugPrint('Gagal menyimpan history: $e');
      }

      await fetchTagihan();
      notifyListeners();
    }
  }
}
