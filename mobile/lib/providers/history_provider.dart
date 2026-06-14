import 'package:flutter/material.dart';
import 'package:mobile/models/history.dart';
import 'package:mobile/services/history_service.dart';

class HistoryProvider with ChangeNotifier {
  final HistoryService _service = HistoryService();
  List<HistoryPembayaran> _list = [];
  bool _isLoading = false;

  List<HistoryPembayaran> get list => _list;
  bool get isLoading => _isLoading;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    _list = await _service.getAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHistory(HistoryPembayaran item) async {
    await _service.add(item);
    await loadHistory();
  }

  Future<void> clear() async {
    await _service.clear();
    _list = [];
    notifyListeners();
  }
}
