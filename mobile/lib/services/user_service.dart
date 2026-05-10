import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/models/user.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String url = dotenv.get("BASE_URL");

  Future<bool> createUser(UserRequests request) async {
    try {
      final response = await http.post(
        Uri.parse("$url/api/auth/login"),
        body: jsonEncode(request.toJson()),
        headers: {"accept": "application/json"},
      );
      final jsonResponse = await jsonDecode(response.body);
      debugPrint("Hit API: $jsonResponse");

      if (response.statusCode != 200) {
        debugPrint("macam aneh jo");
        return false;
      }
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
