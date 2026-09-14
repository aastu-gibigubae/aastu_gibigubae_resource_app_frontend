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
  final SecureStorage secureStorage;

  /// A separate Dio instance used only for token refresh to avoid
  /// triggering this interceptor recursively.
  final Dio refreshDio;

  /// Called when the refresh attempt itself fails (e.g. session fully
  /// expired). The app shell listens to this to redirect to login.
  final void Function()? onSessionExpired;

  /// In-flight token refresh future to prevent concurrent 401s from
  /// sending duplicate refresh requests.
  Future<String?>? _refreshFuture;

  AuthInterceptor({
    required this.secureStorage,
    required this.refreshDio,
    this.onSessionExpired,
  });

  // ── Request ────────────────────────────────────────────────────

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.read(StorageKeys.accessToken);
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
        final newToken = await _synchronizedRefresh();
        if (newToken != null && newToken.isNotEmpty) {
          // Re-play the failed request with the new token.
          final opts = err.requestOptions
            ..headers['Authorization'] = 'Bearer $newToken';
          final cloned = await refreshDio.fetch(opts);
          return handler.resolve(cloned);
        } else {
          onSessionExpired?.call();
        }
      } catch (refreshErr) {
        if (refreshErr is DioException &&
            refreshErr.response?.statusCode == 401) {
          onSessionExpired?.call();
        }
      }
    }
    handler.next(err);
  }

  // ── Private ────────────────────────────────────────────────────

  Future<String?> _synchronizedRefresh() {
    if (_refreshFuture != null) {
      return _refreshFuture!;
    }
    _refreshFuture = _refreshAccessToken().whenComplete(() {
      _refreshFuture = null;
    });
    return _refreshFuture!;
  }

  Future<String?> _refreshAccessToken() async {
    final refreshToken = await secureStorage.read(StorageKeys.refreshToken);
    if (refreshToken == null || refreshToken.trim().isEmpty) return null;

    final response = await refreshDio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );

    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final tokens = data['tokens'] is Map<String, dynamic>
          ? data['tokens'] as Map<String, dynamic>
          : data;
      final accessToken =
          tokens['access_token'] as String? ?? tokens['token'] as String?;
      final newRefresh = tokens['refresh_token'] as String?;

      if (accessToken != null && accessToken.isNotEmpty) {
        await secureStorage.write(StorageKeys.accessToken, accessToken);
      }
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await secureStorage.write(StorageKeys.refreshToken, newRefresh);
      }

      return accessToken;
    }

    return null;
  }
}
