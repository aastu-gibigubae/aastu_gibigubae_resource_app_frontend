import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/storage/secure_storage.dart';
import 'route_names.dart';

/// ================================================================
/// ROUTE GUARDS
///
/// Navigation rules:
///   • Unauthenticated → protected route  : redirect to /login
///   • Authenticated   → /login or /signup : redirect based on plan
///   • Premium user    → /selection        : redirect to /home
///   • Free user       → /login or /signup : redirect to /selection
/// ================================================================

class RouteGuards {
  final SecureStorage _secureStorage;

  const RouteGuards(this._secureStorage);

  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final location = state.matchedLocation;

    final token = await _secureStorage.read(StorageKeys.accessToken);
    final isLoggedIn = token != null && token.isNotEmpty;

    // Routes accessible regardless of auth state.
    final isPublic = location == RouteNames.splash ||
        location == RouteNames.onboarding ||
        location == RouteNames.login ||
        location == RouteNames.signup ||
        location == RouteNames.selection ||
        location == RouteNames.courseResources;

    // Unauthenticated users hit protected routes → send to login.
    if (!isLoggedIn && !isPublic) {
      return RouteNames.login;
    }

    if (isLoggedIn) {
      final subscriptionStatus =
          await _secureStorage.read(StorageKeys.subscriptionStatus) ?? 'none';
      final isPremium = subscriptionStatus == 'active';

      // Premium users trying to re-enter login/signup → home.
      // Free users trying to re-enter login/signup → selection.
      if (location == RouteNames.login || location == RouteNames.signup) {
        return isPremium ? RouteNames.home : RouteNames.selection;
      }

      // Premium users visiting selection or course-resources →
      // they already have access, send them to home.
      if (isPremium &&
          (location == RouteNames.selection ||
              location == RouteNames.courseResources)) {
        return RouteNames.home;
      }
    }

    return null;
  }
}
