import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aastu_gibigubae_resource_app_frontend/app/providers/app_providers.dart';
import 'package:aastu_gibigubae_resource_app_frontend/core/constants/storage_keys.dart';
import 'package:aastu_gibigubae_resource_app_frontend/features/auth/presentation/pages/login_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Remember Me functionality tests', () {
    testWidgets('Pre-fills email when rememberMe is true and savedEmail exists',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        StorageKeys.rememberMe: true,
        StorageKeys.savedEmail: 'student@aastu.edu.et',
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: LoginPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final emailFinder = find.byType(EditableText);
      expect(emailFinder, findsWidgets);

      // Verify that the text input contains the saved email
      expect(find.text('student@aastu.edu.et'), findsOneWidget);
    });

    testWidgets('Leaves email field empty when rememberMe is false',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        StorageKeys.rememberMe: false,
        StorageKeys.savedEmail: 'student@aastu.edu.et',
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: LoginPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('student@aastu.edu.et'), findsNothing);
    });
  });
}
