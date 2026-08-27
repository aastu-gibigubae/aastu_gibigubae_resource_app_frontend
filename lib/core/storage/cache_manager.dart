import '../constants/app_constants.dart';
import '../constants/storage_keys.dart';
import 'local_database.dart';

/// ================================================================
/// CACHE MANAGER
///
/// Higher-level API over LocalDatabase for cached resource records.
/// Enforces the 7-day re-verification rule for premium content.
/// ================================================================

class CacheManager {
  const CacheManager();

  // ── Write ──────────────────────────────────────────────────────

  Future<void> cacheResource({
    required String resourceId,
    required String filePath,
    required bool isPremium,
    String? checksum,
    String? updatedAt,
  }) async {
    await LocalDatabase.insert(
      StorageKeys.cachedResourcesTable,
      {
        StorageKeys.colResourceId: resourceId,
        StorageKeys.colFilePath: filePath,
        StorageKeys.colChecksum: checksum,
        StorageKeys.colUpdatedAt: updatedAt,
        StorageKeys.colCachedAt: DateTime.now().toIso8601String(),
        StorageKeys.colIsPremium: isPremium ? 1 : 0,
      },
    );
  }

  // ── Read ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getCachedResource(String resourceId) async {
    final rows = await LocalDatabase.query(
      StorageKeys.cachedResourcesTable,
      where: '${StorageKeys.colResourceId} = ?',
      whereArgs: [resourceId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, dynamic>>> getAllCachedResources() async {
    return LocalDatabase.query(
      StorageKeys.cachedResourcesTable,
      orderBy: '${StorageKeys.colCachedAt} DESC',
    );
  }

  // ── Freshness check ────────────────────────────────────────────

  /// Returns true when the cached record is still valid.
  ///
  /// Free resources are always valid (no expiry).
  /// Premium resources expire after [AppConstants.cacheValidityDuration].
  bool isFresh(Map<String, dynamic> record) {
    final isPremium = (record[StorageKeys.colIsPremium] as int?) == 1;
    if (!isPremium) return true;

    final cachedAtStr = record[StorageKeys.colCachedAt] as String?;
    if (cachedAtStr == null) return false;

    final cachedAt = DateTime.tryParse(cachedAtStr);
    if (cachedAt == null) return false;

    return DateTime.now().difference(cachedAt) <
        AppConstants.cacheValidityDuration;
  }

  // ── Delete ─────────────────────────────────────────────────────

  Future<void> removeCachedResource(String resourceId) async {
    await LocalDatabase.delete(
      StorageKeys.cachedResourcesTable,
      where: '${StorageKeys.colResourceId} = ?',
      whereArgs: [resourceId],
    );
  }

  Future<void> clearAll() async {
    await LocalDatabase.delete(StorageKeys.cachedResourcesTable);
  }
}
