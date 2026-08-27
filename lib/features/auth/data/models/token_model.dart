/// ================================================================
/// TOKEN MODEL
/// ================================================================

class TokenModel {
  final String accessToken;
  final String refreshToken;
  final int? expiresIn; // seconds

  const TokenModel({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        if (expiresIn != null) 'expires_in': expiresIn,
      };
}
