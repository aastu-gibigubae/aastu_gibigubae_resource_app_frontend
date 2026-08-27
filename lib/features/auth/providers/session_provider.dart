import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/constants/storage_keys.dart';

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

/// Convenience bool — true when subscription_status == 'premium'.
final isPremiumProvider = FutureProvider<bool>((ref) async {
  final status = await ref.watch(subscriptionStatusProvider.future);
  return status == 'premium';
});
