import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/branding_widgets.dart';
import '../../../auth/providers/session_provider.dart';
import '../../../device/providers/device_status_provider.dart';
import '../widgets/payment_widgets.dart';

class PaymentReviewPage extends ConsumerStatefulWidget {
  const PaymentReviewPage({super.key});

  @override
  ConsumerState<PaymentReviewPage> createState() => _PaymentReviewPageState();
}

class _PaymentReviewPageState extends ConsumerState<PaymentReviewPage> {
  bool _isChecking = false;

  Future<void> _checkStatus() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    try {
      // First, call the heartbeat endpoint to fetch the latest
      // subscription_status from the server and persist it to SecureStorage.
      try {
        await ref.read(deviceStatusProvider.notifier).refresh();
      } catch (_) {
        // Heartbeat may fail (offline, etc.) — continue with cached data.
      }

      // Now isPremiumProvider reads the freshly updated SecureStorage.
      final isPremium = await ref.refresh(isPremiumProvider.future);
      if (!mounted) return;
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
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Payment Review',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
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
                  isLoading: _isChecking,
                  onCheckStatus: _isChecking ? null : _checkStatus,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}