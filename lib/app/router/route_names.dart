// ================================================================
// ROUTE NAMES
//
// All named routes used by go_router.
// Developer B: add your route names here and inform Developer A.
// ================================================================

class RouteNames {
  RouteNames._();

  // ── Core ──────────────────────────────────────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // ── Auth ──────────────────────────────────────────────────────
  static const String login = '/login';
  static const String signup = '/signup';

  // ── Main shell (bottom-nav tabs) ──────────────────────────────
  static const String selection = '/selection';
  static const String home = '/home';       // tab 0 – Explore
  static const String map = '/map';         // tab 1 – Map
  static const String coupons = '/coupons'; // tab 2 – Coupons
  static const String profile = '/profile'; // tab 3 – Profile

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

  // ── Browse (Developer B) ──────────────────────────────────────
  static const String streams = '/streams';
  static const String departments = '/departments';
  static const String courses = '/courses';
  static const String resources = '/resources';

  // ── Search (Developer B) ──────────────────────────────────────
  static const String search = '/search';

  // ── Resource detail (Developer B) ─────────────────────────────
  static const String resourceDetail = '/resource/:id';

  // ── Downloads (Developer B) ───────────────────────────────────
  static const String downloads = '/downloads';
  static const String pdfViewer = '/pdf-viewer';

  // ── Reports (Developer B) ─────────────────────────────────────
  static const String reportResource = '/report/:id';

  // ── Notifications (Developer B) ───────────────────────────────
  static const String notifications = '/notifications';
}
