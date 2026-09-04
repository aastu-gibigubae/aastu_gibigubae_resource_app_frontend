/// ================================================================
/// API CONSTANTS
///
/// All backend endpoints live here.
/// Update this file when adding a new endpoint and inform the
/// other developer.
/// ================================================================

class ApiConstants {
  ApiConstants._();

  // ── Base URL ─────────────────────────────────────────────────────
  static const String baseUrl = 'https://resource-app-h7e9.onrender.com';

  // ── Auth ─────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // ── Device / Verification ─────────────────────────────────────────
  /// SRS Module 5 — FR-5.3 / FR-5.4
  static const String heartbeat = '/verify/heartbeat';

  // ── Browse ────────────────────────────────────────────────────────
  static const String streams = '/streams';
  static const String departments = '/departments';
  static const String courses = '/courses';

  /// GET /courses/:id/resources?category=&page=&limit=
  static String courseResources(String courseId) =>
      '/courses/$courseId/resources';

  // ── Search ────────────────────────────────────────────────────────
  static const String search = '/search';

  // ── Reports ───────────────────────────────────────────────────────
  static const String reportResource = '/resources/:id/report';

  // ── Notifications ─────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/:id/read';

  // ── Admin ─────────────────────────────────────────────────────────
  static const String adminUsers = '/admin/users';
  static const String adminGrantPremium = '/admin/users/:id/grant-premium';
  static const String adminRevokeDevice = '/admin/users/:id/revoke-device';
  static const String adminReports = '/admin/reports';
  static const String adminResolveReport = '/admin/reports/:id/resolve';

  // ── Helpers ───────────────────────────────────────────────────────

  /// Replace the `:id` placeholder with the actual value.
  static String withId(String template, String id) =>
      template.replaceFirst(':id', id);
}
