import 'dart:convert';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// ================================================================
/// AUTH REPOSITORY IMPL
///
/// Coordinates the remote datasource and secure storage.
/// Tokens are persisted after every successful auth call.
/// ================================================================

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;

  const AuthRepositoryImpl({
    required this._remoteDataSource,
    required this._secureStorage,
  });

  // ── Login ──────────────────────────────────────────────────────

  @override
  Future<({User user, String accessToken, String refreshToken})> login({
    required String email,
    required String password,
    required String deviceFingerprint,
  }) async {
    final response = await _remoteDataSource.login(
      email: email,
      password: password,
      deviceFingerprint: deviceFingerprint,
    );

    // Persist tokens + cached user so the session survives app restarts.
    await _persistSession(
      response.user,
      response.tokens.accessToken,
      response.tokens.refreshToken,
    );

    return (
      user: response.user.toEntity(),
      accessToken: response.tokens.accessToken,
      refreshToken: response.tokens.refreshToken,
    );
  }

  // ── Signup ─────────────────────────────────────────────────────

  @override
  Future<({User user, String accessToken, String refreshToken})> signup({
    required String name,
    required String email,
    required String password,
    required String? phone,
    required String deviceFingerprint,
  }) async {
    final response = await _remoteDataSource.signup(
      name: name,
      email: email,
      password: password,
      phone: phone,
      deviceFingerprint: deviceFingerprint,
    );

    await _persistSession(response.user, response.tokens.accessToken,
        response.tokens.refreshToken);

    return (
      user: response.user.toEntity(),
      accessToken: response.tokens.accessToken,
      refreshToken: response.tokens.refreshToken,
    );
  }

  // ── Logout ─────────────────────────────────────────────────────

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
    await _secureStorage.deleteAll();
  }

  // ── Refresh session ────────────────────────────────────────────

  @override
  Future<String> refreshSession() async {
    final storedRefresh =
        await _secureStorage.read(StorageKeys.refreshToken);
    if (storedRefresh == null) {
      throw Exception('No refresh token stored.');
    }

    final tokens = await _remoteDataSource.refreshToken(storedRefresh);
    await _secureStorage.write(StorageKeys.accessToken, tokens.accessToken);
    await _secureStorage.write(StorageKeys.refreshToken, tokens.refreshToken);

    return tokens.accessToken;
  }

  // ── Get current user ───────────────────────────────────────────

  @override
  Future<User?> getCurrentUser() async {
    final userJson = await _secureStorage.read('cached_user');
    if (userJson == null) return null;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(map).toEntity();
    } catch (_) {
      return null;
    }
  }

  // ── Private helpers ────────────────────────────────────────────

  Future<void> _persistSession(
    UserModel user,
    String accessToken,
    String refreshToken,
  ) async {
    await Future.wait([
      _secureStorage.write(StorageKeys.accessToken, accessToken),
      _secureStorage.write(StorageKeys.refreshToken, refreshToken),
      _secureStorage.write(StorageKeys.userId, user.id),
      _secureStorage.write(StorageKeys.subscriptionStatus,
          user.subscriptionStatus),
      _secureStorage.write('cached_user', jsonEncode(user.toJson())),
    ]);
  }
}
