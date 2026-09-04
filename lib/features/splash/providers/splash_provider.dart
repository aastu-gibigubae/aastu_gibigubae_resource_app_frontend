import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/constants/storage_keys.dart';

/// ================================================================
/// SPLASH PROVIDER
///
/// Determines where to navigate after the splash screen:
///
///   • onboarding  — first launch (onboarding not yet seen)
///   • login       — returning user without a valid session
///   • home        — returning premium user (subscription active)
///   • selection   — returning free user (logged in, not premium)
/// ================================================================

enum SplashDestination { onboarding, login, home, selection }

final splashDestinationProvider =
    FutureProvider<SplashDestination>((ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  final storage = ref.watch(secureStorageProvider);

  // ── First launch: show onboarding ─────────────────────────────
  final onboardingSeen =
      prefs.getBool(StorageKeys.onboardingSeen) ?? false;

  if (!onboardingSeen) {
    return SplashDestination.onboarding;
  }

  // ── No session: go to login ────────────────────────────────────
  final token = await storage.read(StorageKeys.accessToken);
  final hasToken = token != null && token.isNotEmpty;

  if (!hasToken) {
    return SplashDestination.login;
  }

  // ── Has session: check subscription ───────────────────────────
  final subscriptionStatus =
      await storage.read(StorageKeys.subscriptionStatus) ?? 'none';

  final isPremium = subscriptionStatus == 'active';

  return isPremium
      ? SplashDestination.home        // premium → skip selection
      : SplashDestination.selection;  // free → show selection/preview
});
