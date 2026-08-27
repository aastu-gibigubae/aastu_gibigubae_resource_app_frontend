import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/branding_widgets.dart';
import '../widgets/payment_widgets.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AppBackground(
        showTopRightOutline: false,
        showBottomRightDots: false,
        showBottomRightCircle: false,
        showBottomRightOutline: false,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              40,
              30,
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

                const SizedBox(height: 12),

                const PaymentFeeCard(),

                const SizedBox(height: 12),

                const PaymentBankCard(),

                const SizedBox(height: 12),

                PaymentPrimaryButton(
                  text: "I've Made a Payment",
                  onPressed: () {
                    context.go(RouteNames.paymentReview);
                  },
                ),

                const SizedBox(height: 12),

                PaymentOutlineButton(
                  text: 'How to Pay',
                  onPressed: () {
                    // How-to-pay action.
                  },
                ),

                const SizedBox(height: 12),

                Container(
                  width: 300,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCE1EB),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Text(
                    'Need help? Contact Admin',
                    style: TextStyle(
                      color: Color(0xFF0B2D6B),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
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