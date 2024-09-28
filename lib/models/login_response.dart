class LoginResponse {
  final String token;

  LoginResponse({
    required this.token,
  });

  // Factory method to create a LoginResponse instance from JSON
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
    );
  }

  // Method to convert LoginResponse instance to JSON (if needed for serialization)
  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}
