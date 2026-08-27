import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../providers/device_status_provider.dart';

/// ================================================================
/// ACTIVATION STATUS WIDGET
///
/// Large badge showing the current activation state with
/// an icon, colour, and label appropriate to the status.
/// ================================================================

class ActivationStatus extends StatelessWidget {
  final DeviceStatusState status;

  const ActivationStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: config.color, width: 1.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, color: config.color, size: 18),
          const SizedBox(width: 8),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _statusConfig(DeviceStatusState s) {
    switch (s) {
      case DeviceStatusState.active:
        return _StatusConfig(
          color: const Color(0xFF2E7D32),
          icon: Icons.verified_rounded,
          label: 'ACTIVE',
        );
      case DeviceStatusState.pending:
        return _StatusConfig(
          color: const Color(0xFFE65100),
          icon: Icons.hourglass_top_rounded,
          label: 'PENDING',
        );
      case DeviceStatusState.revoked:
        return _StatusConfig(
          color: const Color(0xFFC62828),
          icon: Icons.block_rounded,
          label: 'REVOKED',
        );
      case DeviceStatusState.mismatch:
        return _StatusConfig(
          color: const Color(0xFF6A1B9A),
          icon: Icons.devices_other_rounded,
          label: 'DEVICE MISMATCH',
        );
      case DeviceStatusState.overdue:
        return _StatusConfig(
          color: const Color(0xFFB71C1C),
          icon: Icons.update_rounded,
          label: 'REVERIFICATION REQUIRED',
        );
      default:
        return _StatusConfig(
          color: AppColors.grey,
          icon: Icons.help_outline_rounded,
          label: 'UNKNOWN',
        );
    }
  }
}

class _StatusConfig {
  final Color color;
  final IconData icon;
  final String label;

  const _StatusConfig({
    required this.color,
    required this.icon,
    required this.label,
  });
}
