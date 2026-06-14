import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/models/tagihan.dart';

class PembayaranService {
  final String baseUrl = dotenv.env['URL_KEUANGAN'] ??
      "https://api-keuangan-4a.akufarish.my.id:8873/api";

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ??
        prefs.getString('token') ??
        prefs.getString('TOKEN') ??
        prefs.getString('auth_token') ??
        '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<TagihanModel>> getTagihanData() async {
    final url = Uri.parse('$baseUrl/tagihan');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          return data.map((item) => TagihanModel.fromJson(item)).toList();
        }
      } else {
        print('Gagal mengambil data. Status API: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      print('Service Error: $e');
      return [];
    }
  }

  Future<bool> updatePembayaranData(
      String idTagihan, Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/tagihan/$idTagihan');
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(payload),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Service Update Error: $e');
      return false;
    }
  }
}