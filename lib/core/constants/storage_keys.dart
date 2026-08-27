/// ================================================================
/// STORAGE KEYS
///
/// Centralised keys for SecureStorage, SharedPreferences, and
/// the local SQLite database.
/// ================================================================

class StorageKeys {
  StorageKeys._();

  // ── Secure Storage (tokens & sensitive data) ─────────────────────
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String deviceFingerprint = 'device_fingerprint';

  // ── SharedPreferences (simple flags) ─────────────────────────────
  static const String onboardingSeen = 'onboarding_seen';
  static const String lastHeartbeat = 'last_heartbeat_ts';
  static const String lastVerification = 'last_verification_ts';
  static const String subscriptionStatus = 'subscription_status';

  // ── SQLite table / column names ───────────────────────────────────
  static const String cachedResourcesTable = 'cached_resources';
  static const String colId = 'id';
  static const String colResourceId = 'resource_id';
  static const String colFilePath = 'file_path';
  static const String colChecksum = 'checksum';
  static const String colUpdatedAt = 'updated_at';
  static const String colCachedAt = 'cached_at';
  static const String colIsPremium = 'is_premium';
}
