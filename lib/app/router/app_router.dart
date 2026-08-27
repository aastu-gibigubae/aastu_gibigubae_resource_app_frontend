import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/premium/presentation/pages/premium_page.dart';
import '../../features/premium/presentation/pages/payment_review_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/resources/pages/course_resources_page.dart';
import '../../features/selection/presentation/pages/selection_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../shell/main_shell.dart';
import 'route_guards.dart';
import 'route_names.dart';

/// ================================================================
/// APP ROUTER
/// ================================================================

GoRouter createRouter({
  required RouteGuards guards,
}) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: guards.redirect,
    debugLogDiagnostics: true,

    routes: [

      // ============================================================
      // SPLASH
      // ============================================================

      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SplashPage(),
        ),
      ),

      // ============================================================
      // ONBOARDING / WELCOME
      // ============================================================

      GoRoute(
        path: RouteNames.onboarding,
        name: RouteNames.onboarding,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: WelcomePage(),
        ),
      ),

      // ============================================================
      // AUTH
      // ============================================================

      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        pageBuilder: (context, state) => const MaterialPage(
          child: LoginPage(),
        ),
      ),

      GoRoute(
        path: RouteNames.signup,
        name: RouteNames.signup,
        pageBuilder: (context, state) => const MaterialPage(
          child: SignUpPage(),
        ),
      ),

      // ============================================================
      // SELECTION  (before entering the shell)
      // ============================================================

      GoRoute(
        path: RouteNames.selection,
        name: RouteNames.selection,
        pageBuilder: (context, state) => const MaterialPage(
          child: SelectionPage(),
        ),
      ),

      // ============================================================
      // PREMIUM / PAYMENT  (full-screen, outside the shell)
      // ============================================================

      GoRoute(
        path: RouteNames.premium,
        name: RouteNames.premium,
        pageBuilder: (context, state) => const MaterialPage(
          child: PremiumPage(),
        ),
      ),

      GoRoute(
        path: RouteNames.paymentReview,
        name: RouteNames.paymentReview,
        pageBuilder: (context, state) => const MaterialPage(
          child: PaymentReviewPage(),
        ),
      ),

      // ============================================================
      // COURSE RESOURCES  (full-screen, outside the shell)
      // ============================================================

      GoRoute(
        path: RouteNames.courseResources,
        name: RouteNames.courseResources,
        pageBuilder: (context, state) => const MaterialPage(
          child: CourseResourcesPage(),
        ),
      ),

      // ============================================================
      // MAIN SHELL  — persistent bottom nav
      //
      // Branch order must match MainShell._tabs order:
      //   0 → Explore  (/home)
      //   1 → Map      (/map)
      //   2 → Coupons  (/coupons)
      //   3 → Profile  (/profile)
      // ============================================================

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(
          navigationShell: navigationShell,
        ),
        branches: [

          // ── Branch 0: Explore / Home ────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                name: RouteNames.home,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: _HomePlaceholder(),
                ),
              ),
            ],
          ),

          // ── Branch 1: Map ───────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.map,
                name: RouteNames.map,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: _PlaceholderTab(label: 'Map'),
                ),
              ),
            ],
          ),

          // ── Branch 2: Coupons ───────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.coupons,
                name: RouteNames.coupons,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: _PlaceholderTab(label: 'Coupons'),
                ),
              ),
            ],
          ),

          // ── Branch 3: Profile ───────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.profile,
                name: RouteNames.profile,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfilePage(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],

    // ==============================================================
    // ERROR PAGE
    // ==============================================================

    errorPageBuilder: (context, state) => MaterialPage(
      child: _RouterErrorPage(error: state.error),
    ),
  );
}

// ── Placeholders ──────────────────────────────────────────────────

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFDF6EE),
      body: Center(
        child: Text(
          'Home — Developer B',
          style: TextStyle(fontSize: 18, color: Color(0xFF1A1A1A)),
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String label;
  const _PlaceholderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EE),
      body: Center(
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, color: Color(0xFF1A1A1A)),
        ),
      ),
    );
  }
}

// ── Router error page ─────────────────────────────────────────────

class _RouterErrorPage extends StatelessWidget {
  final GoException? error;
  const _RouterErrorPage({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 70, color: Colors.redAccent),

                const SizedBox(height: 20),

                const Text(
                  'Something went wrong',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B2D6B),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  error?.toString() ??
                      'The requested page could not be opened.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15, color: Colors.grey),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.go(RouteNames.onboarding),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B2D6B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Back to Welcome',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
