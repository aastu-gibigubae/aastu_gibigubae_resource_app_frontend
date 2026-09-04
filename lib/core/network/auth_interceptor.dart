import 'package:dio/dio.dart';

import '../constants/storage_keys.dart';
import '../storage/secure_storage.dart';

/// ================================================================
/// AUTH INTERCEPTOR
///
/// Attaches the Bearer token to every outgoing request.
/// On 401 responses it attempts a silent token refresh once,
/// then re-plays the original request.
/// If refresh fails the user is considered logged out.
/// ================================================================

class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;

  /// A separate Dio instance used only for token refresh to avoid
  /// triggering this interceptor recursively.
  final Dio _refreshDio;

  /// Called when the refresh attempt itself fails (e.g. session fully
  /// expired). The app shell listens to this to redirect to login.
  final void Function()? onSessionExpired;

  AuthInterceptor({
    required SecureStorage secureStorage,
    required Dio refreshDio,
    this.onSessionExpired,
  })  : _secureStorage = secureStorage,
        _refreshDio = refreshDio;

  // ── Request ────────────────────────────────────────────────────

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(StorageKeys.accessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // ── Response ───────────────────────────────────────────────────

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  // ── Error ──────────────────────────────────────────────────────

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isAuthRequest = err.requestOptions.path.startsWith('/auth/');
    if (err.response?.statusCode == 401 && !isAuthRequest) {
      try {
        final newToken = await _refreshAccessToken();
        if (newToken != null) {
          // Re-play the failed request with the new token.
          final opts = err.requestOptions
            ..headers['Authorization'] = 'Bearer $newToken';
          final cloned = await _refreshDio.fetch(opts);
          return handler.resolve(cloned);
        }
      } catch (_) {
        // Refresh failed — session is fully expired.
      }
      onSessionExpired?.call();
    }
    handler.next(err);
  }

  // ── Private ────────────────────────────────────────────────────

  Future<String?> _refreshAccessToken() async {
    final refreshToken = await _secureStorage.read(StorageKeys.refreshToken);
    if (refreshToken == null) return null;

    final response = await _refreshDio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );

    final accessToken = response.data['access_token'] as String?;
    final newRefresh = response.data['refresh_token'] as String?;

    if (accessToken != null) {
      await _secureStorage.write(StorageKeys.accessToken, accessToken);
    }
    if (newRefresh != null) {
      await _secureStorage.write(StorageKeys.refreshToken, newRefresh);
    }

    return accessToken;
  }
}
