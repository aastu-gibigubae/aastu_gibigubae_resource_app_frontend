import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/device/providers/device_status_provider.dart';
import '../../features/notifications/providers/notification_providers.dart';
import '../../features/resources/providers/resource_providers.dart';

/// ================================================================
/// SYNC SERVICE
///
/// Monitors network state changes. When the device transitions from
/// offline to online, it automatically syncs newly added remote data
/// and updates the offline SQLite store.
/// ================================================================

class SyncService {
  final Ref _ref;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _wasOffline = false;

  SyncService(this._ref) {
    _initListener();
  }

  void _initListener() {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);

      if (isOnline && _wasOffline) {
        debugPrint('[SyncService] Device back online — syncing newly added data...');
        syncAll();
      }

      _wasOffline = !isOnline;
    });
  }

  /// Refreshes all active resource feeds and synchronizes with local storage.
  Future<void> syncAll() async {
    try {
      // Re-fetch streams & departments
      _ref.invalidate(streamsProvider);

      // Re-fetch notifications
      _ref.invalidate(notificationsProvider);

      // Refresh downloaded resource lists
      _ref.invalidate(downloadedResourceIdsProvider);
      _ref.invalidate(downloadedResourcesProvider);

      // Heartbeat / status check
      _ref.read(deviceStatusProvider.notifier).refresh();

      debugPrint('[SyncService] Background sync complete.');
    } catch (e) {
      debugPrint('[SyncService] Sync error: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(ref);
  ref.onDispose(service.dispose);
  return service;
});
