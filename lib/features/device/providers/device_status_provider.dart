import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/failure.dart';

/// ================================================================
/// DEVICE STATUS PROVIDER
///
/// Calls the heartbeat endpoint and returns the device state.
///
/// Possible states from backend:
///   active | pending | revoked | mismatch | overdue
/// ================================================================

enum DeviceStatusState { active, pending, revoked, mismatch, overdue, unknown }

class DeviceStatusData {
  final DeviceStatusState status;
  final String message;
  final DateTime? lastVerified;

  const DeviceStatusData({
    required this.status,
    required this.message,
    this.lastVerified,
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
    final fingerprintService =
        ref.read(deviceFingerprintServiceProvider);

    try {
      final fingerprint = await fingerprintService.getFingerprint();

      final response = await dio.post(
        ApiConstants.heartbeat,
        data: {'device_fingerprint': fingerprint},
      );

      final data = response.data as Map<String, dynamic>;
      final statusStr = (data['status'] as String?) ?? 'unknown';
      final message = (data['message'] as String?) ?? _defaultMessage(statusStr);
      final verifiedAt = data['verified_at'] != null
          ? DateTime.tryParse(data['verified_at'] as String)
          : null;

      // Persist last verification timestamp.
      if (statusStr == 'active') {
        await storage.write(
          StorageKeys.lastVerification,
          DateTime.now().toIso8601String(),
        );
        await storage.write(
          StorageKeys.lastHeartbeat,
          DateTime.now().toIso8601String(),
        );
      }

      return DeviceStatusData(
        status: _parseStatus(statusStr),
        message: message,
        lastVerified: verifiedAt,
      );
    } on DioException catch (e) {
      final failure = ErrorMapper.fromDioException(e);
      return DeviceStatusData(
        status: _failureToState(failure),
        message: failure.message,
      );
    } catch (e) {
      return DeviceStatusData(
        status: DeviceStatusState.unknown,
        message: e.toString(),
      );
    }
  }

  // ── Refresh ────────────────────────────────────────────────────

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchStatus);
  }

  // ── Helpers ────────────────────────────────────────────────────

  DeviceStatusState _parseStatus(String s) {
    switch (s) {
      case 'active':
        return DeviceStatusState.active;
      case 'pending':
        return DeviceStatusState.pending;
      case 'revoked':
        return DeviceStatusState.revoked;
      case 'mismatch':
        return DeviceStatusState.mismatch;
      case 'overdue':
        return DeviceStatusState.overdue;
      default:
        return DeviceStatusState.unknown;
    }
  }

  DeviceStatusState _failureToState(Failure f) {
    if (f is DeviceMismatchFailure) return DeviceStatusState.mismatch;
    if (f is ReverificationOverdueFailure) return DeviceStatusState.overdue;
    return DeviceStatusState.unknown;
  }

  String _defaultMessage(String status) {
    switch (status) {
      case 'active':
        return 'Your device is verified and active.';
      case 'pending':
        return 'Your device is pending activation. Please wait for approval.';
      case 'revoked':
        return 'Your device access has been revoked. Contact support.';
      case 'mismatch':
        return 'This account is registered on a different device.';
      case 'overdue':
        return 'Re-verification is required. Connect to the internet.';
      default:
        return 'Unable to determine device status.';
    }
  }
}

final deviceStatusProvider =
    AutoDisposeAsyncNotifierProvider<DeviceStatusNotifier, DeviceStatusData>(
  DeviceStatusNotifier.new,
);
