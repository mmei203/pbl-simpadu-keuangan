// file: mobile/services/pembayaran_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/models/tagihan.dart';

class PembayaranService {
  final String baseUrl = dotenv.env['URL_KEUANGAN'] ??
      "https://api-keuangan-4a.akufarish.my.id:8873/api";

  final String _urlMahasiswa = "https://api-mahasiswa-4a.akufarish.my.id:8874/api";

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

  String _konversiProdiIdKeNama(dynamic prodiId) {
    if (prodiId == null) return '-';
    
    String idStr = prodiId.toString().trim();
    
    switch (idStr) {
      case '12':
        return 'Teknik Informatika';
      case '11':
        return 'Sistem Informasi';
      case '13':
        return 'Manajemen Informatika';
      default:
        return 'Prodi ID: $idStr';
    }
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
          
          List<TagihanModel> temporaryList = [];

          final List<dynamic> semuaMahasiswa = await _fetchAllMahasiswa(headers);

          for (var item in data) {
            TagihanModel tagihan = TagihanModel.fromJson(item);

            final mhsObj = item['keuangan_mahasiswa'] ?? {};
            final String idMahasiswaTarget = mhsObj['ID_MAHASISWA']?.toString() ?? '';

            if (idMahasiswaTarget.isNotEmpty) {
              final detailMhs = semuaMahasiswa.firstWhere(
                (mhs) => mhs['id_mahasiswa']?.toString().trim() == idMahasiswaTarget.trim(),
                orElse: () => null,
              );
              
              if (detailMhs != null) {
                final String nimAsli = detailMhs['nim']?.toString() ?? '-';
                final String namaAsli = detailMhs['nama_mahasiswa']?.toString() ?? '-';
                
                final String prodiAsli = _konversiProdiIdKeNama(detailMhs['prodi_id']);

                tagihan = TagihanModel(
                  id: tagihan.id,
                  idKeuanganMhs: tagihan.idKeuanganMhs,
                  nim: nimAsli,
                  nama: namaAsli,
                  prodi: prodiAsli,
                  status: tagihan.status,
                  totalTagihan: tagihan.totalTagihan,
                  terbayar: tagihan.terbayar,
                  sisa: tagihan.sisa,
                  noInvoice: tagihan.noInvoice,
                  namaTagihan: tagihan.namaTagihan,
                  nomorCicilan: tagihan.nomorCicilan,
                  totalCicilan: tagihan.totalCicilan,
                  nominalCicilan: tagihan.nominalCicilan,
                  potongan: tagihan.potongan,
                  tglJatuhTempo: tagihan.tglJatuhTempo,
                  tglTagihan: tagihan.tglTagihan,
                  tglBayar: tagihan.tglBayar,
                );
              } else {
                tagihan = TagihanModel(
                  id: tagihan.id,
                  idKeuanganMhs: tagihan.idKeuanganMhs,
                  nim: tagihan.nim != '-' ? tagihan.nim : idMahasiswaTarget, 
                  nama: tagihan.nama != '-' && tagihan.nama.isNotEmpty ? tagihan.nama : 'Memuat...',
                  prodi: tagihan.prodi != '-' && tagihan.prodi.isNotEmpty ? tagihan.prodi : '-',
                  status: tagihan.status,
                  totalTagihan: tagihan.totalTagihan,
                  terbayar: tagihan.terbayar,
                  sisa: tagihan.sisa,
                  noInvoice: tagihan.noInvoice,
                  namaTagihan: tagihan.namaTagihan,
                  nomorCicilan: tagihan.nomorCicilan,
                  totalCicilan: tagihan.totalCicilan,
                  nominalCicilan: tagihan.nominalCicilan,
                  potongan: tagihan.potongan,
                  tglJatuhTempo: tagihan.tglJatuhTempo,
                  tglTagihan: tagihan.tglTagihan,
                  tglBayar: tagihan.tglBayar,
                );
              }
            }
            temporaryList.add(tagihan);
          }
          return temporaryList;
        }
      }
      return [];
    } catch (e) {
      print('Service Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> _fetchAllMahasiswa(Map<String, String> headers) async {
    final urlMhs = Uri.parse('$_urlMahasiswa/mahasiswa');
    try {
      final response = await http.get(urlMhs, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return body['data'] is List ? body['data'] : [];
        }
      }
    } catch (e) {
      print('⚠️ Gagal koneksi ke port :8874: $e');
    }
    return [];
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