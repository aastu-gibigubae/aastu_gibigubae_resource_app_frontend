import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/error_mapper.dart';
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

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String? token,
    required String newPassword,
    required String confirmPassword,
  });
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

  // ── Forgot password ────────────────────────────────────────────

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDioException(e);
    }
  }

  // ── Reset password ─────────────────────────────────────────────

  @override
  Future<void> resetPassword({
    required String? token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final data = <String, dynamic>{
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };
      if (token != null && token.isNotEmpty) {
        data['token'] = token;
      }
      await _dio.post(
        ApiConstants.resetPassword,
        data: data,
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDioException(e);
    }
  }
}
