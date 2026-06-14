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

 // ==========================================
  // [READ] - Mengambil Data dari Kategori UKT (GOLONGAN_UKT)
  // ==========================================
  Future<List<Mahasiswa>> getMahasiswa() async {
    try {
      final token = await _getValidToken();
      final urlKeuangan = dotenv.env['URL_KEUANGAN'];

      // 1. Endpoint kembali ke kategori-ukt
      final response = await http.get(
        Uri.parse('$urlKeuangan/kategori-ukt'), 
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("=== DEBUG GET KATEGORI UKT ===");
      print("Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseJson = json.decode(response.body);
        final List<dynamic> listKategori = responseJson['data'] ?? [];

        List<Mahasiswa> listHasilTabel = [];

        for (var kat in listKategori) {
          final String idKategori = kat['ID_KATEGORI']?.toString() ?? '-';
          
          // 2. Ambil murni dari field GOLONGAN_UKT (Misal isinya: "Golongan 1" atau "Golongan 5")
          final String golonganRaw = kat['GOLONGAN_UKT']?.toString() ?? '-';
          
          // 3. Persingkat teksnya secara dinamis menjadi "Gol 1", "Gol 2", dst.
          String golonganShort = golonganRaw;
          if (golonganRaw.toLowerCase().contains('golongan')) {
            // Mengambil angka saja yang ada di dalam teks GOLONGAN_UKT
            final RegExp regExp = RegExp(r'\d+');
            final match = regExp.firstMatch(golonganRaw);
            if (match != null) {
              golonganShort = "Gol ${match.group(0)}";
            }
          }

          // 4. Petakan langsung ke kolom tabel UI
          listHasilTabel.add(Mahasiswa(
            id: idKategori,      // ID Kategori disimpan untuk relasi/CRUD
            nim: idKategori,     // Menampilkan kode KAT001, KAT002 di kolom NIM sementara waktu
            nama: "-",           
            prodi: "-",          
            ukt: golonganShort,  // 🎯 Menampilkan "Gol 1" sampai "Gol 5" di kolom UKT murni dari GOLONGAN_UKT
          ));
        }

        return listHasilTabel;
      } else {
        throw 'Gagal memuat kategori UKT (Status: ${response.statusCode})';
      }
    } catch (e) {
      print("Error pada getMahasiswa: $e");
      throw 'Terjadi kesalahan koneksi: $e';
    }
  }

  Future<bool> updateUkt(Mahasiswa mahasiswa, String newIdKategori) async {
    try {
      final baseUrl = dotenv.env['URL_KEUANGAN'];
      final token = await _getValidToken();

      // Konversi teks "Gol 5" dari dropdown menjadi "Golongan 5" agar sesuai standar DB
      String golonganFull = newIdKategori;
      if (newIdKategori.toLowerCase().contains('gol')) {
        final RegExp regExp = RegExp(r'\d+');
        final match = regExp.firstMatch(newIdKategori);
        if (match != null) {
          golonganFull = "Golongan ${match.group(0)}";
        }
      }

      // Melakukan HTTP PUT menuju endpoint: /api/kategori-ukt/{ID_KATEGORI}
      final response = await http.put(
        Uri.parse('$baseUrl/kategori-ukt/${mahasiswa.id}'), 
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'ID_KATEGORI': mahasiswa.id,         // Contoh: "KAT005"
          'GOLONGAN_UKT': golonganFull,        // 🎯 Mengirimkan string "Golongan 5" hasil konversi
          'NOMINAL_UKT': '4900000.00',         // Nilai nominal default/sementara sesuai database
          'ID_PRODI': '1',                     // ID Prodi default sesuai database
        }),
      );

      print("=== DEBUG UPDATE PUT KATEGORI UKT ===");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body.toString()}");
      print("========================");

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return true; // Berhasil memperbarui data!
      } else {
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          if (errorData['errors'] != null) {
            return Future.error(errorData['errors'].toString());
          }
          return Future.error(errorData['message'] ?? 'Gagal memperbarui kategori UKT.');
        } catch (_) {
          return Future.error('Server menolak pembaruan (Status: ${response.statusCode})');
        }
      }
    } catch (e) {
      return Future.error('Terjadi kesalahan saat memperbarui: $e');
    }
  }
}
