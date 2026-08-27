import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// ===============================================================
/// PAYMENT HEADER
/// ===============================================================

class PaymentHeader extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String description;

  const PaymentHeader({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          imageAsset,
          width: 110,
          height: 110,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 5),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF38557F),
              fontSize: 15,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

/// ===============================================================
/// PAYMENT PRIMARY BUTTON
/// ===============================================================

class PaymentPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const PaymentPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// ===============================================================
/// PAYMENT OUTLINE BUTTON
/// ===============================================================

class PaymentOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const PaymentOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: const BorderSide(
            color: AppColors.secondary,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ===============================================================
/// PAYMENT FEE CARD
/// ===============================================================

class PaymentFeeCard extends StatelessWidget {
  const PaymentFeeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 22, 25, 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Access Fee',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '150',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 56,
                  height: .7,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  'ETB',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Row(
            children: [
              Text(
                'One-time payment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.circle,
                color: AppColors.secondary,
                size: 7,
              ),
              SizedBox(width: 10),
              Text(
                'Full Access',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ===============================================================
/// BANK INFORMATION
/// ===============================================================

class PaymentBankCard extends StatelessWidget {
  const PaymentBankCard({super.key});

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xFFF0F4FC),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 15),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF38557F),
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 25, 28, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFD9D9D9),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Make Payment To',
            style: TextStyle(
              color: Color(0xFF38557F),
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          _row(Icons.account_balance, 'Bank Name'),
          const SizedBox(height: 5),
          _row(Icons.person, 'Account Name'),
          const SizedBox(height: 5),
          _row(Icons.credit_card, 'Account Number'),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE3E7EF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.error,
                  color: AppColors.primary,
                  size: 30,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'After payment, tap "I\'ve Made a Payment" '
                    'and enter the code sent by our admin.',
                    style: TextStyle(
                      color: Color(0xFF38557F),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================================================
/// REVIEW STEPS
/// ===============================================================

class PaymentReviewSteps extends StatelessWidget {
  const PaymentReviewSteps({super.key});

  Widget _step(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF292929),
                fontSize: 15,
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFB28A2A),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What happens next?',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),
          _step('1', 'Admin verifies your payment'),
          const SizedBox(height: 15),
          _step('2', 'Your account will be activated'),
          const SizedBox(height: 15),
          _step(
            '3',
            "You'll get a notification once access is approved",
          ),
        ],
      ),
    );
  }
}

/// ===============================================================
/// REVIEW STATUS CARD
/// ===============================================================

class PaymentStatusCard extends StatelessWidget {
  final VoidCallback? onCheckStatus;

  const PaymentStatusCard({
    super.key,
    this.onCheckStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFC8C8C8),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Current Status',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6DE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '● Pending Review',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "We'll notify you here in the app once your "
              "premium access is activated.",
              style: TextStyle(
                color: Color(0xFF38557F),
                fontSize: 15,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFDCE0E8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF28A9E0),
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'For any questions, contact our admin '
                    'on Telegram @gibigbugbaeAdmin',
                    style: TextStyle(
                      color: Color(0xFF38557F),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PaymentPrimaryButton(
            text: 'Check Status  ⟳',
            onPressed: onCheckStatus,
          ),
        ],
      ),
    );
  }
}