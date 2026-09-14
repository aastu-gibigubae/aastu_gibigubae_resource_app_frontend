import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/curved_header.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/providers/session_provider.dart';

class DeviceStatusPage extends ConsumerWidget {
  const DeviceStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;
    final isPremiumAsync = ref.watch(isPremiumProvider);
    final isPremium = user?.isPremium ?? isPremiumAsync.valueOrNull ?? false;

    final fingerprintAsync = ref.watch(
      FutureProvider<String?>((ref) async {
        return ref.read(deviceFingerprintServiceProvider).getFingerprint();
      }),
    );
    final rawFp = fingerprintAsync.valueOrNull;
    final deviceId = (rawFp != null && rawFp.isNotEmpty)
        ? 'DEV-${rawFp.substring(0, rawFp.length > 8 ? 8 : rawFp.length).toUpperCase()}'
        : 'DEV-ACTIVE';

    final planLabel = isPremium ? 'Freshman Premium' : 'Free Plan';
    final statusLabel = user?.isActivated == true
        ? (isPremium ? 'Active' : 'Basic')
        : 'Pending';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CurvedHeader(
              title: 'Device & Status',
              subtitle: 'Account & Subscription Verification',
              subtitleColor: Color(0xFFF59E0B),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      isPremium
                          ? Icons.verified_user_rounded
                          : Icons.shield_outlined,
                      size: 56,
                      color: isPremium
                          ? const Color(0xFF10B981)
                          : const Color(0xFF3B82F6),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isPremium ? 'Device Activated' : 'Device Registered',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isPremium
                          ? 'Your device is bound to this account. All downloads and course resources are unlocked.'
                          : 'Your device is bound to this account on the Free Plan. Upgrade to Premium to unlock downloads and offline access.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow('Plan', planLabel),
                    const Divider(height: 20, color: Color(0xFFF3F4F6)),
                    _buildInfoRow('Status', statusLabel, isSuccess: isPremium),
                    const Divider(height: 20, color: Color(0xFFF3F4F6)),
                    _buildInfoRow('Device ID', deviceId),
                    const SizedBox(height: 24),
                    if (!isPremium) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push(RouteNames.premium),
                          icon: const Icon(Icons.star_rounded,
                              color: Colors.white),
                          label: const Text(
                            'Upgrade to Premium',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          context.go(RouteNames.home);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Explore Course Resources',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isSuccess = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color:
                isSuccess ? const Color(0xFF10B981) : const Color(0xFF1E3A8A),
          ),
        ),
      ],
    );
  }
}
