import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/errors/error_mapper.dart';
import '../data/datasources/notification_remote_datasource.dart';
import '../domain/entities/notification_item.dart';

// Datasource provider
final notificationRemoteDatasourceProvider =
    Provider<NotificationRemoteDatasource>((ref) {
  return NotificationRemoteDatasource(ref.watch(dioProvider));
});

// Notifications state notifier
class NotificationsNotifier
    extends AutoDisposeAsyncNotifier<List<NotificationItem>> {
  @override
  Future<List<NotificationItem>> build() => _fetch();

  Future<List<NotificationItem>> _fetch() async {
    final ds = ref.read(notificationRemoteDatasourceProvider);
    try {
      final models = await ds.getNotifications();
      return models
          .map((m) => NotificationItem.fromBackend(
                id: m.id,
                type: m.type,
                message: m.message,
                readStatus: m.readStatus,
                createdAt: m.createdAt,
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final ds = ref.read(notificationRemoteDatasourceProvider);
    try {
      await ds.markAsRead(notificationId: notificationId);
      // Refresh the list after marking as read.
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
