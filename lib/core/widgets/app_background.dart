import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top Grey Circle
        Positioned(
          top: -100,
          right: -200,
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

        // Top Blue Circle
        Positioned(
          top: -100,
          left: -200,
          child: Container(
            width: 330,
            height: 230,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Bottom Grey Circle
        Positioned(
          bottom: -180,
          right: -180,
          child: Container(
            width: 360,
            height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD6D6D6),
                width: 1.5,
              ),
            ),
          ),
        ),

        // Bottom Blue Circle
        Positioned(
          bottom: -190,
          right: -190,
          child: Container(
            width: 350,
            height: 350,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Bottom Dots
        Positioned(
          right: 18,
          bottom: 32,
          child: SizedBox(
            width: 60,
            child: Wrap(
              spacing: 9,
              runSpacing: 9,
              children: List.generate(
                12,
                (index) => Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF74633F),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),

        SafeArea(
          child: child,
        ),
      ],
    );
  }
}