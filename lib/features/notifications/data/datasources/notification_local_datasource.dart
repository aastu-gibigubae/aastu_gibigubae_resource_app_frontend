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

  Future<void> cacheNotifications(List<NotificationItem> items) async {
    try {
      final now = DateTime.now().toIso8601String();
      for (final item in items) {
        final idInt = int.tryParse(item.id) ?? 0;
        if (idInt <= 0) continue;

        await LocalDatabase.insert(
          StorageKeys.cachedNotificationsTable,
          {
            StorageKeys.colId: idInt,
            StorageKeys.colType: _mapTitleToType(item.title),
            StorageKeys.colMessage: item.message,
            StorageKeys.colReadStatus: item.isRead ? 1 : 0,
            StorageKeys.colCreatedAt: item.timestamp,
            StorageKeys.colSyncedAt: now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
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
