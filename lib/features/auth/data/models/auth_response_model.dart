import 'token_model.dart';
import 'user_model.dart';

/// ================================================================
/// AUTH RESPONSE MODEL
///
/// Wraps the combined login / signup backend response.
/// ================================================================

class AuthResponseModel {
  final UserModel user;
  final TokenModel tokens;

  const AuthResponseModel({
    required this.user,
    required this.tokens,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      tokens: TokenModel.fromJson(json),
    );
  }
}
