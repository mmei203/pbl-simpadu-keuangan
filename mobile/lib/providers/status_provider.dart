import 'package:flutter/material.dart';
import 'package:mobile/models/mahasiswa.dart';
import 'package:mobile/services/status_service.dart';

class StatusProvider with ChangeNotifier {
  final StatusService _statusService = StatusService();
  
  List<Mahasiswa> _allMahasiswa = [];
  bool _isLoading = false;
  
  // 1. State untuk menyimpan pilihan filter aktif
  String _selectedFilter = 'ALL'; 

  // Getter data publik
  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;

  // =========================================================================
  // 2. GETTER DINAMIS (Kunci Utama Filter Berfungsi)
  // =========================================================================
  // UI Tabel nantinya wajib membaca 'listMahasiswa' ini yang otomatis tersaring
  List<Mahasiswa> get listMahasiswa {
    if (_selectedFilter == 'ALL') {
      return _allMahasiswa;
    }
    // Menyaring list berdasarkan kecocokan status ('AKTIF' / 'NONAKTIF')
    return _allMahasiswa.where((mhs) => mhs.ukt.toUpperCase() == _selectedFilter).toList();
  }

  // =========================================================================
  // 3. FUNGSI UNTUK MENGUBAH FILTER DARI DROPDOWN
  // =========================================================================
  void setFilter(String filterValue) {
    _selectedFilter = filterValue;
    // Beritahu Consumer di UI untuk menggambar ulang tabel secara instan
    notifyListeners(); 
  }

  // =========================================================================
  // 4. FETCH DATA DARI SERVER
  // =========================================================================
  Future<void> fetchStatusMahasiswa() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Mengambil data massal terbaru dari backend service
      _allMahasiswa = await _statusService.getStatusMahasiswa();
    } catch (e) {
      print('Error pada Provider Fetch: $e');
      _allMahasiswa = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}