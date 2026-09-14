import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aastu_gibigubae_resource_app_frontend/app/app.dart';
import 'package:aastu_gibigubae_resource_app_frontend/app/providers/app_providers.dart';

void main() {
  testWidgets('App smoke test builds successfully', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const FreshmanApp(),
      ),
    );

    // Initial frame builds without crashing
    expect(find.byType(FreshmanApp), findsOneWidget);
  });
}
