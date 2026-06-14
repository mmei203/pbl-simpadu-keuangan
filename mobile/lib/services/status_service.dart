import 'package:mobile/models/mahasiswa.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StatusService {
  final String? baseUrl = dotenv.env['URL_KEUANGAN'];

  Future<String> _getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token') ?? prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw 'Sesi tidak ditemukan. Silakan login kembali.';
    }
    return token;
  }

  Future<List<Mahasiswa>> getStatusMahasiswa() async {
    final String? urlMahasiswaRaw = dotenv.env['URL_MAHASISWA'];
    if (baseUrl == null || urlMahasiswaRaw == null) {
      throw Exception(
        'Konfigurasi URL_KEUANGAN atau URL_MAHASISWA tidak ditemukan di file .env',
      );
    }

    String cleanUrlKeuangan = baseUrl!.trim().endsWith('/')
        ? baseUrl!.trim().substring(0, baseUrl!.trim().length - 1)
        : baseUrl!.trim();
    String cleanUrlMahasiswa = urlMahasiswaRaw.trim().endsWith('/')
        ? urlMahasiswaRaw.trim().substring(0, urlMahasiswaRaw.trim().length - 1)
        : urlMahasiswaRaw.trim();

    try {
      final token = await _getValidToken();

      // 1. Ambil Data Keuangan Mahasiswa (Status Aktif)
      final responseKeuangan = await http.get(
        Uri.parse('$cleanUrlKeuangan/keuangan-mahasiswa'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // 2. Ambil Data Profil Mahasiswa (Nama, NIM, Prodi)
      final responseMhs = await http.get(
        Uri.parse('$cleanUrlMahasiswa/mahasiswa'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      List<Mahasiswa> listHasilTabel = [];

      if (responseKeuangan.statusCode == 200) {
        final Map<String, dynamic> decodedKeuangan = json.decode(
          responseKeuangan.body,
        );
        final List<dynamic> dataKeuanganRaw = decodedKeuangan['data'] ?? [];

        List<dynamic> listMahasiswaRaw = [];
        if (responseMhs.statusCode == 200) {
          final Map<String, dynamic> mhsJson = json.decode(responseMhs.body);
          listMahasiswaRaw = mhsJson['data'] ?? [];
        }

        for (var jsonItem in dataKeuanganRaw) {
          final String idKeuangan =
              jsonItem['ID_KEUANGAN_MHS']?.toString() ?? '';
          String idMhsUkt =
              (jsonItem['ID_MAHASISWA'] ?? jsonItem['id_mahasiswa'] ?? '')
                  .toString()
                  .trim();

          final dbStatus =
              jsonItem['STATUS_AKTIF']?.toString().trim().toUpperCase() ?? '';
          final String statusFinal = (dbStatus == 'AKTIF')
              ? 'AKTIF'
              : 'NONAKTIF';

          String finalNim = '-';
          String finalNama = '-';
          String finalProdi = '-';

          // Pencarian ke objek listMahasiswaRaw
          final detailMhs = listMahasiswaRaw.firstWhere((m) {
            final mId = (m['id_mahasiswa'] ?? m['ID_MAHASISWA'] ?? '')
                .toString()
                .trim();
            return mId == idMhsUkt && mId.isNotEmpty;
          }, orElse: () => null);

          if (detailMhs != null) {
            // Sesuai Dokumentasi: Menggunakan field 'nim' dan 'nama_mahasiswa'
            finalNim = (detailMhs['nim'] ?? idMhsUkt).toString();
            finalNama = (detailMhs['nama_mahasiswa'] ?? 'Tanpa Nama')
                .toString();

            // Konversi prodi_id dari dokumentasi menjadi teks Prodi di UI
            final String prodiId = (detailMhs['prodi_id'] ?? '').toString();
            if (prodiId == '2' ||
                finalNim.contains('KAT05') ||
                finalNim.contains('KAT06')) {
              finalProdi = "S1 Sistem Informasi";
            } else {
              finalProdi = "D3 Teknik Informatika";
            }
          } else {
            // Logika Fallback jika data terputus / tidak sinkron
            finalNim = idMhsUkt.isNotEmpty ? idMhsUkt : "22010103001";

            // Generate nama dari potongan NIM
            String urutan = finalNim.length > 3
                ? finalNim.substring(finalNim.length - 3)
                : "001";
            finalNama = "Mahasiswa $urutan";

            final String idKategori = (jsonItem['ID_KATEGORI'] ?? '')
                .toString()
                .toUpperCase();
            if (idKategori.contains('KAT05') || idKategori.contains('KAT06')) {
              finalProdi = "S1 Sistem Informasi";
            } else {
              finalProdi = "D3 Teknik Informatika";
            }
          }

          listHasilTabel.add(
            Mahasiswa(
              id: idKeuangan,
              nim: finalNim,
              nama: finalNama,
              prodi: finalProdi,
              ukt: statusFinal,
            ),
          );
        }
      }

      return listHasilTabel;
    } catch (e) {
      print('Error pada StatusService: $e');
      throw Exception('Gagal memproses Sinkronisasi: $e');
    }
  }

  // Fungsi updateStatus tetap sama
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
      final token = await _getValidToken();
      final Map<String, dynamic> bodyRequest = {
        "ID_KATEGORI": idKategori.isEmpty ? "KAT001" : idKategori,
        "ID_MAHASISWA": idMahasiswa,
        "SEMESTER": semester.isEmpty ? "1" : semester,
        "BEASISWA": beasiswa.isEmpty ? "Tidak" : beasiswa,
        "STATUS_AKTIF": statusBaru.trim().toUpperCase(),
      };

      final response = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(bodyRequest),
      );

      return (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204);
    } catch (e) {
      print('Error di StatusService (update): $e');
      return false;
    }
  }
}
