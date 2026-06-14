import 'package:mobile/models/mahasiswa.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StatusService {
  // Mengambil Base URL dari env
  final String? baseUrl = dotenv.env['URL_KEUANGAN'];

  // =========================================================================
  // 1. GET DATA MASAL (UNTUK TABEL UTAMA)
  // =========================================================================
  Future<List<Mahasiswa>> getStatusMahasiswa() async {
    if (baseUrl == null) {
      throw Exception('Konfigurasi URL_KEUANGAN tidak ditemukan di file .env');
    }

    // Membersihkan whitespace dan memastikan susunan slash URL rapi tanpa double slash
    String cleanUrl = baseUrl!.trim();
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }

    // Target endpoint sesuai dokumentasi API index massal
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

        // Sesuaikan jika data bersarang di dalam key 'data', atau langsung list massal
        final List<dynamic> dataMahasiswa = decodedData['data'] ?? [];

        return dataMahasiswa.map((jsonItem) {
          // Memetakan field response backend ke objek Mahasiswa dengan presisi
          return Mahasiswa(
            id: jsonItem['ID_KEUANGAN_MHS']?.toString() ?? '',
            nim: jsonItem['ID_MAHASISWA']?.toString() ?? '',
            nama:
                jsonItem['nama']?.toString() ??
                jsonItem['NAMA']?.toString() ??
                'Tanpa Nama',
            prodi: jsonItem['ID_KATEGORI']?.toString() ?? '',

            // 🎯 NORMALISASI STATUS:
            ukt: () {
              // Ambil nilai dari backend, ubah ke String, hapus spasi, dan jadikan huruf kapital
              final dbStatus =
                  jsonItem['STATUS_AKTIF']?.toString().trim().toUpperCase() ??
                  '';

              // Jika nilainya murni 'AKTIF', kembalikan 'AKTIF'
              if (dbStatus == 'AKTIF') {
                return 'AKTIF';
              }

              // Jika nilainya selain 'AKTIF' (bisa 'NONAKTIF', 'nonaktif', null, atau kosong),
              // paksa standarisasi menjadi 'NONAKTIF' agar lolos filter Provider
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

  // =========================================================================
  // 2. PUT UPDATE STATUS (UNTUK FORM EDIT)
  // =========================================================================
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

      // 🎯 PASTIKAN STATUS_AKTIF MENERIMA STRING UTUP (AKTIF / NONAKTIF)
      final Map<String, dynamic> bodyRequest = {
        "ID_KATEGORI": idKategori,
        "ID_MAHASISWA": idMahasiswa,
        "SEMESTER": semester,
        "BEASISWA": beasiswa,
        "STATUS_AKTIF": statusBaru
            .trim()
            .toUpperCase(), // 🔥 Memaksa jadi KAPITAL murni
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
