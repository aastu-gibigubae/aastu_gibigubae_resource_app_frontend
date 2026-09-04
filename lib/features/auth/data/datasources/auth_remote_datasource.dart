import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/auth_response_model.dart';
import '../models/token_model.dart';

/// ================================================================
/// AUTH REMOTE DATASOURCE
///
/// Makes HTTP calls to the backend auth endpoints.
/// Errors are handled upstream by ErrorInterceptor — no try/catch
/// needed here. DioExceptions bubble up as typed AppExceptions.
/// ================================================================

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    required String deviceFingerprint,
  });

  Future<AuthResponseModel> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String deviceFingerprint,
  });

  Future<void> logout();

  Future<TokenModel> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  const AuthRemoteDataSourceImpl(this._dio);

  // ── Login ──────────────────────────────────────────────────────

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    required String deviceFingerprint,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
        'device_fingerprint': deviceFingerprint,
      },
    );
    return AuthResponseModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  // ── Signup ─────────────────────────────────────────────────────

  @override
  Future<AuthResponseModel> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String deviceFingerprint,
  }) async {
    final response = await _dio.post(
      ApiConstants.signup,
      data: {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'device_fingerprint': deviceFingerprint,
      },
    );
    return AuthResponseModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  // ── Logout ─────────────────────────────────────────────────────

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      // Swallow server errors on logout — we still clear local state.
      // Only rethrow on genuine connection failure.
      if (e.type == DioExceptionType.connectionError) rethrow;
    }
  }

  // ── Refresh token ──────────────────────────────────────────────

  @override
  Future<TokenModel> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      ApiConstants.refreshToken,
      data: {'refresh_token': refreshToken},
    );
    return TokenModel.fromJson(response.data as Map<String, dynamic>);
  }
}
