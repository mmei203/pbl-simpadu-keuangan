import 'package:mobile/models/mahasiswa.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StatusService {
  final String? baseUrl = dotenv.env['URL_KEUANGAN'];

  Future<List<Mahasiswa>> getStatusMahasiswa() async {
    if (baseUrl == null) {
      throw Exception('Konfigurasi URL_KEUANGAN tidak ditemukan di file .env');
    }

    String cleanUrl = baseUrl!.trim();
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }
    final url = Uri.parse('$cleanUrl/keuangan-mahasiswa');

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      print('Mencoba GET ke URL: $url');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Hasil GET Status Code: ${response.statusCode}');
      print('Hasil GET Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);

        final List<dynamic> dataMahasiswa = decodedData['data'] ?? [];

        return dataMahasiswa.map((jsonItem) {
          return Mahasiswa(
            id: jsonItem['ID_KEUANGAN_MHS']?.toString() ?? '',
            nim: jsonItem['ID_MAHASISWA']?.toString() ?? '',
            nama:
                jsonItem['nama']?.toString() ??
                jsonItem['NAMA']?.toString() ??
                'Tanpa Nama',
            prodi: jsonItem['ID_KATEGORI']?.toString() ?? '',

            ukt: () {
              final dbStatus =
                  jsonItem['STATUS_AKTIF']?.toString().trim().toUpperCase() ??
                  '';

              if (dbStatus == 'AKTIF') {
                return 'AKTIF';
              }
              return 'NONAKTIF';
            }(),
          );
        }).toList();
      } else {
        throw Exception(
          'Gagal memuat data status: Kode ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error di StatusService (fetch): $e');
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }

  Future<bool> updateStatus(
    String idKeuangan,
    String idMahasiswa,
    String statusBaru, {
    required String idKategori,
    required String semester,
    required String beasiswa,
  }) async {
    if (baseUrl == null) return false;

    String cleanUrl = baseUrl!.trim();
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }

    final url = Uri.parse('$cleanUrl/keuangan-mahasiswa/$idKeuangan');

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final Map<String, dynamic> bodyRequest = {
        "ID_KATEGORI": idKategori,
        "ID_MAHASISWA": idMahasiswa,
        "SEMESTER": semester,
        "BEASISWA": beasiswa,
        "STATUS_AKTIF": statusBaru
            .trim()
            .toUpperCase(),
      };

      print('Mencoba PUT ke URL: $url');
      print('Body Request Sesuai Dokumentasi: ${json.encode(bodyRequest)}');

      final response = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(bodyRequest),
      );

      print('Hasil Akhir PUT Status Code: ${response.statusCode}');
      print('Hasil Akhir PUT Response Body: ${response.body}');

      return (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204);
    } catch (e) {
      print('Error di StatusService (update): $e');
      return false;
    }
  }
}
