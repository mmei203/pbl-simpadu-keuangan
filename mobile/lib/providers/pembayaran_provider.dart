import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile/models/tagihan.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PembayaranProvider with ChangeNotifier {
  List<TagihanModel> _listTagihan = [];
  bool _isLoading = false;

  List<TagihanModel> get listTagihan => _listTagihan;
  bool get isLoading => _isLoading;

  final String baseUrl = dotenv.env['URL_KEUANGAN'] ??
      "https://api-keuangan-4a.akufarish.my.id:8873/api";

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ??
        prefs.getString('token') ??
        prefs.getString('TOKEN') ??
        prefs.getString('auth_token') ??
        '';
    print('=== TOKEN: $token ===');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> fetchTagihan() async {
    _isLoading = true;
    notifyListeners();

    try {
      final headers = await _getHeaders();
      List<TagihanModel> semuaData = [];

      // Coba fetch dengan pagination
      int currentPage = 1;
      bool hasMore = true;

      while (hasMore) {
        final url =
            Uri.parse('$baseUrl/tagihan?page=$currentPage&per_page=100');
        final response = await http.get(url, headers: headers);

        print('=== FETCH PAGE $currentPage ===');
        print('Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData =
              json.decode(response.body);

          print('Keys: ${responseData.keys.toList()}');

          if (responseData['success'] == true &&
              responseData['data'] != null) {
            final List<dynamic> dataTagihan = responseData['data'];
            print('Data di page $currentPage: ${dataTagihan.length}');

            semuaData.addAll(
                dataTagihan.map((item) => TagihanModel.fromJson(item)));

            // Cek apakah masih ada halaman berikutnya
            // Sesuaikan key pagination dengan response API kamu
            final pagination = responseData['pagination'] ??
                responseData['meta'] ??
                responseData;

            final lastPage = pagination['last_page'] ??
                pagination['total_pages'] ??
                pagination['totalPages'] ??
                1;

            final int last = int.tryParse(lastPage.toString()) ?? 1;

            if (currentPage >= last || dataTagihan.isEmpty) {
              hasMore = false;
            } else {
              currentPage++;
            }
          } else {
            hasMore = false;
          }
        } else {
          print('Error status: ${response.statusCode}');
          print('Body: ${response.body}');
          hasMore = false;
        }
      }

      print('=== TOTAL DATA: ${semuaData.length} ===');
      _listTagihan = semuaData;
    } catch (error) {
      print('Eror saat fetch data: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> simpanPembayaran(
      String idTagihan, Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/tagihan/$idTagihan');
    try {
      final headers = await _getHeaders();

      print('=== SIMPAN PAYLOAD ===');
      print('URL: $url');
      print('Payload: ${json.encode(payload)}');

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      return response.statusCode == 200;
    } catch (error) {
      print('Eror saat menyimpan data: $error');
      return false;
    }
  }
}