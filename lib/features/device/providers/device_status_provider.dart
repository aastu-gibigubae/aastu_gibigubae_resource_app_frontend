import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/storage_keys.dart';

/// ================================================================
/// DEVICE STATUS PROVIDER
///
/// Calls POST /verify/heartbeat and returns the device state.
///
/// SRS heartbeat response shapes (all HTTP 200):
///
///   Active:
///   { "subscription_status": "active", "locked": false }
///
///   Reverification overdue:
///   { "subscription_status": "active", "locked": true,
///     "reason_code": "reverification_overdue" }
///
///   Device mismatch:
///   { "subscription_status": "active", "locked": true,
///     "reason_code": "device_mismatch" }
///
///   Not subscribed / pending:
///   { "subscription_status": "none", "locked": true,
///     "reason_code": "premium_required" }
/// ================================================================

enum DeviceStatusState { active, pending, revoked, mismatch, overdue, unknown }

class DeviceStatusData {
  final DeviceStatusState status;
  final String message;
  final DateTime? lastVerified;
  final String? subscriptionExpiry;

  const DeviceStatusData({
    required this.status,
    required this.message,
    this.lastVerified,
    this.subscriptionExpiry,
  });
}

class DeviceStatusNotifier
    extends AutoDisposeAsyncNotifier<DeviceStatusData> {
  @override
  Future<DeviceStatusData> build() async {
    return _fetchStatus();
  }

  Future<DeviceStatusData> _fetchStatus() async {
    final dio = ref.read(dioProvider);
    final storage = ref.read(secureStorageProvider);
    final fingerprintService = ref.read(deviceFingerprintServiceProvider);

    try {
      final fingerprint = await fingerprintService.getFingerprint();

      final response = await dio.post(
        ApiConstants.heartbeat,
        data: {'device_fingerprint': fingerprint},
      );

      final data = response.data as Map<String, dynamic>;

      // ── Parse SRS response shape ──────────────────────────────
      final subscriptionStatus =
          (data['subscription_status'] as String?) ?? 'none';
      final locked = (data['locked'] as bool?) ?? true;
      final reasonCode = data['reason_code'] as String?;
      final message = (data['message'] as String?) ??
          _defaultMessage(subscriptionStatus, locked, reasonCode);
      final expiryStr = data['subscription_expiry_date'] as String?;

      // ── Derive UI state ───────────────────────────────────────
      final deviceState = _deriveState(
        subscriptionStatus: subscriptionStatus,
        locked: locked,
        reasonCode: reasonCode,
      );

      // ── Persist timestamps when active ────────────────────────
      if (!locked && subscriptionStatus == 'active') {
        final now = DateTime.now().toIso8601String();
        await Future.wait([
          storage.write(StorageKeys.lastVerification, now),
          storage.write(StorageKeys.lastHeartbeat, now),
        ]);
      }

      return DeviceStatusData(
        status: deviceState,
        message: message,
        lastVerified: locked ? null : DateTime.now(),
        subscriptionExpiry: expiryStr,
      );
    } catch (e) {
      // ── Offline / server error ────────────────────────────────
      // Check if we are within the 7-day grace window using the
      // last stored verification timestamp.
      final lastVerifiedStr =
          await storage.read(StorageKeys.lastVerification);

      if (lastVerifiedStr != null) {
        final lastVerified = DateTime.tryParse(lastVerifiedStr);
        if (lastVerified != null) {
          final daysSince =
              DateTime.now().difference(lastVerified).inDays;
          if (daysSince < 7) {
            return DeviceStatusData(
              status: DeviceStatusState.active,
              message:
                  'Offline — using cached verification (${7 - daysSince} days remaining).',
              lastVerified: lastVerified,
            );
          } else {
            return const DeviceStatusData(
              status: DeviceStatusState.overdue,
              message:
                  'Re-verification required. Please connect to the internet.',
            );
          }
        }
      }

      return DeviceStatusData(
        status: DeviceStatusState.unknown,
        message: 'Could not reach the server. Check your connection.',
      );
    }
  }

  // ── Refresh ────────────────────────────────────────────────────

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchStatus);
  }

  // ── Helpers ────────────────────────────────────────────────────

  DeviceStatusState _deriveState({
    required String subscriptionStatus,
    required bool locked,
    required String? reasonCode,
  }) {
    if (!locked) return DeviceStatusState.active;

    switch (reasonCode) {
      case 'device_mismatch':
        return DeviceStatusState.mismatch;
      case 'reverification_overdue':
        return DeviceStatusState.overdue;
      case 'premium_required':
        return DeviceStatusState.pending;
      default:
        if (subscriptionStatus == 'none') return DeviceStatusState.pending;
        if (subscriptionStatus == 'expired') return DeviceStatusState.revoked;
        return DeviceStatusState.unknown;
    }
  }

  String _defaultMessage(
    String subscriptionStatus,
    bool locked,
    String? reasonCode,
  ) {
    if (!locked) return 'Your device is verified and active.';
    switch (reasonCode) {
      case 'device_mismatch':
        return 'This account is activated on a different device. '
            'Contact the admin via Telegram to reactivate.';
      case 'reverification_overdue':
        return 'Re-verification required. Connect to the internet.';
      case 'premium_required':
        return 'Upgrade to Premium to unlock all course resources.';
      default:
        if (subscriptionStatus == 'expired') {
          return 'Your subscription has expired. Please renew.';
        }
        return 'Device activation pending. Contact an admin.';
    }
  }
}

final deviceStatusProvider =
    AutoDisposeAsyncNotifierProvider<DeviceStatusNotifier, DeviceStatusData>(
  DeviceStatusNotifier.new,
);
