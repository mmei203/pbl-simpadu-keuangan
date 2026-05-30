import 'package:flutter/material.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService userService = UserService();
  bool isLoading = false;
  bool _isLoginLoading = false;
  bool get isLoginLoading => _isLoginLoading;
  UserResponse? _loggedInUser;
  UserResponse? get loggedInUser => _loggedInUser;
  List<UserResponse>? _data;
  List<UserResponse>? get data => _data;

  // get user name
  void setLoggedInUser(UserResponse user) {
    _loggedInUser = user;
    notifyListeners();
  }

  // Login function
  Future<UserResponse?> login(UserRequests request) async {
    _isLoginLoading = true;
    notifyListeners();

    try {
      UserResponse? user = await userService.login(request);
      _isLoginLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _isLoginLoading = false;
      notifyListeners();
      return null;
    }
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
