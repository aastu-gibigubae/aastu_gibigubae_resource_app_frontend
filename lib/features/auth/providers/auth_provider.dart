import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/constants/mock_config.dart';
import '../../../core/constants/storage_keys.dart';
import '../domain/entities/user.dart';

/// ================================================================
/// AUTH PROVIDER
///
/// Holds the currently authenticated user.
/// AsyncValue[User?] — null means logged out.
///
/// When [kMockAuth] is true all backend calls are skipped and a
/// fake user is returned immediately so screens can be developed
/// without a running backend.
/// ================================================================

// ── Mock user ─────────────────────────────────────────────────────

User get _mockUser => User(
      id: kMockUserId,
      name: kMockUserName,
      email: kMockUserEmail,
      subscriptionStatus: 'free',
      createdAt: DateTime(2026, 1, 1),
    );

// ─────────────────────────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    if (kMockAuth) {
      // Check if we already wrote a mock token (i.e. user "logged in").
      final token = await ref
          .read(secureStorageProvider)
          .read(StorageKeys.accessToken);
      return (token != null && token.isNotEmpty) ? _mockUser : null;
    }

    // Real path — restore session from secure storage.
    return ref.watch(authRepositoryProvider).getCurrentUser();
  }

  // ── Login ──────────────────────────────────────────────────────

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    if (kMockAuth) {
      await _writeMockTokens();
      state = AsyncValue.data(_mockUser);
      return null; // success
    }

    try {
      final fingerprint = await ref
          .read(deviceFingerprintServiceProvider)
          .getFingerprint();

      final useCase = ref.read(loginUseCaseProvider);
      final result = await useCase(
        email: email,
        password: password,
        deviceFingerprint: fingerprint,
      );

      if (result.isSuccess) {
        state = AsyncValue.data(result.user);
        return null;
      } else {
        state = const AsyncValue.data(null);
        return result.failure?.message ?? 'Login failed.';
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return e.toString();
    }
  }

  // ── Signup ─────────────────────────────────────────────────────

  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    state = const AsyncValue.loading();

    if (kMockAuth) {
      await _writeMockTokens();
      state = AsyncValue.data(_mockUser);
      return null; // success
    }

    try {
      final fingerprint = await ref
          .read(deviceFingerprintServiceProvider)
          .getFingerprint();

      final useCase = ref.read(signupUseCaseProvider);
      final result = await useCase(
        name: name,
        email: email,
        password: password,
        phone: phone,
        deviceFingerprint: fingerprint,
      );

      if (result.isSuccess) {
        state = AsyncValue.data(result.user);
        return null;
      } else {
        state = const AsyncValue.data(null);
        return result.failure?.message ?? 'Signup failed.';
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return e.toString();
    }
  }

  // ── Logout ─────────────────────────────────────────────────────

  Future<void> logout() async {
    if (kMockAuth) {
      await ref.read(secureStorageProvider).deleteAll();
      state = const AsyncValue.data(null);
      return;
    }

    try {
      await ref.read(logoutUseCaseProvider).call();
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  // ── Private helpers ────────────────────────────────────────────

  Future<void> _writeMockTokens() async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(StorageKeys.accessToken, kMockAccessToken);
    await storage.write(StorageKeys.refreshToken, kMockRefreshToken);
    await storage.write(StorageKeys.userId, kMockUserId);
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, User?>(() => AuthNotifier());
