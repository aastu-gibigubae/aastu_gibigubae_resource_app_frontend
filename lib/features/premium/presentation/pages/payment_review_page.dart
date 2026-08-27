import 'package:flutter/material.dart';

import '../../../../core/widgets/branding_widgets.dart';
import '../widgets/payment_widgets.dart';

class PaymentReviewPage extends StatelessWidget {
  const PaymentReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AppBackground(
showTopRightOutline: false,
        showBottomRightDots: false,
              
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              35,
              40,
              35,
              70,
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
                  onCheckStatus: () {
                    // Check payment status here.
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}