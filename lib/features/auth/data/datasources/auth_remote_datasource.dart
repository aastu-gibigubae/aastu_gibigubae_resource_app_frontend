import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../models/auth_response_model.dart';
import '../models/token_model.dart';

/// ================================================================
/// AUTH REMOTE DATASOURCE
///
/// Makes HTTP calls to the backend auth endpoints.
/// Throws [AppException] subclasses on error.
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
    try {
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
    } on DioException catch (e) {
      throw ErrorMapper.fromDioException(e);
    }
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
    try {
      final response = await _dio.post(
        ApiConstants.signup,
        data: {
          'name': name,
          'email': email,
          'password': password,
          if (phone != null) 'phone': phone,
          'device_fingerprint': deviceFingerprint,
        },
      );
      return AuthResponseModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioException(e);
    }
  }

  // ── Logout ─────────────────────────────────────────────────────

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      // If the server returns an error on logout we still clear local state,
      // so only rethrow on network errors.
      if (e.type == DioExceptionType.connectionError) {
        throw ErrorMapper.fromDioException(e);
      }
    }
  }

  // ── Refresh token ──────────────────────────────────────────────

  @override
  Future<TokenModel> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );
      return TokenModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioException(e);
    }
  }
}
