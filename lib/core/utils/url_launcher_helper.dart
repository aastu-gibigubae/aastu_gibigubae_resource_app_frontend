import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// ================================================================
/// URL LAUNCHER HELPER
///
/// Provides robust, fallback-enabled external launching for
/// Telegram handles and web URLs without silently failing on Android.
/// ================================================================

class UrlLauncherHelper {
  UrlLauncherHelper._();

  /// Launches Telegram directly into the app (via tg:// scheme),
  /// falling back gracefully to the web URL (https://t.me/...).
  static Future<void> launchTelegram(
    BuildContext context, {
    String handle = '@gibigubae_admin',
  }) async {
    final cleanHandle = handle.replaceAll('@', '').trim();
    final appUri = Uri.parse('tg://resolve?domain=$cleanHandle');
    final webUri = Uri.parse('https://t.me/$cleanHandle');

    bool launched = false;

    // 1. Try launching native Telegram app directly
    try {
      launched = await launchUrl(
        appUri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
    } catch (_) {
      // Telegram app scheme not handled or not installed
    }

    // 2. If native app scheme did not open, try external application (browser / app chooser)
    if (!launched) {
      try {
        launched = await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {}
    }

    // 3. Fallback to platform default mode
    if (!launched) {
      try {
        launched = await launchUrl(
          webUri,
          mode: LaunchMode.platformDefault,
        );
      } catch (_) {}
    }

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open Telegram for @$cleanHandle'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  /// Opens an external web URL safely.
  static Future<void> launchWebUrl(
    BuildContext context,
    String url,
  ) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    bool launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}

    if (!launched) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open link: $url'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }
}
