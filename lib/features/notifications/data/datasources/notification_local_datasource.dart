import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/local_database.dart';
import '../../domain/entities/notification_item.dart';

/// ================================================================
/// NOTIFICATION LOCAL DATASOURCE
///
/// Handles offline caching and read-status tracking for notifications.
/// ================================================================
class NotificationLocalDatasource {
  const NotificationLocalDatasource();

  /// Efficiently caches only NEW notifications using a set-diff strategy:
  ///   1. Fetch all existing IDs in a single SQL query  → O(1) lookups
  ///   2. Filter incoming list to new-only items        → O(N)
  ///   3. Batch-insert new items in one transaction     → 1 DB round-trip
  ///
  /// This replaces the old N-insert loop and avoids N+1 DB calls.
  Future<void> cacheNotifications(List<NotificationItem> items) async {
    if (items.isEmpty) return;
    try {
      final now = DateTime.now().toIso8601String();

      // ── Step 1: Load all known IDs in a single query ──────────────
      final existingRows = await LocalDatabase.query(
        StorageKeys.cachedNotificationsTable,
        // Only fetch the id column to minimise data transfer
      );
      final existingIds = existingRows
          .map((r) => r[StorageKeys.colId] as int)
          .toSet(); // O(1) lookup

      // ── Step 2: Keep only items we have not seen yet ───────────────
      final newItems = items.where((item) {
        final idInt = int.tryParse(item.id) ?? 0;
        return idInt > 0 && !existingIds.contains(idInt);
      }).toList();

      if (newItems.isEmpty) {
        debugPrint('[NotificationLocalDatasource] No new notifications to cache.');
        return;
      }

      // ── Step 3: Batch-insert in one SQLite transaction ─────────────
      final rows = newItems.map((item) {
        final idInt = int.parse(item.id);
        return <String, dynamic>{
          StorageKeys.colId: idInt,
          StorageKeys.colType: _mapTitleToType(item.title),
          StorageKeys.colMessage: item.message,
          StorageKeys.colReadStatus: item.isRead ? 1 : 0,
          StorageKeys.colCreatedAt: item.timestamp,
          StorageKeys.colSyncedAt: now,
        };
      }).toList();

      await LocalDatabase.batchInsert(
        StorageKeys.cachedNotificationsTable,
        rows,
        conflictAlgorithm: ConflictAlgorithm.ignore, // never overwrite read-status
      );

      debugPrint(
        '[NotificationLocalDatasource] Cached ${newItems.length} new notification(s).'
      );
    } catch (e) {
      debugPrint('[NotificationLocalDatasource] cacheNotifications error: $e');
    }
  }

  Future<List<NotificationItem>> getCachedNotifications() async {
    try {
      final rows = await LocalDatabase.query(
        StorageKeys.cachedNotificationsTable,
        orderBy: '${StorageKeys.colId} DESC',
      );

      return rows.map((r) {
        final id = r[StorageKeys.colId] as int;
        final type = (r[StorageKeys.colType] as String?) ?? 'announcement';
        final message = (r[StorageKeys.colMessage] as String?) ?? '';
        final isRead = (r[StorageKeys.colReadStatus] as int?) == 1;
        final createdAtStr = r[StorageKeys.colCreatedAt] as String?;

        return NotificationItem.fromBackend(
          id: id,
          type: type,
          message: message,
          readStatus: isRead,
          createdAt: createdAtStr != null ? DateTime.tryParse(createdAtStr) : null,
        );
      }).toList();
    } catch (e) {
      debugPrint('[NotificationLocalDatasource] getCachedNotifications error: $e');
      return [];
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await LocalDatabase.update(
        StorageKeys.cachedNotificationsTable,
        {StorageKeys.colReadStatus: 1},
        where: '${StorageKeys.colId} = ?',
        whereArgs: [notificationId],
      );
    } catch (e) {
      debugPrint('[NotificationLocalDatasource] markAsRead error: $e');
    }
  }

  String _mapTitleToType(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('approved') || lower.contains('premium')) {
      return 'premium_approved';
    }
    if (lower.contains('report') || lower.contains('issue')) {
      return 'issue_report_addressed';
    }
    if (lower.contains('expir')) {
      return 'subscription_expiring';
    }
    return 'announcement';
  }
}
