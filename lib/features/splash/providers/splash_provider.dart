import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/constants/storage_keys.dart';

/// ================================================================
/// SPLASH PROVIDER
///
/// Determines where to navigate after the splash screen:
///   • onboarding       — first launch (onboarding not yet seen)
///   • login            — returning user without a valid session
///   • home             — premium user or free user who completed onboarding flow
///   • selection        — user who hasn't selected year and stream yet
///   • exploreResources — user who selected year/stream but hasn't seen explore/payment
/// ================================================================

enum SplashDestination { onboarding, login, home, selection, exploreResources }

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

  if (!hasToken) {
    return SplashDestination.login;
  }

  // ── Check if the user is premium → go to home ───────────────────
  final subscriptionStatus =
      await storage.read(StorageKeys.subscriptionStatus) ?? 'none';
  final isPremium =
      subscriptionStatus == 'active' || subscriptionStatus == 'premium';

  if (isPremium) {
    return SplashDestination.home;
  }

  // ── Check if user completed year & stream selection ─────────────
  final selectionCompleted =
      prefs.getBool(StorageKeys.selectionCompleted) ?? false;

  if (!selectionCompleted) {
    return SplashDestination.selection;
  }

  // ── Check if user has seen payment or explore courses screen ─────
  final exploreSeen = prefs.getBool(StorageKeys.exploreSeen) ?? false;
  final paymentSeen = prefs.getBool(StorageKeys.paymentSeen) ?? false;

  if (!exploreSeen && !paymentSeen) {
    return SplashDestination.exploreResources;
  }

  return SplashDestination.home;
});
