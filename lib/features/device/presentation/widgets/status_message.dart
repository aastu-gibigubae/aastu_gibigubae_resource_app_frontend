import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../providers/device_status_provider.dart';

/// ================================================================
/// STATUS MESSAGE
///
/// Human-readable explanation of the current device state with
/// appropriate styling and an optional action hint.
/// ================================================================

class StatusMessage extends StatelessWidget {
  final DeviceStatusData data;

  const StatusMessage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final config = _messageConfig(data.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(config.icon, color: config.iconColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.message,
                  style: TextStyle(
                    color: config.textColor,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          if (config.hint != null) ...[
            const SizedBox(height: 8),
            Text(
              config.hint!,
              style: TextStyle(
                color: config.textColor.withValues(alpha: 0.7),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _MessageConfig _messageConfig(DeviceStatusState s) {
    switch (s) {
      case DeviceStatusState.active:
        return _MessageConfig(
          bgColor: const Color(0xFFE8F5E9),
          borderColor: const Color(0xFFA5D6A7),
          iconColor: const Color(0xFF2E7D32),
          textColor: const Color(0xFF1B5E20),
          icon: Icons.check_circle_outline_rounded,
        );
      case DeviceStatusState.pending:
        return _MessageConfig(
          bgColor: const Color(0xFFFFF3E0),
          borderColor: const Color(0xFFFFCC80),
          iconColor: const Color(0xFFE65100),
          textColor: const Color(0xFFBF360C),
          icon: Icons.schedule_rounded,
          hint: 'Approval usually takes less than 24 hours.',
        );
      case DeviceStatusState.revoked:
        return _MessageConfig(
          bgColor: const Color(0xFFFFEBEE),
          borderColor: const Color(0xFFEF9A9A),
          iconColor: const Color(0xFFC62828),
          textColor: const Color(0xFFB71C1C),
          icon: Icons.error_outline_rounded,
          hint: 'Please contact support to resolve this.',
        );
      case DeviceStatusState.mismatch:
        return _MessageConfig(
          bgColor: const Color(0xFFF3E5F5),
          borderColor: const Color(0xFFCE93D8),
          iconColor: const Color(0xFF6A1B9A),
          textColor: const Color(0xFF4A148C),
          icon: Icons.warning_amber_rounded,
          hint: 'Log out and log in again on the correct device.',
        );
      case DeviceStatusState.overdue:
        return _MessageConfig(
          bgColor: const Color(0xFFFFEBEE),
          borderColor: const Color(0xFFEF9A9A),
          iconColor: const Color(0xFFB71C1C),
          textColor: const Color(0xFFB71C1C),
          icon: Icons.update_rounded,
          hint:
              'Connect to the internet and open the app to re-verify.',
        );
      default:
        return _MessageConfig(
          bgColor: const Color(0xFFF5F5F5),
          borderColor: const Color(0xFFE0E0E0),
          iconColor: AppColors.grey,
          textColor: const Color(0xFF424242),
          icon: Icons.info_outline_rounded,
        );
    }
  }
}

class _MessageConfig {
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;
  final String? hint;

  const _MessageConfig({
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
    this.hint,
  });
}
