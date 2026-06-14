import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/models/mahasiswa.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UktService {
  // ==========================================
  // [HELPER] - Mengambil Token Secara Aman (Multi-Key)
  // ==========================================
  Future<String> _getValidToken() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('access_token');
    if (token == null || token.isEmpty) {
      token = prefs.getString('token');
    }

    if (token == null || token.isEmpty) {
      throw 'Sesi tidak ditemukan. Silakan login kembali.';
    }

    try {
      bool isTokenExpired = JwtDecoder.isExpired(token);
      if (isTokenExpired) {
        throw 'Sesi login telah berakhir. Silakan login kembali.';
      }
    } catch (_) {}

    return token;
  }

  // ==========================================
  // [READ] - Ambil Data & Sinkronisasi Total (Menampilkan Golongan dari API Keuangan)
  // ==========================================
  Future<List<Mahasiswa>> getMahasiswa() async {
    try {
      final token = await _getValidToken();
      if (token == null || token.isEmpty) {
        throw 'Sesi tidak ditemukan. Silakan login kembali.';
      }

      final urlKeuangan = dotenv.env['URL_KEUANGAN'];
      final urlMahasiswa = dotenv.env['URL_MAHASISWA'];

      // 1. HIT API KATEGORI UKT - Untuk memetakan KATxxx menjadi Gol X
      List<dynamic> listKategoriRaw = [];
      try {
        final responseKategori = await http.get(
          Uri.parse('$urlKeuangan/kategori-ukt'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (responseKategori.statusCode == 200) {
          final Map<String, dynamic> decodedKat = json.decode(
            responseKategori.body,
          );
          listKategoriRaw = decodedKat['data'] ?? [];
        }
      } catch (e) {
        print("💡 Log Sistem: Gagal memuat Master Kategori UKT -> $e");
      }

      // 2. HIT API KEUANGAN MAHASISWA (Basis Urutan Tabel)
      final responseKeuangan = await http.get(
        Uri.parse('$urlKeuangan/keuangan-mahasiswa'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // 3. HIT API MAHASISWA
      dynamic responseMhs;
      try {
        responseMhs = await http
            .get(
              Uri.parse('$urlMahasiswa/mahasiswa'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
                'Connection': 'Keep-Alive',
              },
            )
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        print("💡 Log Sistem: Gagal terhubung ke API Mahasiswa -> $e");
      }

      print("=== DEBUG UKT PAGE (SINKRON GOLONGAN API) ===");
      print("Status Keuangan: ${responseKeuangan.statusCode}");

      List<Mahasiswa> listHasilTabel = [];

      if (responseKeuangan.statusCode == 200) {
        final Map<String, dynamic> decodedKeuangan = json.decode(
          responseKeuangan.body,
        );
        final List<dynamic> dataKeuanganRaw = decodedKeuangan['data'] ?? [];

        List<dynamic> listMahasiswaRaw = [];
        if (responseMhs != null && responseMhs.statusCode == 200) {
          final Map<String, dynamic> mhsJson = json.decode(responseMhs.body);
          listMahasiswaRaw = mhsJson['data'] ?? [];
        }

        // LOOPING UTAMA
        for (var jsonItem in dataKeuanganRaw) {
          final String idKeuangan =
              jsonItem['ID_KEUANGAN_MHS']?.toString() ?? '';
          String linkIdMhs =
              (jsonItem['id_mahasiswa'] ?? jsonItem['ID_MAHASISWA'] ?? '')
                  .toString()
                  .trim();
          String idKategoriRaw =
              (jsonItem['ID_KATEGORI'] ?? jsonItem['id_kategori'] ?? '-')
                  .toString()
                  .trim();

          // LOGIKA MENCARI TAMPILAN GOLONGAN (Berdasarkan Dokumen API kategori-ukt)
          String golonganDisplay =
              idKategoriRaw; // Fallback awal pakai KATxxx jika tidak ketemu

          final matchKategori = listKategoriRaw.firstWhere(
            (kat) =>
                (kat['ID_KATEGORI'] ?? kat['id_kategori'] ?? '')
                    .toString()
                    .trim() ==
                idKategoriRaw,
            orElse: () => null,
          );

          if (matchKategori != null) {
            // Ambil field GOLONGAN_UKT dari API (berisi "Gol 1", "Gol 2", dll.)
            golonganDisplay =
                (matchKategori['GOLONGAN_UKT'] ??
                        matchKategori['golongan_ukt'] ??
                        idKategoriRaw)
                    .toString();
          } else {
            // Kontingensi manual jika API Kategori bermasalah, ubah KAT056 -> Gol 1 secara dinamis jika formatnya berurutan
            if (idKategoriRaw.toUpperCase().contains('KAT')) {
              // Jika Anda ingin mengubah manual atau membersihkan teks di sini
              // Contoh fallback aman jika data murni string:
              golonganDisplay = idKategoriRaw.toUpperCase().replaceAll(
                'KAT',
                'Gol ',
              );
            }
          }

          String finalNim = '-';
          String finalNama = '-';
          String finalProdi = '-';

          // LOGIKA SINKRONISASI PENCARIAN PROFIL
          final detailMhs = listMahasiswaRaw.firstWhere((m) {
            final mIdMhs = (m['id_mahasiswa'] ?? m['ID_MAHASISWA'] ?? '')
                .toString()
                .trim();
            final mIdKeu = (m['id_keuangan_mhs'] ?? m['ID_KEUANGAN_MHS'] ?? '')
                .toString()
                .trim();

            return (mIdMhs == linkIdMhs && mIdMhs.isNotEmpty) ||
                (mIdKeu == linkIdMhs && mIdKeu.isNotEmpty) ||
                (mIdMhs == idKeuangan && idKeuangan.isNotEmpty);
          }, orElse: () => null);

          if (detailMhs != null) {
            finalNim = (detailMhs['nim'] ?? detailMhs['NIM'] ?? linkIdMhs)
                .toString();
            finalNama =
                (detailMhs['nama_mahasiswa'] ??
                        detailMhs['nama'] ??
                        'Tanpa Nama')
                    .toString();

            final String prodiId = (detailMhs['prodi_id'] ?? '').toString();
            if (prodiId == '2') {
              finalProdi = "S1 Sistem Informasi";
            } else {
              finalProdi = "D3 Teknik Informatika";
            }
          } else {
            // Fallback mengikuti tampilan Kelola Status saat API Mahasiswa down/timeout
            finalNim = linkIdMhs.isNotEmpty ? linkIdMhs : "-";
            finalNama = "Tanpa Nama...";
            finalProdi = "D3 Teknik Informatika";
          }

          listHasilTabel.add(
            Mahasiswa(
              id: idKeuangan,
              nim: finalNim,
              nama: finalNama,
              prodi: finalProdi,
              ukt:
                  golonganDisplay, // Sekarang menampilkan hasil mapping dari GOLONGAN_UKT ("Gol 1", "Gol 2")
            ),
          );
        }

        return listHasilTabel;
      } else {
        throw 'Gagal memuat data keuangan (Status: ${responseKeuangan.statusCode})';
      }
    } catch (e) {
      print("Error pada getMahasiswa: $e");
      throw 'Terjadi kesalahan koneksi: $e';
    }
  }

  // ==========================================
  // [UPDATE] - Perbarui Kategori UKT Mahasiswa (Aman & Auto Mapping)
  // ==========================================
  Future<bool> updateMahasiswaUkt({
    required String idKeuanganMhs, // ID utama row keuangan (UUID)
    required String uktValueBaru,  // Nilai dari UI (Bisa berupa "Gol 1" atau "KAT056")
  }) async {
    try {
      final token = await _getValidToken();
      if (token == null || token.isEmpty) {
        throw 'Sesi tidak ditemukan. Silakan login kembali.';
      }

      final urlKeuangan = dotenv.env['URL_KEUANGAN'];
      String finalIdKategori = uktValueBaru.trim();

      // JIKA YANG DIKIRIM UI ADALAH "Gol 1", KITA CARI ID_KATEGORI-NYA (KATxxx) KE API
      if (!uktValueBaru.toUpperCase().contains('KAT')) {
        try {
          final responseKategori = await http.get(
            Uri.parse('$urlKeuangan/kategori-ukt'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (responseKategori.statusCode == 200) {
            final Map<String, dynamic> decodedKat = json.decode(responseKategori.body);
            List<dynamic> listKategoriRaw = decodedKat['data'] ?? [];

            // Cari yang GOLONGAN_UKT-nya cocok (misal: "Gol 1" atau "Golongan 1")
            final match = listKategoriRaw.firstWhere(
              (kat) {
                final golUkt = (kat['GOLONGAN_UKT'] ?? kat['golongan_ukt'] ?? '').toString().toLowerCase().trim();
                return golUkt == uktValueBaru.toLowerCase().trim();
              },
              orElse: () => null,
            );

            if (match != null) {
              finalIdKategori = (match['ID_KATEGORI'] ?? match['id_kategori'] ?? uktValueBaru).toString();
            }
          }
        } catch (e) {
          print("💡 Log Sistem: Gagal mapping otomatis Kategori -> $e");
        }
      }

      print("=== DEBUG PROSES UPDATE UKT ===");
      print("Target ID Keuangan Mhs: $idKeuanganMhs");
      print("Payload ID_KATEGORI Dikirim: $finalIdKategori");

      // HIT API PUT KEUANGAN MAHASISWA
      final response = await http.put(
        Uri.parse('$urlKeuangan/keuangan-mahasiswa/$idKeuanganMhs'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'ID_KATEGORI': finalIdKategori, // Mengirim kode murni database (KATxxx)
        }),
      );

      print("Status Code Balasan Server: ${response.statusCode}");
      print("Response Body Balasan Server: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error pada fungsi updateMahasiswaUkt: $e");
      return false;
    }
  }
}
