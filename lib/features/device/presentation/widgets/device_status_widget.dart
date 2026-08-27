import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';

/// ================================================================
/// DEVICE STATUS WIDGET
///
/// Shows device fingerprint info and last-verified timestamp.
/// ================================================================

class DeviceStatusWidget extends StatelessWidget {
  final String? fingerprint;
  final DateTime? lastVerified;

  const DeviceStatusWidget({
    super.key,
    this.fingerprint,
    this.lastVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDE3EF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          const Row(
            children: [
              Icon(Icons.phone_android_rounded,
                  color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'This Device',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEF0F5)),
          const SizedBox(height: 12),

          // ── Fingerprint ─────────────────────────────────────────
          if (fingerprint != null) ...[
            _InfoRow(
              label: 'Device ID',
              value: '${fingerprint!.substring(0, 16)}...',
            ),
            const SizedBox(height: 8),
          ],

          // ── Last verified ────────────────────────────────────────
          _InfoRow(
            label: 'Last Verified',
            value: lastVerified != null
                ? _formatDate(lastVerified!)
                : 'Not yet verified',
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
