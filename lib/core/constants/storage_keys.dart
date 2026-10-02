/// ================================================================
/// STORAGE KEYS
///
/// Centralised keys for SecureStorage, SharedPreferences, and
/// the local SQLite database.
/// ================================================================
library;

class StorageKeys {
  StorageKeys._();

  // ── Secure Storage (tokens & sensitive data) ─────────────────────
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String cachedUser = 'cached_user';
  static const String deviceFingerprint = 'device_fingerprint';

  // ── SharedPreferences (simple flags) ─────────────────────────────
  static const String onboardingSeen = 'onboarding_seen';
  static const String selectionCompleted = 'selection_completed';
  static const String exploreSeen = 'explore_seen';
  static const String paymentSeen = 'payment_seen';
  static const String lastHeartbeat = 'last_heartbeat_ts';
  static const String lastVerification = 'last_verification_ts';
  static const String subscriptionStatus = 'subscription_status';
  static const String rememberMe = 'remember_me';
  static const String savedEmail = 'saved_email';

  // ── SQLite table / column names ───────────────────────────────────
  static const String cachedResourcesTable = 'cached_resources';
  static const String cachedStreamsTable = 'cached_streams';
  static const String cachedDepartmentsTable = 'cached_departments';
  static const String cachedCoursesTable = 'cached_courses';
  static const String cachedResourceItemsTable = 'cached_resource_items';
  static const String cachedNotificationsTable = 'cached_notifications';

  static const String colId = 'id';
  static const String colResourceId = 'resource_id';
  static const String colFilePath = 'file_path';
  static const String colChecksum = 'checksum';
  static const String colUpdatedAt = 'updated_at';
  static const String colCachedAt = 'cached_at';
  static const String colIsPremium = 'is_premium';
  static const String colTitle = 'title';
  static const String colCategory = 'category';
  static const String colCourseName = 'course_name';
  static const String colFileSizeBytes = 'file_size_bytes';
  static const String colCourseId = 'course_id';
  static const String colDepartmentId = 'department_id';
  static const String colAcademicYear = 'academic_year';
  static const String colStreamId = 'stream_id';
  static const String colSemesterLabel = 'semester_label';
  static const String colIconKey = 'icon_key';
  static const String colResourceCount = 'resource_count';
  static const String colDescription = 'description';
  static const String colIsFreeSample = 'is_free_sample';
  static const String colLocked = 'locked';
  static const String colFileUrl = 'file_url';
  static const String colType = 'type';
  static const String colMessage = 'message';
  static const String colReadStatus = 'read_status';
  static const String colCreatedAt = 'created_at';
  static const String colSyncedAt = 'synced_at';
}
