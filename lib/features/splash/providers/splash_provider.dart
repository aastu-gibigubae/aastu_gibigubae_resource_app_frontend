import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/constants/storage_keys.dart';

/// ================================================================
/// SPLASH PROVIDER
///
/// Determines where to navigate after the splash screen:
///   • onboarding  — first launch (onboarding not yet seen)
///   • login       — returning user without a valid session
///   • selection   — returning user with a valid session
/// ================================================================

enum SplashDestination { onboarding, login, selection }

final splashDestinationProvider =
    FutureProvider<SplashDestination>((ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  final storage = ref.watch(secureStorageProvider);

  // ── Check if onboarding was seen ────────────────────────────────
  final onboardingSeen =
      prefs.getBool(StorageKeys.onboardingSeen) ?? false;

  if (!onboardingSeen) {
    return SplashDestination.onboarding;
  }

  // ── Check if user has a valid token ─────────────────────────────
  final token = await storage.read(StorageKeys.accessToken);
  final hasToken = token != null && token.isNotEmpty;

  return hasToken
      ? SplashDestination.selection
      : SplashDestination.login;
});
