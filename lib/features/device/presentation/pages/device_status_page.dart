import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/device_status_provider.dart';

class DeviceStatusPage extends ConsumerWidget {
  const DeviceStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;
    final deviceStatusAsync = ref.watch(deviceStatusProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Navy Curved Header matching image copy 19.png
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.of(context).padding.top + 12,
                  24,
                  26,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(RouteNames.home);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Status',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Your account and access, in one place',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Refresh button
                    IconButton(
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        ref.read(deviceStatusProvider.notifier).refresh();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Content driven by deviceStatusProvider
              deviceStatusAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                error: (e, _) => _buildStatusContent(
                  context: context,
                  isSubActive: false,
                  subscriptionText: 'Unknown',
                  subscriptionColor: const Color(0xFF64748B),
                  expiryText: 'Unable to check status',
                  deviceState: DeviceStatusState.unknown,
                  deviceText: 'Unknown',
                  lastVerifiedText: 'Could not connect',
                ),
                data: (data) {
                  final isSubActive =
                      data.status == DeviceStatusState.active;

                  // Derive subscription text
                  String subscriptionText;
                  Color subscriptionColor;
                  if (isSubActive) {
                    subscriptionText = 'Active';
                    subscriptionColor = const Color(0xFF16A34A);
                  } else if (data.status == DeviceStatusState.overdue) {
                    subscriptionText = 'Expired';
                    subscriptionColor = const Color(0xFFDC2626);
                  } else {
                    subscriptionText = 'Inactive';
                    subscriptionColor = const Color(0xFFDC2626);
                  }

                  // Expiry text
                  final expires = user?.subscriptionExpiresAt;
                  String expiryText;
                  if (expires != null) {
                    expiryText =
                        'Access ends ${expires.month}/${expires.day}/${expires.year}';
                  } else if (isSubActive) {
                    expiryText = 'Premium access active';
                  } else {
                    expiryText = 'No active access';
                  }

                  // Device text
                  String deviceText;
                  switch (data.status) {
                    case DeviceStatusState.active:
                      deviceText = 'Activated';
                    case DeviceStatusState.mismatch:
                      deviceText = 'Device Mismatch';
                    case DeviceStatusState.pending:
                      deviceText = 'Pending Activation';
                    case DeviceStatusState.revoked:
                      deviceText = 'Revoked';
                    case DeviceStatusState.overdue:
                      deviceText = 'Re-verification Required';
                    case DeviceStatusState.unknown:
                      deviceText = user?.isActivated == true
                          ? 'Activated'
                          : 'Pending Activation';
                  }

                  // Last verified text
                  String lastVerifiedText;
                  if (data.lastVerified != null) {
                    final now = DateTime.now();
                    final diff = now.difference(data.lastVerified!);
                    if (diff.inMinutes < 2) {
                      lastVerifiedText = 'Last checked just now';
                    } else if (diff.inHours < 1) {
                      lastVerifiedText =
                          'Last checked ${diff.inMinutes} min ago';
                    } else if (diff.inDays < 1) {
                      lastVerifiedText =
                          'Last checked ${diff.inHours} hours ago';
                    } else {
                      lastVerifiedText =
                          'Last checked ${diff.inDays} days ago';
                    }
                  } else {
                    lastVerifiedText = 'Not yet verified';
                  }

                  return _buildStatusContent(
                    context: context,
                    isSubActive: isSubActive,
                    subscriptionText: subscriptionText,
                    subscriptionColor: subscriptionColor,
                    expiryText: expiryText,
                    deviceState: data.status,
                    deviceText: deviceText,
                    lastVerifiedText: lastVerifiedText,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusContent({
    required BuildContext context,
    required bool isSubActive,
    required String subscriptionText,
    required Color subscriptionColor,
    required String expiryText,
    required DeviceStatusState deviceState,
    required String deviceText,
    required String lastVerifiedText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subscription Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subscription',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSubActive
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSubActive
                            ? Icons.check
                            : Icons.lock_outline_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subscriptionText,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: subscriptionColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            expiryText,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.shield_outlined,
                      size: 26,
                      color: Color(0xFF0F172A),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // This device Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This device',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.phone_android_rounded,
                        size: 34,
                        color: deviceState == DeviceStatusState.mismatch
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deviceText,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: deviceState == DeviceStatusState.mismatch
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lastVerifiedText,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Helper note text matching image copy 19.png
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Access is re-checked automatically about once a week. '
            "If you're offline for more than 7 days, downloaded files lock until you reconnect.",
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}
