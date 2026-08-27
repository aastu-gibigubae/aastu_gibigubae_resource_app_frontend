import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/storage/secure_storage.dart';
import 'route_names.dart';

/// ================================================================
/// ROUTE GUARDS
///
/// Redirect logic evaluated on every navigation event.
///
/// Rules:
///   • Unauthenticated users are sent to /login.
///   • Authenticated users cannot revisit /login or /signup.
///   • Onboarding is shown once; after that it is skipped.
/// ================================================================

class RouteGuards {
  final SecureStorage _secureStorage;

  const RouteGuards(this._secureStorage);

  // ── Main redirect callback ─────────────────────────────────────

  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final location = state.matchedLocation;

    final token = await _secureStorage.read(StorageKeys.accessToken);
    final isLoggedIn = token != null && token.isNotEmpty;

    // Public routes that don't need a session check.
    final isAuthRoute = location == RouteNames.login ||
        location == RouteNames.signup ||
        location == RouteNames.onboarding ||
        location == RouteNames.splash;

    // Redirect unauthenticated users away from protected routes.
    if (!isLoggedIn && !isAuthRoute) {
      return RouteNames.login;
    }

    // Redirect authenticated users away from login/signup.
    if (isLoggedIn &&
        (location == RouteNames.login || location == RouteNames.signup)) {
      return RouteNames.selection;
    }

    return null; // No redirect needed.
  }
}
