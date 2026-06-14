import 'package:flutter/material.dart';
import 'package:mobile/models/mahasiswa.dart';
import 'package:mobile/services/status_service.dart';

class StatusProvider with ChangeNotifier {
  final StatusService _statusService = StatusService();
  
  List<Mahasiswa> _allMahasiswa = [];
  bool _isLoading = false;
  String _selectedFilter = 'ALL'; 
  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;
  List<Mahasiswa> get listMahasiswa {
    if (_selectedFilter == 'ALL') {
      return _allMahasiswa;
    }
    return _allMahasiswa.where((mhs) => mhs.ukt.toUpperCase() == _selectedFilter).toList();
  }
  void setFilter(String filterValue) {
    _selectedFilter = filterValue;
    notifyListeners(); 
  }

  Future<void> fetchStatusMahasiswa() async {
    _isLoading = true;
    notifyListeners();

    try {
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