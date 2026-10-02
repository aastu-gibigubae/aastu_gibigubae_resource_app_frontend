import 'package:flutter/material.dart';
import '../../../../core/widgets/category_icons.dart';
import '../../domain/entities/course_item.dart';
import '../constants/resource_ui_constants.dart';

class CourseCard extends StatelessWidget {
  final CourseItem course;
  final VoidCallback onTap;
  final bool isHighlighted;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isHighlighted ? const Color(0xFFFEF3C7).withAlpha(160) : Colors.white,
          borderRadius: BorderRadius.circular(ResourceUiConstants.cardBorderRadius),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFFFDE68A)
                : ResourceUiConstants.cardBorderColor,
            width: isHighlighted ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isHighlighted ? 10 : 6),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CourseIconBadge(iconKey: course.iconKey, size: 50),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ResourceUiConstants.textNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.semester,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${course.resourceCount}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: ResourceUiConstants.textNavy,
                  ),
                ),
                const Text(
                  'Resources',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
