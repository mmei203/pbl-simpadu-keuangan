import 'package:flutter/material.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService userService = UserService();
  bool isLoading = false;
  List<UserResponse>? _data;
  List<UserResponse>? get data => _data;

  Future<void> getAllUser() async {
    isLoading = true;
    notifyListeners();

    try {
      _data = await userService.getDataUser();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      isLoading = false;
      notifyListeners();
    }
  }
}
