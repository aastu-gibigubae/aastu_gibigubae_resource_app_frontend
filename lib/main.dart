import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise SharedPreferences before the widget tree is built so
  // the sharedPreferencesProvider override is ready.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Inject the SharedPreferences instance into the provider.
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const FreshmanApp(),
    ),
  );
}
