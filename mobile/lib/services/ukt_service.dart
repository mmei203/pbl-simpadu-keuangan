import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/models/mahasiswa.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UktService {
  Future<String> _getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw 'Sesi tidak ditemukan. Silakan login kembali.';
    }

    bool isTokenExpired = JwtDecoder.isExpired(token);
    if (isTokenExpired) {
      throw 'Sesi login telah berakhir. Silakan login kembali.';
    }

    return token;
  }

  Future<List<Mahasiswa>> getMahasiswa() async {
    try {
      final baseUrl = dotenv.env['URL_KEUANGAN'];
      final token = await _getValidToken();

      final response = await http.get(
        Uri.parse('$baseUrl/keuangan-mahasiswa'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> listData = data['data'] ?? [];

        return listData.map((json) => Mahasiswa.fromJson(json)).toList();
      } else {
        throw 'Gagal memuat data (Status: ${response.statusCode})';
      }
    } catch (e) {
      throw 'Terjadi kesalahan koneksi: $e';
    }
  }

  Future<bool> updateUkt(Mahasiswa mahasiswa, String newIdKategori) async {
    try {
      final baseUrl = dotenv.env['URL_KEUANGAN'];
      final token = await _getValidToken();

      final int idKeuanganInteger =
          DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Konversi NIM mahasiswa ke Integer jika backend menggunakan data angka murni
      // Jika konversi gagal, dia akan tetap mengirimkan string nim aslinya
      final dynamic idMahasiswaFormatted =
          int.tryParse(mahasiswa.nim) ?? mahasiswa.nim;

      // Konversi ID Kategori ke Integer jikalau dropdown kamu mengirimkan string angka (misal "3")
      final dynamic idKategoriFormatted =
          int.tryParse(newIdKategori) ?? newIdKategori;

      final response = await http.post(
        Uri.parse('$baseUrl/keuangan-mahasiswa'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'ID_KEUANGAN_MHS': idKeuanganInteger,
          'ID_MAHASISWA':
              idMahasiswaFormatted, // 🎯 Menggunakan hasil konversi murni
          'ID_KATEGORI':
              idKategoriFormatted, // 🎯 Menggunakan hasil konversi murni
          'SEMESTER': '4',
          'STATUS_AKTIF': 'Aktif',
        }),
      );

      print("=== DEBUG UPDATE UKT RESUBMIT III ===");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body.toString()}");
      print("========================");

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return true;
      } else {
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          if (errorData['errors'] != null) {
            return Future.error(errorData['errors'].toString());
          }
          return Future.error(
            errorData['message'] ?? 'Gagal memperbarui data.',
          );
        } catch (_) {
          return Future.error(
            'Server menolak data dengan pesan: ${response.body}',
          );
        }
      }
    } catch (e) {
      return Future.error('Terjadi kesalahan saat menyimpan: $e');
    }
  }
}
