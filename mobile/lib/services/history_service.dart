import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/models/history.dart';

class HistoryService {
  static const String _kKey = 'history_entries_v1';

  Future<List<HistoryPembayaran>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> arr = json.decode(raw);
      return arr.map((e) => HistoryPembayaran.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> add(HistoryPembayaran item) async {
    final list = await getAll();
    // insert newest first
    list.insert(0, item);
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_kKey, encoded);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }
}
