import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// ===============================================================
/// YEAR SELECTION CARD
/// ===============================================================

class YearSelectionCard extends StatelessWidget {
  final String year;
  final bool selected;
  final VoidCallback onTap;

  const YearSelectionCard({
    super.key,
    required this.year,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),

        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : Colors.white,

          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: selected
                ? AppColors.primary
                : const Color(0xFFD8DEE9),
            width: 2,
          ),
        ),

        child: Stack(
          children: [
            // =====================================================
            // CONTENT
            // =====================================================

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.school,
                    size: 46,

                    color: selected
                        ? Colors.white
                        : AppColors.primary,
                  ),

                  const SizedBox(height: 7),

                  Text(
                    year,
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : AppColors.primary,

                      fontSize: 23,

                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // =====================================================
            // SELECTED CHECK
            // =====================================================

            if (selected)
              Positioned(
                top: 8,
                right: 8,

                child: Container(
                  width: 38,
                  height: 38,

                  decoration:
                      const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// FIELD OF STUDY CARD
/// ===============================================================

class FieldSelectionCard extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const FieldSelectionCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),

        height: 82,

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(17),

          border: Border.all(
            color: selected
                ? AppColors.primary
                : const Color(0xFFD8DEE9),

            width: selected ? 3 : 2,
          ),
        ),

        child: Row(
          children: [
            // ===================================================
            // TITLE
            // ===================================================

            Expanded(
              child: Center(
                child: Text(
                  title,

                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // ===================================================
            // RADIO / CHECK
            // ===================================================

            Padding(
              padding:
                  const EdgeInsets.only(
                right: 20,
              ),

              child: AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 180,
                ),

                width: 48,
                height: 48,

                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : Colors.white,

                  shape: BoxShape.circle,

                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : const Color(
                            0xFFD8DEE9,
                          ),

                    width: 3,
                  ),
                ),

                child: selected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 31,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// CONTINUE BUTTON
/// ===============================================================

class SelectionContinueButton
    extends StatelessWidget {
  final VoidCallback? onPressed;

  const SelectionContinueButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 74,

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.primary,

          foregroundColor:
              Colors.white,

          elevation: 0,

          padding: EdgeInsets.zero,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(28),
          ),
        ),

        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Text(
              'Continue',

              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(width: 20),

            const Icon(
              Icons.arrow_forward,
              color: AppColors.secondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}