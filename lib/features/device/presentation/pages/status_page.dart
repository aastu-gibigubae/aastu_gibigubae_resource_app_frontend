import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/providers/app_providers.dart';
import '../../providers/device_status_provider.dart';
import '../widgets/activation_status.dart';
import '../widgets/device_status_widget.dart';
import '../widgets/status_message.dart';

/// ================================================================
/// STATUS PAGE
///
/// Shows the device activation / heartbeat status.
/// Auto-refreshes when the page mounts.
/// ================================================================

class StatusPage extends ConsumerWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(deviceStatusProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Device Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              ref.read(deviceStatusProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: statusAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () =>
              ref.read(deviceStatusProvider.notifier).refresh(),
        ),
        data: (data) => _StatusBody(data: data),
      ),
    );
  }
}

// ── Main body ─────────────────────────────────────────────────────

class _StatusBody extends ConsumerWidget {
  final DeviceStatusData data;

  const _StatusBody({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fingerprintAsync = ref.watch(
      FutureProvider<String?>((ref) async {
        return ref
            .read(deviceFingerprintServiceProvider)
            .getFingerprint();
      }).future,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Status badge ─────────────────────────────────────────
          ActivationStatus(status: data.status),

          const SizedBox(height: 28),

          // ── Message card ─────────────────────────────────────────
          StatusMessage(data: data),

          const SizedBox(height: 20),

          // ── Device info ──────────────────────────────────────────
          FutureBuilder<String?>(
            future: fingerprintAsync,
            builder: (context, snapshot) {
              return DeviceStatusWidget(
                fingerprint: snapshot.data,
                lastVerified: data.lastVerified,
              );
            },
          ),

          const SizedBox(height: 28),

          // ── 7-day rule reminder ──────────────────────────────────
          if (data.status == DeviceStatusState.active)
            _SevenDayReminder(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── 7-day reminder ────────────────────────────────────────────────

class _SevenDayReminder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.calendar_today_rounded,
              color: AppColors.primary, size: 15),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Premium content is cached for 7 days. '
              'Connect to the internet at least once a week to keep access.',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 56, color: AppColors.grey),
            const SizedBox(height: 16),
            const Text(
              'Could not reach the server',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
