class UserRequests {
  String email;
  String password;

  UserRequests({required this.email, required this.password});

  Map<dynamic, String> toJson() => {"email": email, "password": password};
}
