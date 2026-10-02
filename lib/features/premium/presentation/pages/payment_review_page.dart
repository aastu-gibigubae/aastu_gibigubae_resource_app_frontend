import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/branding_widgets.dart';
import '../../../auth/providers/session_provider.dart';
import '../../../device/providers/device_status_provider.dart';
import '../widgets/payment_widgets.dart';

class PaymentReviewPage extends ConsumerWidget {
  const PaymentReviewPage({super.key});

  Future<void> _checkStatus(BuildContext context, WidgetRef ref) async {
    // First, call the heartbeat endpoint to fetch the latest
    // subscription_status from the server and persist it to SecureStorage.
    try {
      await ref.read(deviceStatusProvider.notifier).refresh();
    } catch (_) {
      // Heartbeat may fail (offline, etc.) — continue with cached data.
    }

    // Now isPremiumProvider reads the freshly updated SecureStorage.
    final isPremium = await ref.refresh(isPremiumProvider.future);
    if (!context.mounted) return;
    if (isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Your payment has been approved! Premium is active.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      context.go(RouteNames.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⏳ Payment verification is still pending. Our admin will approve it shortly.',
          ),
          backgroundColor: Color(0xFFD97706),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.home);
            }
          },
        ),
      ),
      body: AppBackground(
        showTopRightOutline: false,
        showBottomRightDots: false,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              30,
              10,
              30,
              50,
            ),
            child: Column(
              children: [
                const PaymentHeader(
                  imageAsset: 'assets/images/payment_review.png',
                  title: 'Payment Under Review',
                  description:
                      "Thank you! We've received your payment "
                      'request and our admin is reviewing it.',
                ),

                const SizedBox(height: 18),

                const PaymentReviewSteps(),

                const SizedBox(height: 18),

                PaymentStatusCard(
                  onCheckStatus: () => _checkStatus(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}