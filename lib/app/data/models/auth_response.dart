class AuthResponse {
  final String token;
  final String? refreshToken;
  final int? expiresIn;

  AuthResponse({required this.token, this.refreshToken, this.expiresIn});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresIn: json['expires_in'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
    };
  }
}
