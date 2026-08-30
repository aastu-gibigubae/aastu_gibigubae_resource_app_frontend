import 'package:flutter/material.dart';
import '../../../../core/widgets/category_icons.dart';
import '../../domain/entities/resource_category_type.dart';
import '../constants/resource_ui_constants.dart';

class CategoryRowCard extends StatelessWidget {
  final ResourceCategoryType category;
  final String title;
  final VoidCallback onTap;

  const CategoryRowCard({
    super.key,
    required this.category,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResourceUiConstants.tileBorderRadius),
          border: Border.all(color: ResourceUiConstants.statsBorderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CategoryIconBadge(category: category, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ResourceUiConstants.textNavy,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: ResourceUiConstants.textNavy,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
