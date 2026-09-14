import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/category_icons.dart';
import '../../../../core/widgets/curved_header.dart';
import '../../data/datasources/mock_resource_datasource.dart';
import '../../domain/entities/course_item.dart';
import '../../providers/resource_providers.dart';
import '../constants/resource_ui_constants.dart';
import '../widgets/category_row_card.dart';
import '../widgets/course_stats_banner.dart';

class CourseCategoriesPage extends ConsumerWidget {
  final int courseId;
  final CourseItem? initialCourse;

  const CourseCategoriesPage({
    super.key,
    required this.courseId,
    this.initialCourse,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialCourse != null) {
      return _buildContent(context, initialCourse!);
    }

    final coursesAsync =
        ref.watch(coursesProvider(const CoursesParams()));

    return coursesAsync.when(
      data: (result) {
        final course = result.courses.firstWhere(
          (c) => c.id == courseId,
          orElse: () =>
              const MockResourceDatasource().getCourseById(courseId),
        );
        return _buildContent(context, course);
      },
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) {
        final course =
            const MockResourceDatasource().getCourseById(courseId);
        return _buildContent(context, course);
      },
    );
  }

  Widget _buildContent(BuildContext context, CourseItem course) {
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

            const SizedBox(height: 16),

            // Course Stats Banner (orphaned widget embedded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CourseStatsBanner(course: course),
            ),

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
  }
}
