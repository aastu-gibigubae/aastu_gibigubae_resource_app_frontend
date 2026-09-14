import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:aastu_gibigubae_resource_app_frontend/features/premium/providers/premium_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Premium Instructions Tests', () {
    const rawJson = '''
{
  "title": "Go Premium",
  "subtitle": "Get unlimited access to all course resources",
  "price": "200 ETB / semester",
  "payment_accounts": [
    {
      "bank": "Commercial Bank of Ethiopia (CBE)",
      "account_number": "1000123456789",
      "account_name": "AASTU Gibigubae"
    },
    {
      "bank": "Telebirr",
      "account_number": "0912345678",
      "account_name": "AASTU Gibigubae"
    }
  ],
  "steps": [
    "Transfer 200 ETB to one of the accounts above.",
    "Take a screenshot of the payment confirmation.",
    "Send the screenshot to our Telegram bot for verification.",
    "Your account will be activated within 24 hours."
  ],
  "telegram_handle": "@aastu_freshman_bot",
  "telegram_url": "https://t.me/aastu_freshman_bot",
  "note": "Premium access is valid for one semester."
}
''';

    test('parses price, accounts, steps, and telegram URL accurately', () {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      final instructions = PremiumInstructions.fromJson(map);

      expect(instructions.price, '200 ETB / semester');
      expect(instructions.paymentAccounts.length, 2);
      expect(instructions.paymentAccounts[0].bank,
          'Commercial Bank of Ethiopia (CBE)');
      expect(instructions.paymentAccounts[0].accountNumber, '1000123456789');
      expect(instructions.paymentAccounts[1].bank, 'Telebirr');
      expect(instructions.paymentAccounts[1].accountNumber, '0912345678');
      expect(instructions.steps.length, 4);
      expect(instructions.telegramHandle, '@aastu_freshman_bot');
      expect(instructions.telegramUrl, 'https://t.me/aastu_freshman_bot');
    });
  });
}
