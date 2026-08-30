import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class CurvedHeader extends StatelessWidget {
  final Widget? leading;
  final String? title;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget? titleWidget;
  final Widget? bottomChild;
  final Widget? heroGraphic;
  final double? height;
  final VoidCallback? onBack;
  final bool showBackButton;
  final EdgeInsets padding;

  const CurvedHeader({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.subtitleColor,
    this.titleWidget,
    this.bottomChild,
    this.heroGraphic,
    this.height,
    this.onBack,
    this.showBackButton = false,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 24),
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: topPadding + 10,
          left: padding.left,
          right: padding.right,
          bottom: padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top action bar (back button if enabled)
            if (showBackButton || leading != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    if (showBackButton)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onBack ?? () => Navigator.of(context).maybePop(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      )
                    else
                      ?leading,
                  ],
                ),
              ),

            // Title and Subtitle area
            if (titleWidget != null)
              titleWidget!
            else ...[
              if (title != null)
                Text(
                  title!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: subtitleColor ?? const Color(0xFFFBBF24),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],

            // Bottom Child (e.g. Search Bar or Custom widget)
            if (bottomChild != null) ...[
              const SizedBox(height: 16),
              bottomChild!,
            ],

            // Optional Hero Graphic (e.g. PDF document centered at header bottom)
            if (heroGraphic != null) ...[
              const SizedBox(height: 12),
              Center(child: heroGraphic!),
            ],
          ],
        ),
      ),
    );
  }
}
