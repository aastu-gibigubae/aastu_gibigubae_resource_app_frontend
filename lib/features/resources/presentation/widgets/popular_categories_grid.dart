import 'package:flutter/material.dart';
import '../../../../core/widgets/category_icons.dart';
import '../../domain/entities/resource_category_type.dart';
import '../constants/resource_ui_constants.dart';

class PopularCategoriesGrid extends StatelessWidget {
  final void Function(ResourceCategoryType category) onCategoryTap;

  const PopularCategoriesGrid({
    super.key,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ResourceUiConstants.popularCategoryPairs.map((cat) {
            return SizedBox(
              width: itemWidth,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onCategoryTap(cat.$1),
                child: Row(
                  children: [
                    CategoryIconBadge(category: cat.$1, size: 40),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cat.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ResourceUiConstants.textNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
