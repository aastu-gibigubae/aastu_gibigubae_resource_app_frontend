import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/category_icons.dart';
import '../../../../core/widgets/curved_header.dart';
import '../../providers/resource_providers.dart';
import '../constants/resource_ui_constants.dart';
import '../widgets/category_row_card.dart';

class CourseCategoriesPage extends ConsumerWidget {
  final int courseId;

  const CourseCategoriesPage({
    super.key,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch all courses and find the one with matching ID.
    final coursesAsync =
        ref.watch(coursesProvider(const CoursesParams()));

    return coursesAsync.when(
      data: (result) {
        final course = result.courses.firstWhere(
          (c) => c.id == courseId,
          orElse: () => result.courses.isNotEmpty
              ? result.courses.first
              : throw Exception('No courses available'),
        );

        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                CurvedHeader(
                  showBackButton: true,
                  titleWidget: Row(
                    children: [
                      CourseIconBadge(iconKey: course.iconKey, size: 54),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            AppSpacing.gapXs,
                            Text(
                              course.semester,
                              style: const TextStyle(
                                color: ResourceUiConstants.accentGold,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpacing.gapMd,

                AppSpacing.gapLg,

                // Resource Categories List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        ResourceUiConstants.resourceCategories,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...ResourceUiConstants.categoryPairs.map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CategoryRowCard(
                            category: cat.$1,
                            title: cat.$2,
                            onTap: () {
                              context.push(
                                RouteNames.courseCategoryResources,
                                extra: {
                                  'courseId': course.id,
                                  'category': cat.$1,
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text('Error: $err'),
        ),
      ),
    );
  }
}
