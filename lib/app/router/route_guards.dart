import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/storage/secure_storage.dart';
import 'route_names.dart';

/// ================================================================
/// ROUTE GUARDS
///
/// Navigation rules:
///   • Unauthenticated → protected route  : redirect to /login
///   • Authenticated   → /login or /signup : redirect based on user progress
///   • User completed selection visiting /selection : redirect to explore or home
/// ================================================================

class RouteGuards {
  final SecureStorage _secureStorage;
  final SharedPreferences? _prefs;

  const RouteGuards(this._secureStorage, [this._prefs]);

  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final location = state.matchedLocation;

    final token = await _secureStorage.read(StorageKeys.accessToken);
    final isLoggedIn = token != null && token.isNotEmpty;

    // Routes accessible regardless of auth state.
    final isPublic = location == RouteNames.splash ||
        location == RouteNames.onboarding ||
        location == RouteNames.login ||
        location == RouteNames.signup;

    // Unauthenticated users hit protected routes → send to login.
    if (!isLoggedIn && !isPublic) {
      return RouteNames.login;
    }

    if (isLoggedIn) {
      final subscriptionStatus =
          await _secureStorage.read(StorageKeys.subscriptionStatus) ?? 'none';
      final isPremium =
          subscriptionStatus == 'active' || subscriptionStatus == 'premium';

      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final selectionCompleted =
          prefs.getBool(StorageKeys.selectionCompleted) ?? false;
      final exploreSeen = prefs.getBool(StorageKeys.exploreSeen) ?? false;
      final paymentSeen = prefs.getBool(StorageKeys.paymentSeen) ?? false;

      String getPostLoginDestination() {
        if (isPremium) return RouteNames.home;
        if (!selectionCompleted) return RouteNames.selection;
        if (!exploreSeen && !paymentSeen) return RouteNames.exploreResources;
        return RouteNames.home;
      }

      // Premium or returning users trying to re-enter login/signup
      if (location == RouteNames.login || location == RouteNames.signup) {
        return getPostLoginDestination();
      }

      // If user already completed selection and visits /selection
      if (location == RouteNames.selection && (isPremium || selectionCompleted)) {
        if (isPremium) return RouteNames.home;
        if (!exploreSeen && !paymentSeen) return RouteNames.exploreResources;
        return RouteNames.home;
      }
    }

    return null;
  }
}
