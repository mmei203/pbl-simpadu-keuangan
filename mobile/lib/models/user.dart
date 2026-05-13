class UserRequests {
  String email;
  String password;

  UserRequests({required this.email, required this.password});

  Map<dynamic, String> toJson() => {"email": email, "password": password};
}

class UserResponse {
  String email;
  String name;
  String role_name;

  UserResponse({
    required this.email,
    required this.name,
    required this.role_name,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      email: json['email'],
      name: json['name'],
      role_name: json['role_name'],
    );
  }
}
