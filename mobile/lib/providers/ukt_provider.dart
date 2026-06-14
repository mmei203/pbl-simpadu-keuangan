import 'package:flutter/material.dart';
import 'package:mobile/models/mahasiswa.dart';
import 'package:mobile/services/ukt_service.dart';

class UktProvider with ChangeNotifier {
  final UktService _uktService = UktService();

  // State Loader & Error Message
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // State List Data Mahasiswa
  List<Mahasiswa> _listMahasiswa = [];
  List<Mahasiswa> get listMahasiswa => _listMahasiswa;

  /// Fungsi untuk mengambil seluruh data mahasiswa dari API keuangan
  Future<void> fetchAllMahasiswa() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _listMahasiswa = await _uktService.getMahasiswa();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fungsi untuk memperbarui golongan UKT mahasiswa ke server
  Future<bool> updateMahasiswaUkt(String id, String uktBaru) async {
    _isLoading = true;
    notifyListeners();

    // Memanggil service dengan parameter penyesuaian baru
    bool berhasil = await _uktService.updateMahasiswaUkt(
      idKeuanganMhs: id, 
      uktValueBaru: uktBaru,
    );

    if (berhasil) {
      await fetchAllMahasiswa(); // Refresh data otomatis setelah sukses
    } else {
      _errorMessage = "Gagal Memperbarui Data ke Server.";
    }

    _isLoading = false;
    notifyListeners();
    return berhasil;
  }
}