import 'package:flutter/material.dart';
import 'package:mobile/models/mahasiswa.dart';
import 'package:mobile/services/ukt_service.dart';

class UktProvider with ChangeNotifier {
  final UktService _uktService = UktService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<Mahasiswa> _listMahasiswa = [];
  List<Mahasiswa> get listMahasiswa => _listMahasiswa;

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

  Future<bool> updateMahasiswaUkt(String id, String uktBaru) async {
    _isLoading = true;
    notifyListeners();

    bool berhasil = await _uktService.updateMahasiswaUkt(
      idKeuanganMhs: id, 
      uktValueBaru: uktBaru,
    );

    if (berhasil) {
      await fetchAllMahasiswa();
    } else {
      _errorMessage = "Gagal Memperbarui Data ke Server.";
    }

    _isLoading = false;
    notifyListeners();
    return berhasil;
  }
}