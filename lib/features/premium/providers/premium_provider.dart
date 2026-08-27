import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ================================================================
/// PREMIUM PROVIDER
///
/// Loads the static payment instructions from the bundled JSON asset.
/// No backend call is made — instructions are fully offline.
/// ================================================================

class PaymentAccount {
  final String bank;
  final String accountNumber;
  final String accountName;

  const PaymentAccount({
    required this.bank,
    required this.accountNumber,
    required this.accountName,
  });

  factory PaymentAccount.fromJson(Map<String, dynamic> json) {
    return PaymentAccount(
      bank: json['bank'] as String,
      accountNumber: json['account_number'] as String,
      accountName: json['account_name'] as String,
    );
  }
}

class PremiumInstructions {
  final String title;
  final String subtitle;
  final String price;
  final List<PaymentAccount> paymentAccounts;
  final List<String> steps;
  final String telegramHandle;
  final String telegramUrl;
  final String note;

  const PremiumInstructions({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.paymentAccounts,
    required this.steps,
    required this.telegramHandle,
    required this.telegramUrl,
    required this.note,
  });

  factory PremiumInstructions.fromJson(Map<String, dynamic> json) {
    return PremiumInstructions(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      price: json['price'] as String,
      paymentAccounts: (json['payment_accounts'] as List)
          .map((e) => PaymentAccount.fromJson(e as Map<String, dynamic>))
          .toList(),
      steps: List<String>.from(json['steps'] as List),
      telegramHandle: json['telegram_handle'] as String,
      telegramUrl: json['telegram_url'] as String,
      note: json['note'] as String,
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────

final premiumInstructionsProvider =
    FutureProvider<PremiumInstructions>((ref) async {
  final jsonStr = await rootBundle
      .loadString('assets/premium/payment_instructions.json');
  final map = jsonDecode(jsonStr) as Map<String, dynamic>;
  return PremiumInstructions.fromJson(map);
});
