import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

/// ================================================================
/// DIO CLIENT
///
/// Singleton factory that returns a configured [Dio] instance.
/// All feature datasources use this instead of creating their own.
/// ================================================================

class DioClient {
  DioClient._();

  /// Creates and configures the main Dio instance.
  ///
  /// [secureStorage] is needed by [AuthInterceptor] to read / write
  /// tokens.  [onSessionExpired] is called when refresh fails so the
  /// app shell can navigate to the login screen.
  static Dio create({
    required SecureStorage secureStorage,
    void Function()? onSessionExpired,
  }) {
    // ── Base options ───────────────────────────────────────────────
    final options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    final dio = Dio(options);

    // ── A lightweight Dio used only for token refresh ──────────────
    // It does NOT have the AuthInterceptor to avoid infinite loops.
    final refreshDio = Dio(options);

    // ── Add interceptors (order matters) ──────────────────────────
    dio.interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        error: true,
        logPrint: (obj) => debugPrint('[DIO] $obj'),
      ),
      ErrorInterceptor(),
      AuthInterceptor(
        secureStorage: secureStorage,
        refreshDio: refreshDio,
        onSessionExpired: onSessionExpired,
      ),
    ]);

    return dio;
  }
}
