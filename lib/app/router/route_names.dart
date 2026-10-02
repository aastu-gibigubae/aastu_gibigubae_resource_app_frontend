// ================================================================
// ROUTE NAMES
//
// All named routes used by go_router.
// ================================================================

class RouteNames {
  RouteNames._();

  // ── Core ──────────────────────────────────────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // ── Auth ──────────────────────────────────────────────────────
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // ── Main shell (4 bottom-nav tabs) ────────────────────────────
  static const String selection = '/selection';
  static const String exploreResources = '/explore-resources';
  static const String home = '/home';                   // tab 0 – Home
  static const String browse = '/browse';               // tab 1 – Browse (Freshman courses)
  static const String status = '/status';               // tab 2 – Status
  static const String profile = '/profile';             // tab 3 – Profile
  static const String notifications = '/notifications'; // Pushed page from Home bell

  // ── Resource Hub Flow (Screen 1 to 5) ─────────────────────────
  static const String courseDetail = '/course-detail';
  static const String courseCategoryResources = '/course-category-resources';
  static const String resourceDetail = '/resource-detail';

  // ── Premium ───────────────────────────────────────────────────
  static const String premium = '/premium';
  static const String paymentReview = '/payment-review';
  static const String courseResources = '/course-resources';

  /// Helper — builds the course-resources path with query params.
  static String courseResourcesPath({
    required int year,
    required String streamName,
  }) =>
      '/course-resources?year=$year&stream=${Uri.encodeComponent(streamName)}';

  // ── Device ────────────────────────────────────────────────────
  static const String deviceStatus = '/device-status';

  // ── Legacy / Alternative aliases ──────────────────────────────
  static const String streams = '/streams';
  static const String departments = '/departments';
  static const String courses = '/courses';
  static const String search = '/search';
  static const String downloads = '/downloads';
  static const String pdfViewer = '/pdf-viewer';
  static const String reportResource = '/report/:id';
  static const String map = '/map';
  static const String coupons = '/coupons';
}
