import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/constants/storage_keys.dart';

/// ================================================================
/// ONBOARDING PROVIDER
///
/// Persists the "onboarding seen" flag so the welcome page is
/// only shown on first launch.
/// ================================================================

final onboardingProvider =
    AsyncNotifierProvider<OnboardingNotifier, bool>(
  OnboardingNotifier.new,
);

class OnboardingNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(StorageKeys.onboardingSeen) ?? false;
  }

  /// Mark onboarding as completed. Call this when the user taps
  /// "Get Access" on the welcome page.
  Future<void> completeOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(StorageKeys.onboardingSeen, true);
    state = const AsyncValue.data(true);
  }
}
