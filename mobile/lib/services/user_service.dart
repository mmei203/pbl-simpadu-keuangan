import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final String url = dotenv.get("BASE_URL");

  Future<UserResponse?> login(UserRequests request) async {
    try {
      final response = await http.post(
        Uri.parse("$url/api/auth/login"),
        body: jsonEncode(request.toJson()),
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
        },
      );
      
      final jsonResponse = jsonDecode(response.body);
      debugPrint("Hit API: $jsonResponse");

      if (response.statusCode != 200) return null;

      // 1. AMBIL ACCESS_TOKEN DARI DALAM OBJEK 'DATA' SECARA PASTI 🎯
      if (jsonResponse['data'] != null && jsonResponse['data']['access_token'] != null) {
        final String accessToken = jsonResponse['data']['access_token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', accessToken); // Tetap simpan dengan key 'token' agar ukt_service tidak perlu diubah
        
        debugPrint("✅ Token JWT Berhasil Disimpan dari access_token!");
      } else {
        debugPrint("⚠️ WARNING: access_token tidak ditemukan di dalam objek data.");
      }

      return UserResponse.fromJson(jsonResponse['data']);
    } catch (e) {
      debugPrint("Error di UserService: $e");
      return null;
    }
  }
}