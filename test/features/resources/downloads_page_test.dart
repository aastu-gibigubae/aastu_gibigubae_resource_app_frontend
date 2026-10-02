import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aastu_gibigubae_resource_app_frontend/features/resources/domain/entities/resource_category_type.dart';
import 'package:aastu_gibigubae_resource_app_frontend/features/resources/domain/entities/resource_item.dart';
import 'package:aastu_gibigubae_resource_app_frontend/features/resources/presentation/pages/downloads_page.dart';
import 'package:aastu_gibigubae_resource_app_frontend/features/resources/providers/resource_providers.dart';

void main() {
  group('DownloadsPage Widget Tests', () {
    testWidgets('shows empty state when there are no offline downloads',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            downloadedResourcesProvider
                .overrideWith((ref) => Future.value([])),
          ],
          child: const MaterialApp(
            home: DownloadsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Offline Downloads'), findsOneWidget);
      expect(find.text('No offline downloads yet'), findsOneWidget);
      expect(find.text('Browse Resources'), findsOneWidget);
    });

    testWidgets('displays list of downloaded resources correctly',
        (tester) async {
      final mockDownloads = [
        const ResourceItem(
          id: 101,
          title: 'Calculus Chapter 1 Summary',
          courseName: 'Applied Mathematics I',
          category: ResourceCategoryType.handouts,
          fileSizeBytes: 2097152, // 2.0 MB
          fileUrl: '/mock/path/res_101.pdf',
        ),
        const ResourceItem(
          id: 102,
          title: 'Physics Midterm 2024',
          courseName: 'General Physics',
          category: ResourceCategoryType.midterms,
          fileSizeBytes: 1048576, // 1.0 MB
          fileUrl: '/mock/path/res_102.pdf',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            downloadedResourcesProvider
                .overrideWith((ref) => Future.value(mockDownloads)),
          ],
          child: const MaterialApp(
            home: DownloadsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Offline Downloads'), findsOneWidget);
      expect(find.text('2 downloaded files'), findsOneWidget);
      expect(find.text('3.0 MB used'), findsOneWidget);
      expect(find.text('Calculus Chapter 1 Summary'), findsOneWidget);
      expect(find.text('Physics Midterm 2024'), findsOneWidget);
    });

    testWidgets(
        'shows expired banner, locked badge, and dialog when subscription expired',
        (tester) async {
      final expiredDownloads = [
        const ResourceItem(
          id: 101,
          title: 'Calculus Chapter 1 Summary',
          courseName: 'Applied Mathematics I',
          category: ResourceCategoryType.handouts,
          fileSizeBytes: 2097152,
          fileUrl: '/mock/path/res_101.pdf',
          locked: true,
          reasonCode: 'premium_required',
          message: 'Subscription expired. Renew to access.',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            downloadedResourcesProvider
                .overrideWith((ref) => Future.value(expiredDownloads)),
          ],
          child: const MaterialApp(
            home: DownloadsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Expired banner is visible
      expect(find.text('Subscription Expired'), findsOneWidget);
      expect(find.text('Renew'), findsOneWidget);
      expect(find.text('Locked'), findsOneWidget);

      // Tapping the locked tile opens Subscription Required dialog
      await tester.tap(find.text('Calculus Chapter 1 Summary'));
      await tester.pumpAndSettle();

      expect(find.text('Subscription Required'), findsOneWidget);
      expect(find.text('Renew Access'), findsOneWidget);
      expect(find.text('Dismiss'), findsOneWidget);
    });
  });
}
