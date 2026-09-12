import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../constants/storage_keys.dart';
import '../storage/secure_storage.dart';
import 'device_service.dart';

/// ================================================================
/// DEVICE FINGERPRINT SERVICE
///
/// Generates a stable, anonymous device identifier.
///
/// Strategy:
///   1. Return the cached fingerprint from SecureStorage if present.
///   2. Otherwise build one from device details and a UUID salt,
///      hash it with SHA-256, persist it, and return it.
///
/// The fingerprint is sent with every login request so the backend
/// can associate the session with a specific device.
/// ================================================================

class DeviceFingerprintService {
  final DeviceService _deviceService;
  final SecureStorage _secureStorage;
  final Uuid _uuid;

  const DeviceFingerprintService({
    required this._deviceService,
    required this._secureStorage,
    Uuid uuid = const Uuid(),
  }) : _uuid = uuid;

  // ── Public API ─────────────────────────────────────────────────

  /// Returns the persisted fingerprint, or creates one on first call.
  Future<String> getFingerprint() async {
    final cached = await _secureStorage.read(StorageKeys.deviceFingerprint);
    if (cached != null && cached.isNotEmpty) return cached;

    final fingerprint = await _generate();
    await _secureStorage.write(StorageKeys.deviceFingerprint, fingerprint);
    return fingerprint;
  }

  /// Clears the fingerprint (used on logout / account switch).
  Future<void> clearFingerprint() async {
    await _secureStorage.delete(StorageKeys.deviceFingerprint);
  }

  // ── Private ────────────────────────────────────────────────────

  Future<String> _generate() async {
    final details = await _deviceService.getDeviceDetails();

    // Combine device info with a random salt for uniqueness.
    final salt = _uuid.v4();
    final raw =
        '${details.platform}|${details.model}|${details.osVersion}|${details.deviceId ?? salt}|$salt';

    final bytes = utf8.encode(raw);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
