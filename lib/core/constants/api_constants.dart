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
  static const String baseUrl = 'https://api.aastufreshman.com/api/v1';

  // ── Auth ─────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // ── Device ───────────────────────────────────────────────────────
  static const String heartbeat = '/device/heartbeat';
  static const String deviceStatus = '/device/status';

  // ── Browse ────────────────────────────────────────────────────────
  static const String streams = '/streams';
  static const String departments = '/departments';
  static const String courses = '/courses';
  static const String resources = '/resources';

  // ── Search ────────────────────────────────────────────────────────
  static const String search = '/search';

  // ── Downloads ─────────────────────────────────────────────────────
  static const String downloadSignedUrl = '/resources/:id/download';

  // ── Reports ───────────────────────────────────────────────────────
  static const String reportResource = '/resources/:id/report';

  // ── Notifications ─────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/:id/read';

  // ── Helpers ───────────────────────────────────────────────────────

  /// Replace the `:id` placeholder with the actual value.
  static String withId(String template, String id) {
    return template.replaceFirst(':id', id);
  }
}
