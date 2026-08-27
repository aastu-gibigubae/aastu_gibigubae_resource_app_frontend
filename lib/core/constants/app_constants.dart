/// ================================================================
/// APP CONSTANTS
/// ================================================================

class AppConstants {
  AppConstants._();

  static const String appName = 'AASTU Freshman Resource App';

  static const String appVersion = '1.0.0';

  // ── Timeouts ────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ── Pagination ──────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int firstPage = 1;

  // ── Cache ───────────────────────────────────────────────────────

  /// Cached premium content expires after 7 days without re-verification.
  static const Duration cacheValidityDuration = Duration(days: 7);

  // ── Heartbeat ───────────────────────────────────────────────────
  static const Duration heartbeatInterval = Duration(hours: 24);

  // ── Token ───────────────────────────────────────────────────────
  static const int tokenRefreshThresholdSeconds = 60;

  // ── UI ──────────────────────────────────────────────────────────
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration snackBarDuration = Duration(seconds: 3);
}
