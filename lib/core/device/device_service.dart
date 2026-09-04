import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// ================================================================
/// DEVICE SERVICE
///
/// Reads platform-specific device metadata.
/// Safe on all platforms including Web and Desktop.
/// ================================================================

class DeviceService {
  final DeviceInfoPlugin _deviceInfo;

  const DeviceService(this._deviceInfo);

  factory DeviceService.create() => DeviceService(DeviceInfoPlugin());

  Future<DeviceDetails> getDeviceDetails() async {
    // Web — dart:io Platform is not available at all
    if (kIsWeb) {
      final info = await _deviceInfo.webBrowserInfo;
      return DeviceDetails(
        model: info.browserName.name,
        osVersion: info.platform ?? 'Web',
        platform: 'Web',
        deviceId: info.userAgent,
      );
    }

    // Mobile / Desktop — dart:io is safe here
    if (Platform.isAndroid) {
      return _fromAndroid(await _deviceInfo.androidInfo);
    } else if (Platform.isIOS) {
      return _fromIos(await _deviceInfo.iosInfo);
    } else if (Platform.isWindows) {
      final info = await _deviceInfo.windowsInfo;
      return DeviceDetails(
        model: info.productName,
        osVersion: 'Windows ${info.displayVersion}',
        platform: 'Windows',
        deviceId: info.deviceId,
      );
    } else if (Platform.isMacOS) {
      final info = await _deviceInfo.macOsInfo;
      return DeviceDetails(
        model: info.model,
        osVersion: 'macOS ${info.osRelease}',
        platform: 'macOS',
        deviceId: info.systemGUID,
      );
    } else if (Platform.isLinux) {
      final info = await _deviceInfo.linuxInfo;
      return DeviceDetails(
        model: info.name,
        osVersion: info.version ?? 'Linux',
        platform: 'Linux',
        deviceId: info.machineId,
      );
    }

    return const DeviceDetails(
      model: 'Unknown',
      osVersion: 'Unknown',
      platform: 'Other',
    );
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
