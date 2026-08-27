import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/branding_widgets.dart';
import '../../providers/onboarding_provider.dart';

/// ================================================================
/// WELCOME PAGE
///
/// Shown once on first launch. Tapping "Get Access" marks
/// onboarding as complete and navigates to signup.
/// ================================================================

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  Future<void> _onGetAccess(BuildContext context, WidgetRef ref) async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (context.mounted) {
      context.go(RouteNames.signup);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = (width / 390).clamp(0.85, 1.15);

    return Scaffold(
      backgroundColor: Colors.white,
      body: AppBackground(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                /// ==================================================
                /// BRANDING
                /// ==================================================

                SizedBox(height: 74 * scale),

                BrandHeader(
                  style: BrandHeaderStyle.welcome,
                  logoWidth: 142 * scale,
                  titleSize: 40 * scale,
                  subtitleSize: 15.5 * scale,
                ),

                /// ==================================================
                /// WELCOME
                /// ==================================================

                SizedBox(height: 20 * scale),

                Text(
                  'Welcome, Freshmans!👋',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 4, 70, 190),
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                /// ==================================================
                /// DIVIDER
                /// ==================================================

                const AppDivider(
                  lineWidth: 50,
                  lineHeight: 5,
                  dotSize: 10,
                ),

                /// ==================================================
                /// TITLE
                /// ==================================================

                SizedBox(height: 28 * scale),

                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 25 * scale),
                  child: Text(
                    'Your Exam\nPreparation Hub',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 37 * scale,
                      fontWeight: FontWeight.w900,
                      height: 0.98,
                    ),
                  ),
                ),

                /// ==================================================
                /// DESCRIPTION
                /// ==================================================

                SizedBox(height: 15 * scale),

                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 35 * scale),
                  child: Text(
                    'Find course resources, previous exams,\n'
                    'notes, assignments, worksheets, and\n'
                    'study materials.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF263E62),
                      fontSize: 13 * scale,
                      height: 1.55,
                    ),
                  ),
                ),

                /// ==================================================
                /// ILLUSTRATION
                /// ==================================================

                SizedBox(height: 12 * scale),

                Image.asset(
                  'assets/images/onboarding.png',
                  width: 275 * scale,
                  height: 140 * scale,
                  fit: BoxFit.contain,
                ),

                /// ==================================================
                /// BUTTON
                /// ==================================================

                SizedBox(height: 5 * scale),

                SizedBox(
                  width: 167 * scale,
                  height: 45 * scale,
                  child: ElevatedButton(
                    onPressed: () => _onGetAccess(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10 * scale),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Access',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17 * scale,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 7 * scale),
                        Icon(
                          Icons.arrow_forward,
                          color: AppColors.secondary,
                          size: 17 * scale,
                        ),
                      ],
                    ),
                  ),
                ),

                /// ==================================================
                /// BOTTOM TEXT
                /// ==================================================

                SizedBox(height: 10 * scale),

                Text(
                  'All In One Place',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15 * scale,
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
