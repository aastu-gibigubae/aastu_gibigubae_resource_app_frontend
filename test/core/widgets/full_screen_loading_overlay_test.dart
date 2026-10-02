import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aastu_gibigubae_resource_app_frontend/core/widgets/full_screen_loading_overlay.dart';

void main() {
  group('FullScreenLoadingOverlay', () {
    testWidgets('renders spinner, default title, and optional subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FullScreenLoadingOverlay(
              title: 'Logging out...',
              subtitle: 'Please wait a moment',
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Logging out...'), findsOneWidget);
      expect(find.text('Please wait a moment'), findsOneWidget);
    });

    testWidgets('renders default title when none provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FullScreenLoadingOverlay(),
          ),
        ),
      );

      expect(find.text('Please wait...'), findsOneWidget);
    });
  });
}
