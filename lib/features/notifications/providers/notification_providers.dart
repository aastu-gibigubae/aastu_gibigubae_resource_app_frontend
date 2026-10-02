import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/errors/error_mapper.dart';
import '../data/datasources/notification_local_datasource.dart';
import '../data/datasources/notification_remote_datasource.dart';
import '../domain/entities/notification_item.dart';

// Datasource providers
final notificationRemoteDatasourceProvider =
    Provider<NotificationRemoteDatasource>((ref) {
  return NotificationRemoteDatasource(ref.watch(dioProvider));
});

final notificationLocalDatasourceProvider =
    Provider<NotificationLocalDatasource>((ref) {
  return const NotificationLocalDatasource();
});

// Notifications state notifier with offline caching
class NotificationsNotifier
    extends AutoDisposeAsyncNotifier<List<NotificationItem>> {
  @override
  Future<List<NotificationItem>> build() => _fetch();

  Future<List<NotificationItem>> _fetch() async {
    final remoteDs = ref.read(notificationRemoteDatasourceProvider);
    final localDs = ref.read(notificationLocalDatasourceProvider);

    try {
      final models = await remoteDs.getNotifications();
      final items = models
          .map((m) => NotificationItem.fromBackend(
                id: m.id,
                type: m.type,
                message: m.message,
                readStatus: m.readStatus,
                createdAt: m.createdAt,
              ))
          .toList();

      // Cache for offline viewing
      await localDs.cacheNotifications(items);
      return items;
    } catch (_) {
      // On network failure / offline, read from SQLite cache
      final cached = await localDs.getCachedNotifications();
      return cached;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final remoteDs = ref.read(notificationRemoteDatasourceProvider);
    final localDs = ref.read(notificationLocalDatasourceProvider);

    try {
      await remoteDs.markAsRead(notificationId: notificationId);
      await localDs.markAsRead(notificationId);
      // Refresh the list after marking as read
      state = await AsyncValue.guard(_fetch);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioException(e);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

final notificationsProvider = AutoDisposeAsyncNotifierProvider<
    NotificationsNotifier, List<NotificationItem>>(
  NotificationsNotifier.new,
);
