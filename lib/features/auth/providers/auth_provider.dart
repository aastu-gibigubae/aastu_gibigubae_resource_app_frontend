import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/errors/error_mapper.dart';
import '../domain/entities/user.dart';
import 'session_provider.dart';

/// ================================================================
/// AUTH PROVIDER
///
/// Holds the currently authenticated user.
/// AsyncValue[User?] — null means logged out.
/// ================================================================

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    return ref.watch(authRepositoryProvider).getCurrentUser();
  }

  // ── Login ──────────────────────────────────────────────────────

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

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
      final failure = ErrorMapper.fromError(e);
      state = AsyncValue.error(failure, st);
      return failure.message;
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
        // New user — clear any leftover selection/explore flags
        // so they always go through the selection flow fresh.
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(StorageKeys.selectionCompleted);
        await prefs.remove(StorageKeys.exploreSeen);
        await prefs.remove(StorageKeys.paymentSeen);

        state = AsyncValue.data(result.user);
        return null;
      } else {
        state = const AsyncValue.data(null);
        return result.failure?.message ?? 'Signup failed.';
      }
    } catch (e, st) {
      final failure = ErrorMapper.fromError(e);
      state = AsyncValue.error(failure, st);
      return failure.message;
    }
  }

  // ── Logout ─────────────────────────────────────────────────────

  Future<void> logout() async {
    state = const AsyncValue.loading();

    try {
      await ref.read(logoutUseCaseProvider).call();
    } finally {
      state = const AsyncValue.data(null);
      _invalidateSessionProviders();
    }
  }

  /// Invalidates all providers that derive state from SecureStorage
  /// so that no stale isPremium / hasSession values persist after logout.
  void _invalidateSessionProviders() {
    ref.invalidateSelf();
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    ref.container.invalidate(hasSessionProvider);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    ref.container.invalidate(subscriptionStatusProvider);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    ref.container.invalidate(isPremiumProvider);
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, User?>(() => AuthNotifier());
