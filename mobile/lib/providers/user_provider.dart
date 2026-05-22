import 'package:flutter/material.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService userService = UserService();
  bool isLoading = false;
  UserResponse? _loggedInUser;
  UserResponse? get loggedInUser => _loggedInUser;
  List<UserResponse>? _data;
  List<UserResponse>? get data => _data;

  // get user name
  void setLoggedInUser(UserResponse user) {
    _loggedInUser = user;
    notifyListeners();
  }

  Future<void> getAllUser() async {
    isLoading = true;
    notifyListeners();

    try {
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      isLoading = false;
      notifyListeners();
    }
  }
}
