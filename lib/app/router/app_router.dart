import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/device/presentation/pages/device_status_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/premium/presentation/pages/premium_page.dart';
import '../../features/premium/presentation/pages/payment_review_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/resources/domain/entities/resource_category_type.dart';
import '../../features/resources/presentation/pages/browse_courses_page.dart';
import '../../features/resources/presentation/pages/category_resources_page.dart';
import '../../features/resources/presentation/pages/course_categories_page.dart';
import '../../features/resources/presentation/pages/home_page.dart';
import '../../features/resources/presentation/pages/resource_detail_page.dart';
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
      // SELECTION (before entering the shell)
      // ============================================================

      GoRoute(
        path: RouteNames.selection,
        name: RouteNames.selection,
        pageBuilder: (context, state) => const MaterialPage(
          child: SelectionPage(),
        ),
      ),

      // ============================================================
      // PREMIUM / PAYMENT (full-screen)
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

      GoRoute(
        path: RouteNames.courseResources,
        name: RouteNames.courseResources,
        pageBuilder: (context, state) => const MaterialPage(
          child: CourseCategoriesPage(courseId: 1),
        ),
      ),

      // ============================================================
      // COURSE BROWSING & RESOURCE DETAIL FLOW
      // ============================================================

      GoRoute(
        path: RouteNames.courseDetail,
        name: RouteNames.courseDetail,
        pageBuilder: (context, state) {
          final courseId = (state.extra is int) ? state.extra as int : 1;
          return MaterialPage(
            child: CourseCategoriesPage(courseId: courseId),
          );
        },
      ),

      GoRoute(
        path: RouteNames.courseCategoryResources,
        name: RouteNames.courseCategoryResources,
        pageBuilder: (context, state) {
          int courseId = 1;
          ResourceCategoryType category = ResourceCategoryType.handouts;
          if (state.extra is Map) {
            final map = state.extra as Map;
            courseId = map['courseId'] as int? ?? 1;
            category = map['category'] as ResourceCategoryType? ?? ResourceCategoryType.handouts;
          }
          return MaterialPage(
            child: CategoryResourcesPage(
              courseId: courseId,
              category: category,
            ),
          );
        },
      ),

      GoRoute(
        path: RouteNames.resourceDetail,
        name: RouteNames.resourceDetail,
        pageBuilder: (context, state) {
          final resId = (state.extra is int) ? state.extra as int : 101;
          return MaterialPage(
            child: ResourceDetailPage(resourceId: resId),
          );
        },
      ),

      GoRoute(
        path: RouteNames.profile,
        name: RouteNames.profile,
        pageBuilder: (context, state) => const MaterialPage(
          child: ProfilePage(),
        ),
      ),

      // ============================================================
      // MAIN SHELL — persistent 4 bottom nav tabs
      //
      // Branch order:
      //   0 → Home          (/home)
      //   1 → Browse        (/browse)
      //   2 → Status        (/status)
      //   3 → Notifications (/notifications)
      // ============================================================

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(
          navigationShell: navigationShell,
        ),
        branches: [

          // ── Branch 0: Home ──────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                name: RouteNames.home,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomePage(),
                ),
              ),
            ],
          ),

          // ── Branch 1: Browse (Freshman Courses) ─────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.browse,
                name: RouteNames.browse,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: BrowseCoursesPage(),
                ),
              ),
            ],
          ),

          // ── Branch 2: Status ────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.status,
                name: RouteNames.status,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DeviceStatusPage(),
                ),
              ),
            ],
          ),

          // ── Branch 3: Notifications ─────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.notifications,
                name: RouteNames.notifications,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: NotificationsPage(),
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
