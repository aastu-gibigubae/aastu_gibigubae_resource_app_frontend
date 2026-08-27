import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/branding_widgets.dart';
import '../../providers/splash_provider.dart';

/// ================================================================
/// SPLASH PAGE
///
/// Displays branding for [AppConstants.splashDuration] while the
/// [splashDestinationProvider] resolves where to navigate next.
/// ================================================================

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  Timer? _minTimer;
  bool _minTimeElapsed = false;
  SplashDestination? _destination;

  @override
  void initState() {
    super.initState();

    // Minimum display time so the splash never flickers away instantly.
    _minTimer = Timer(
      const Duration(seconds: 2),
      () {
        _minTimeElapsed = true;
        _maybeNavigate();
      },
    );

    // Listen for provider resolution.
    Future.microtask(_listenDestination);
  }

  Future<void> _listenDestination() async {
    final dest =
        await ref.read(splashDestinationProvider.future);
    _destination = dest;
    _maybeNavigate();
  }

  void _maybeNavigate() {
    if (!_minTimeElapsed || _destination == null || !mounted) return;

    switch (_destination!) {
      case SplashDestination.onboarding:
        context.go(RouteNames.onboarding);
      case SplashDestination.login:
        context.go(RouteNames.login);
      case SplashDestination.selection:
        context.go(RouteNames.selection);
    }
  }

  @override
  void dispose() {
    _minTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AppBackground(
        showTopRightOutline: true,
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                // ── Branding ───────────────────────────────────────
                const Spacer(),

                const BrandHeader(
                  style: BrandHeaderStyle.splash,
                  logoWidth: 130,
                  titleSize: 34,
                  subtitleSize: 22,
                ),

                const SizedBox(height: 18),

                const AppDivider(
                  lineWidth: 70,
                  lineHeight: 3,
                  dotSize: 10,
                ),

                const SizedBox(height: 22),

                const Text(
                  'Ace Your Exams. Find Your Department.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF263E62),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),

                // ── Loading ────────────────────────────────────────
                const Spacer(),

                const SizedBox(
                  width: 38,
                  height: 38,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.secondary,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Loading...',
                  style: TextStyle(
                    color: Color(0xFF263E62),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 65),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
