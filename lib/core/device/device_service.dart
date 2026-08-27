import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// ================================================================
/// DEVICE SERVICE
///
/// Reads platform-specific device metadata.
/// Used by DeviceFingerprintService and the heartbeat call.
/// ================================================================

class DeviceService {
  final DeviceInfoPlugin _deviceInfo;

  const DeviceService(this._deviceInfo);

  factory DeviceService.create() =>
      DeviceService(DeviceInfoPlugin());

  // ── Platform-agnostic info ─────────────────────────────────────

  Future<DeviceDetails> getDeviceDetails() async {
    if (Platform.isAndroid) {
      return _fromAndroid(await _deviceInfo.androidInfo);
    } else if (Platform.isIOS) {
      return _fromIos(await _deviceInfo.iosInfo);
    } else {
      // Web / Desktop fallback
      return const DeviceDetails(
        model: 'Unknown',
        osVersion: 'Unknown',
        platform: 'Other',
      );
    }
  }

  // ── Android ────────────────────────────────────────────────────

  DeviceDetails _fromAndroid(AndroidDeviceInfo info) {
    return DeviceDetails(
      model: '${info.manufacturer} ${info.model}',
      osVersion: 'Android ${info.version.release}',
      platform: 'Android',
      deviceId: info.id,
    );
  }

  // ── iOS ────────────────────────────────────────────────────────

  DeviceDetails _fromIos(IosDeviceInfo info) {
    return DeviceDetails(
      model: info.model,
      osVersion: '${info.systemName} ${info.systemVersion}',
      platform: 'iOS',
      deviceId: info.identifierForVendor,
    );
  }
}

/// Immutable value object for device metadata.
class DeviceDetails {
  final String model;
  final String osVersion;
  final String platform;
  final String? deviceId;

  const DeviceDetails({
    required this.model,
    required this.osVersion,
    required this.platform,
    this.deviceId,
  });

  Map<String, dynamic> toMap() => {
        'model': model,
        'os_version': osVersion,
        'platform': platform,
        if (deviceId != null) 'device_id': deviceId,
      };
}
