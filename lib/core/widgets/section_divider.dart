import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 70,
          height: 2,
          color: Colors.blue,
        ),
        const SizedBox(width: 14),
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 70,
          height: 2,
          color: AppColors.secondary,
        ),
      ],
    );
  }
}