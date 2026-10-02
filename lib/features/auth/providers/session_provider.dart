import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/constants/storage_keys.dart';

import 'auth_provider.dart';

/// ================================================================
/// SESSION PROVIDER
///
/// Simple computed provider that exposes whether the user has
/// a valid stored access token without loading the full User object.
/// Useful for route guards and conditional UI.
/// ================================================================

final hasSessionProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  final token = await storage.read(StorageKeys.accessToken);
  return token != null && token.isNotEmpty;
});

/// The subscription status string from secure storage.
/// Returns 'free' when not set.
final subscriptionStatusProvider = FutureProvider<String>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  final status = await storage.read(StorageKeys.subscriptionStatus);
  return status ?? 'free';
});

/// Convenience bool — true when subscription is active and not expired.
/// Also enforces the 7-day offline verification rule if the user has been
/// offline for more than 7 days since last online verification.
final isPremiumProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user != null) {
    return user.isPremium;
  }

  final status = await ref.watch(subscriptionStatusProvider.future);
  if (status != 'premium' && status != 'active') {
    return false;
  }

  // 7-day offline re-verification rule check
  final storage = ref.watch(secureStorageProvider);
  final lastVerifStr = await storage.read(StorageKeys.lastVerification);
  if (lastVerifStr != null) {
    final lastVerif = DateTime.tryParse(lastVerifStr);
    if (lastVerif != null) {
      final daysSinceVerif = DateTime.now().difference(lastVerif).inDays;
      if (daysSinceVerif >= 7) {
        return false;
      }
    }
  }

  return true;
});
