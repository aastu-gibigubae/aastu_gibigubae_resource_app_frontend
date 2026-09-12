import 'token_model.dart';
import 'user_model.dart';

/// ================================================================
/// AUTH RESPONSE MODEL
///
/// Handles both flat and nested backend response shapes:
///
///   Flat (tokens at root level):
///   { "user": {...}, "access_token": "...", "refresh_token": "..." }
///
///   Nested (tokens inside a "tokens" key):
///   { "user": {...}, "tokens": { "access_token": "...", ... } }
///
///   Also handles "token" (singular) as an alias for "access_token".
/// ================================================================

class AuthResponseModel {
  final UserModel user;
  final TokenModel tokens;

  const AuthResponseModel({
    required this.user,
    required this.tokens,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // ── Parse user ─────────────────────────────────────────────────
    final userMap = json['user'] as Map<String, dynamic>? ??
        json['data'] as Map<String, dynamic>? ??
        json; // fallback: user fields at root

    // ── Parse tokens ───────────────────────────────────────────────
    Map<String, dynamic> tokenMap;

    if (json['tokens'] is Map<String, dynamic>) {
      // Nested: { "tokens": { "access_token": "...", ... } }
      tokenMap = json['tokens'] as Map<String, dynamic>;
    } else {
      // Flat: access_token / refresh_token / token at root level
      final accessToken = json['access_token'] as String? ??
          json['token'] as String? ??
          json['accessToken'] as String? ??
          '';
      final refreshToken = json['refresh_token'] as String? ??
          json['refreshToken'] as String? ??
          '';
      tokenMap = {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        if (json['expires_in'] != null) 'expires_in': json['expires_in'],
      };
    }

    return AuthResponseModel(
      user: UserModel.fromJson(userMap),
      tokens: TokenModel.fromJson(tokenMap),
    );
  }
}
