import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/widgets/branding_widgets.dart';
import '../../providers/premium_provider.dart';
import '../widgets/payment_widgets.dart';

class PremiumPage extends ConsumerStatefulWidget {
  const PremiumPage({super.key});

  @override
  ConsumerState<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends ConsumerState<PremiumPage> {
  @override
  void initState() {
    super.initState();
    _markPaymentSeen();
  }

  Future<void> _markPaymentSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageKeys.paymentSeen, true);
    } catch (_) {}
  }

  void _showHowToPaySheet(
      BuildContext context, PremiumInstructions? instructions) {
    final steps = instructions?.steps ??
        [
          'Transfer 150 ETB to one of the payment accounts.',
          'Take a screenshot of the payment confirmation.',
          'Message your payment screenshot and name to @gibigubae_admin on Telegram.',
          'Your account will be activated once verified — usually within a few hours.',
        ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'How to Pay & Activate',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              ...steps.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final text = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: AppColors.secondary,
                        child: Text(
                          '$idx',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF334155),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final instructions = ref.watch(premiumInstructionsProvider).valueOrNull;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Premium Access',
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
        showBottomRightCircle: false,
        showBottomRightOutline: false,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              30,
              10,
              30,
              30,
            ),
            child: Column(
              children: [
                const PaymentHeader(
                  imageAsset: 'assets/images/payment.png',
                  title: 'Get Access',
                  description:
                      'Pay the access fee to unlock all student resources, '
                      'past exams, notes, assignments and more.',
                ),

                const SizedBox(height: 16),

                const PaymentFeeCard(),

                const SizedBox(height: 16),

                const PaymentBankCard(),

                const SizedBox(height: 16),

                PaymentPrimaryButton(
                  text: "I've Sent my Payment",
                  onPressed: () {
                    context.go(RouteNames.paymentReview);
                  },
                ),

                const SizedBox(height: 12),

                PaymentOutlineButton(
                  text: 'How to Pay',
                  onPressed: () => _showHowToPaySheet(context, instructions),
                ),

                const SizedBox(height: 12),

                InkWell(
                  onTap: () async {
                    final url = instructions?.telegramUrl ??
                        'https://t.me/gibigubae_admin';
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: 300,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCE1EB),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.help_outline_rounded,
                          size: 20,
                          color: Color(0xFF0B2D6B),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Need help? Contact Admin',
                          style: TextStyle(
                            color: Color(0xFF0B2D6B),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}