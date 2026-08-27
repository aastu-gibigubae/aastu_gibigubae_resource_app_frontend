import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_providers.dart';
import 'theme/app_theme.dart';

/// ================================================================
/// FRESHMAN APP
///
/// Root widget. Uses go_router for navigation and Riverpod for
/// state management.
/// ================================================================

class FreshmanApp extends ConsumerWidget {
  const FreshmanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'AASTU Freshman',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
