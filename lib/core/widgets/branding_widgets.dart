import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// ===============================================================
/// APP BACKGROUND
///
/// COMMON background widget for:
/// - Splash
/// - Welcome
/// - Selection
/// - Other screens that need the same decorations
///
/// Every decoration can be enabled/disabled independently.
/// ===============================================================

class AppBackground extends StatelessWidget {
  final Widget child;

  /// Top-right thin outline.
  final bool showTopRightOutline;

  /// Bottom-right outer outline.
  final bool showBottomRightOutline;

  /// Bottom-right navy circle.
  final bool showBottomRightCircle;

  /// Bottom-right dotted pattern.
  final bool showBottomRightDots;

  const AppBackground({
    super.key,
    required this.child,

    this.showTopRightOutline = false,
    this.showBottomRightOutline = true,
    this.showBottomRightCircle = true,
    this.showBottomRightDots = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // =========================================================
        // WHITE BACKGROUND
        // =========================================================

        const ColoredBox(
          color: Colors.white,
        ),

        // =========================================================
        // TOP LEFT NAVY CURVE
        // =========================================================

        Positioned(
          top: -200,
          left: -200,
          child: Container(
            width: 330,
            height: 330,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),

        // =========================================================
        // TOP RIGHT OUTLINE
        // =========================================================

        if (showTopRightOutline)
          Positioned(
            top: -105,
            right: -205,
            child: Container(
              width: 360,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD6D6D6),
                  width: 1.5,
                ),
              ),
            ),
          ),

        // =========================================================
        // BOTTOM RIGHT OUTER OUTLINE
        // =========================================================

        if (showBottomRightOutline)
          Positioned(
            right: -233,
            bottom: -233,
            child: IgnorePointer(
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFB8B8B8),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),

        // =========================================================
        // BOTTOM RIGHT NAVY CIRCLE
        // =========================================================

        if (showBottomRightCircle)
          Positioned(
            right: -230,
            bottom: -230,
            child: IgnorePointer(
              child: Container(
                width: 380,
                height: 380,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

        // =========================================================
        // BOTTOM RIGHT DOTS
        // =========================================================

        if (showBottomRightDots)
          const Positioned(
            right: 25,
            bottom: 25,
            child: IgnorePointer(
              child: AppDotPattern(),
            ),
          ),

        // =========================================================
        // PAGE CONTENT
        // =========================================================

        SafeArea(
          child: child,
        ),
      ],
    );
  }
}

/// ===============================================================
/// BRAND HEADER STYLE
/// ===============================================================

enum BrandHeaderStyle {
  splash,
  welcome,
}

/// ===============================================================
/// BRAND HEADER
///
/// COMMON widget for Splash + Welcome.
///
/// Splash:
/// AASTU
/// FRESHMAN
/// RESOURCE APP
///
/// Welcome:
/// AASTU
/// FRESHMAN RESOURCE APP
/// ===============================================================

class BrandHeader extends StatelessWidget {
  final BrandHeaderStyle style;

  final double logoWidth;

  final double titleSize;

  final double subtitleSize;

  const BrandHeader({
    super.key,
    required this.style,
    this.logoWidth = 130,
    this.titleSize = 34,
    this.subtitleSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSplash =
        style == BrandHeaderStyle.splash;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // =========================================================
        // LOGO
        // =========================================================

        Image.asset(
          'assets/images/logo.png',
          width: logoWidth,
          fit: BoxFit.contain,
        ),

        // =========================================================
        // SPACE
        // =========================================================

        SizedBox(
          height: isSplash ? 13 : 10,
        ),

        // =========================================================
        // BRAND TEXT
        // =========================================================

        if (isSplash)
          _SplashBrandText(
            titleSize: titleSize,
            subtitleSize: subtitleSize,
          )
        else
          _WelcomeBrandText(
            titleSize: titleSize,
            subtitleSize: subtitleSize,
          ),
      ],
    );
  }
}

/// ===============================================================
/// SPLASH BRAND TEXT
/// ===============================================================

class _SplashBrandText extends StatelessWidget {
  final double titleSize;
  final double subtitleSize;

  const _SplashBrandText({
    required this.titleSize,
    required this.subtitleSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // =========================================================
        // AASTU
        // =========================================================

        Text(
          'AASTU',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 8),

        // =========================================================
        // FRESHMAN
        // =========================================================

        Text(
          'FRESHMAN',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 12),

        // =========================================================
        // RESOURCE APP
        // =========================================================

        Text(
          'RESOURCE APP',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: subtitleSize,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ],
    );
  }
}

/// ===============================================================
/// WELCOME BRAND TEXT
/// ===============================================================

class _WelcomeBrandText extends StatelessWidget {
  final double titleSize;
  final double subtitleSize;

  const _WelcomeBrandText({
    required this.titleSize,
    required this.subtitleSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // =========================================================
        // AASTU
        // =========================================================

        Text(
          'AASTU',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 12),

        // =========================================================
        // FRESHMAN RESOURCE APP
        // =========================================================

        Text(
          'FRESHMAN RESOURCE APP',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: subtitleSize,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ],
    );
  }
}

/// ===============================================================
/// APP DIVIDER
/// ===============================================================

class AppDivider extends StatelessWidget {
  final double lineWidth;
  final double lineHeight;
  final double dotSize;

  const AppDivider({
    super.key,
    this.lineWidth = 70,
    this.lineHeight = 3,
    this.dotSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // =========================================================
        // NAVY LINE
        // =========================================================

        Container(
          width: lineWidth,
          height: lineHeight,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        const SizedBox(width: 14),

        // =========================================================
        // GOLD DOT
        // =========================================================

        Container(
          width: dotSize,
          height: dotSize,
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 14),

        // =========================================================
        // GOLD LINE
        // =========================================================

        Container(
          width: lineWidth,
          height: lineHeight,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }
}

/// ===============================================================
/// APP DOT PATTERN
/// ===============================================================

class AppDotPattern extends StatelessWidget {
  final int rows;
  final int columns;
  final double dotSize;
  final double spacing;

  const AppDotPattern({
    super.key,
    this.rows = 3,
    this.columns = 4,
    this.dotSize = 9,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:
          (columns * dotSize) +
          ((columns - 1) * spacing),

      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,

        children: List.generate(
          rows * columns,
          (index) {
            return Container(
              width: dotSize,
              height: dotSize,

              decoration: BoxDecoration(
                color: const Color(0xFF59656D)
                    .withValues(alpha: 0.75),
                shape: BoxShape.circle,
              ),
            );
          },
        ),
      ),
    );
  }
}